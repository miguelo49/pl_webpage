class ThreadsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_topic
  before_action :set_thread, only: [ :show, :edit, :update ]

  def index
    authorize ForumThread, :index?
    @threads = policy_scope(ForumThread)
      .where(topic: @topic)
      .includes(:user)
      .order(created_at: :desc)
    @thread = @topic.threads.build
  end

  def show
    authorize @thread
    @comments = visible_comments
    @comment = @thread.comments.build
    authorize @comment
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
    @thread = @topic.threads.find(params[:id])
  end

  def thread_params
    params.require(:forum_thread).permit(:title, :body)
  end

  def visible_comments
    comments = @thread.comments.top_level.includes(:user, :replies, replies: :user).order(created_at: :asc)

    return comments if current_user.board_member? || current_user.moderator? || current_user.technical_admin?

    comments.publicly_visible
  end

  def redirect_after_create
    if @thread.pending?
      redirect_to topic_threads_path(@topic), notice: "Tu hilo fue creado y está pendiente de aprobación."
    else
      redirect_to topic_thread_path(@topic, @thread), notice: "Hilo publicado correctamente."
    end
  end
end
