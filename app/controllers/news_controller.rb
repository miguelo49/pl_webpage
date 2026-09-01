class NewsController < ApplicationController
  include ReactionHandling

  before_action :authenticate_user!
  before_action :set_news_item, only: [ :show, :edit, :update, :destroy, :react ]

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
    load_discussion_context
  end

  def react
    authorize @news_item, :show?
    toggle_reaction(@news_item)
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

  def edit
    authorize @news_item
  end

  def update
    authorize @news_item

    remove_image = remove_featured_image?

    if @news_item.update(news_params.except(:remove_featured_image))
      @news_item.featured_image.purge if remove_image
      redirect_to news_path(@news_item), notice: "Noticia actualizada correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @news_item
    @news_item.destroy!

    redirect_to news_index_path, notice: "Noticia eliminada correctamente."
  end

  private

  def set_news_item
    @news_item = News.includes(:user, :thread, :reactions, featured_image_attachment: :blob).find(params[:id])
  end

  def load_discussion_context
    @thread = @news_item.thread
    return unless @thread

    @topic = @thread.topic
    @comments = visible_comments
    @comment = @thread.comments.build
    authorize @comment, :create?
  end

  def visible_comments
    comments = @thread.comments.top_level
      .includes(:user, :reactions, :replies, replies: [ :user, :reactions ])
      .order(created_at: :asc)

    return comments if current_user.board_member? || current_user.moderator? || current_user.technical_admin?

    comments.publicly_visible
  end

  def news_params
    params.require(:news).permit(:title, :summary, :body, :category, :published_at, :featured_image, :remove_featured_image)
  end

  def remove_featured_image?
    ActiveModel::Type::Boolean.new.cast(news_params[:remove_featured_image])
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
