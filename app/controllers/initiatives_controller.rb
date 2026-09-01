class InitiativesController < ApplicationController
  include ReactionHandling

  before_action :authenticate_user!
  before_action :set_initiative, only: [ :show, :react, :attach_documents, :create_comment, :react_comment, :change_status ]
  before_action :set_comment, only: [ :react_comment ]

  def index
    authorize Initiative

    @selected_commune_id = params[:commune_id]
    @selected_category = params[:category].presence
    @selected_status = selected_status_param
    @communes = Commune.in_territory
    @categories = Initiative.distinct.order(:category).pluck(:category)
    @initiatives = filtered_initiatives
  end

  def show
    authorize @initiative
    load_comments
  end

  def react
    authorize @initiative, :show?
    toggle_reaction(@initiative)
  end

  def attach_documents
    authorize @initiative, :attach_documents?

    @initiative.documents.attach(document_params[:documents])

    if @initiative.valid?
      redirect_to initiative_path(@initiative), notice: "Documento adjuntado."
    else
      load_comments
      flash.now[:alert] = @initiative.errors.full_messages.to_sentence
      render :show, status: :unprocessable_entity
    end
  end

  def create_comment
    authorize @initiative, :show?
    @comment = @initiative.comments.build(comment_params.merge(user: current_user))
    authorize @comment

    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to initiative_path(@initiative), notice: "Comentario publicado." }
      end
    else
      @comments = visible_comments
      respond_to do |format|
        format.turbo_stream { render :create_comment, status: :unprocessable_entity }
        format.html { render :show, status: :unprocessable_entity }
      end
    end
  end

  def react_comment
    authorize @initiative, :show?
    toggle_reaction(@comment)
  end

  def change_status
    authorize @initiative, :change_status?

    @initiative.status_changed_by = current_user
    @initiative.moderated_by = current_user

    if @initiative.update(status: status_param)
      redirect_to initiative_path(@initiative), notice: "Estado actualizado."
    else
      load_comments
      flash.now[:alert] = @initiative.errors.full_messages.to_sentence
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_initiative
    @initiative = Initiative
      .includes(
        :user,
        :commune,
        :reactions,
        { state_changes: :user },
        documents_attachments: :blob,
        comments: [ :user, :reactions, { replies: [ :user, :reactions ] } ]
      )
      .find(params[:id] || params[:initiative_id])
  end

  def set_comment
    @comment = @initiative.comments.find(params[:id])
  end

  def load_comments
    @comments = visible_comments
    @comment = @initiative.comments.build
    authorize @comment, :create?
  end

  def visible_comments
    comments = @initiative.comments.top_level
      .includes(:user, :reactions, :replies, replies: [ :user, :reactions ])
      .order(created_at: :asc)

    return comments if current_user.board_member? || current_user.moderator? || current_user.technical_admin?

    comments.publicly_visible
  end

  def comment_params
    params.require(:comment).permit(:body, :parent_id)
  end

  def document_params
    params.require(:initiative).permit(documents: [])
  end

  def filtered_initiatives
    Initiative
      .includes(:user, :commune, :reactions)
      .by_commune(@selected_commune_id)
      .by_category(@selected_category)
      .by_status(@selected_status)
      .recent
  end

  def selected_status_param
    return unless params[:status].present?
    return unless Initiative.statuses.key?(params[:status])

    params[:status]
  end

  def status_param
    params.require(:initiative).fetch(:status)
  end
end
