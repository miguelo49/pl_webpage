class NewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_news_item, only: [ :show ]

  PER_PAGE = 10

  def index
    authorize News

    scope = policy_scope(News).includes(:user, featured_image_attachment: :blob).recent
    scope = filter_by_category(scope)

    @total_count = scope.count
    @page = current_page
    @total_pages = [ (@total_count / PER_PAGE.to_f).ceil, 1 ].max
    @page = [ @page, @total_pages ].min
    @news_items = scope.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
    @selected_category = selected_category_param
  end

  def show
    authorize @news_item
  end

  def new
    @news_item = News.new
    authorize @news_item
  end

  def create
    @news_item = News.new(news_params.merge(user: current_user))
    authorize @news_item

    if @news_item.save
      redirect_to news_path(@news_item), notice: "Noticia publicada correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_news_item
    @news_item = News.includes(:user, featured_image_attachment: :blob).find(params[:id])
  end

  def news_params
    params.require(:news).permit(:title, :summary, :body, :category, :published_at, :featured_image)
  end

  def filter_by_category(scope)
    return scope unless selected_category_param.present?

    scope.where(category: selected_category_param)
  end

  def selected_category_param
    return unless params[:category].present?
    return unless News.categories.key?(params[:category])

    params[:category]
  end

  def current_page
    [ params[:page].to_i, 1 ].max
  end
end
