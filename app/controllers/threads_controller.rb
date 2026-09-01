class ThreadsController < ApplicationController
  include ReactionHandling
  include BookmarkHandling

  before_action :authenticate_user!
  before_action :set_topic, except: [ :index ]
  before_action :set_thread, only: [ :show, :edit, :update, :react, :bookmark ]

  PER_PAGE = 10

  def index
    authorize ForumThread, :index?
    @topics = Topic.ordered
    @selected_topic_ids = selected_topic_ids
    @threads = policy_scope(ForumThread)
      .includes(:user, :topic, :reactions, :comments)
      .left_joins(:comments)
      .group("threads.id")
      .select("threads.*, GREATEST(threads.created_at, COALESCE(MAX(comments.created_at), threads.created_at)) AS last_activity_at")
      .order("last_activity_at DESC")

    if @selected_topic_ids.any?
      @threads = @threads.where(topic_id: @selected_topic_ids)
    end

    @total_count = @threads.except(:select, :group, :order).count
    @page = current_page
    @total_pages = [ (@total_count / PER_PAGE.to_f).ceil, 1 ].max
    @page = [ @page, @total_pages ].min
    @threads = @threads.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
  end

  def show
    authorize @thread
    @comments = visible_comments
    @comment = @thread.comments.build
    authorize @comment, :create?
  end

  def react
    authorize @thread, :show?
    toggle_reaction(@thread)
  end

  def bookmark
    authorize @thread, :show?
    toggle_bookmark(@thread)
  end

  def new
    @thread = @topic.threads.build(user: current_user)
    authorize @thread
  end

  def create
    @thread = @topic.threads.build(thread_params.merge(user: current_user))
    authorize @thread

    if @thread.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_after_create }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @thread
  end

  def update
    authorize @thread

    if @thread.update(thread_params)
      redirect_to topic_thread_path(@topic, @thread), notice: "Hilo actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def selected_topic_ids
    Array(params[:topic_ids]).reject(&:blank?).map(&:to_i)
  end

  def current_page
    [ params[:page].to_i, 1 ].max
  end

  def set_topic
    @topic = Topic.find(params[:topic_id])
  end

  def set_thread
    @thread = @topic.threads.includes(:reactions, :bookmarks).find(params[:id])
  end

  def thread_params
    params.require(:forum_thread).permit(:title, :body)
  end

  def visible_comments
    comments = @thread.comments.top_level
      .includes(:user, :reactions, :replies, replies: [ :user, :reactions ])
      .order(created_at: :asc)

    return comments if current_user.board_member? || current_user.moderator? || current_user.technical_admin?

    comments.publicly_visible
  end

  def redirect_after_create
    if @thread.pending?
      redirect_to threads_path, notice: "Tu hilo fue creado y está pendiente de aprobación."
    else
      redirect_to topic_thread_path(@topic, @thread), notice: "Hilo publicado correctamente."
    end
  end
end
