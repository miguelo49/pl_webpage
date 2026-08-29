class ThreadsController < ApplicationController
  include ReactionHandling
  include BookmarkHandling

  before_action :authenticate_user!
  before_action :set_topic, except: [ :index ]
  before_action :set_thread, only: [ :show, :edit, :update, :react, :bookmark ]

  def index
    authorize ForumThread, :index?
    @topics = Topic.ordered
    @threads = policy_scope(ForumThread)
      .includes(:user, :topic, :reactions)
      .left_joins(:comments)
      .group("threads.id")
      .select("threads.*, GREATEST(threads.created_at, COALESCE(MAX(comments.created_at), threads.created_at)) AS last_activity_at")
      .order("last_activity_at DESC")
  end

  def show
    authorize @thread
    @comments = visible_comments
    @comment = @thread.comments.build
    authorize @comment
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
