class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_topic
  before_action :set_thread

  def create
    @comment = @thread.comments.build(comment_params.merge(user: current_user))
    authorize @comment

    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to topic_thread_path(@topic, @thread), notice: "Comentario publicado." }
      end
    else
      @comments = visible_comments
      respond_to do |format|
        format.turbo_stream { render :create, status: :unprocessable_entity }
        format.html { render "threads/show", status: :unprocessable_entity }
      end
    end
  end

  private

  def set_topic
    @topic = Topic.find(params[:topic_id])
  end

  def set_thread
    @thread = @topic.threads.find(params[:thread_id])
    authorize @thread, :show?
  end

  def comment_params
    params.require(:comment).permit(:body, :parent_id)
  end

  def visible_comments
    comments = @thread.comments.top_level.includes(:user, :replies, replies: :user).order(created_at: :asc)

    return comments if current_user.board_member? || current_user.moderator? || current_user.technical_admin?

    comments.publicly_visible
  end
end
