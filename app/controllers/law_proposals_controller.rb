class LawProposalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_law_proposal, only: [ :show ]

  def index
    authorize LawProposal

    @selected_commune_id = params[:commune_id]
    @selected_category = params[:category].presence
    @selected_status = selected_status_param
    @communes = Commune.in_territory
    @categories = LawProposal.distinct.order(:category).pluck(:category)
    @law_proposals = filtered_law_proposals
  end

  def show
    authorize @law_proposal
    load_version_context
  end

  private

  def set_law_proposal
    @law_proposal = LawProposal
      .includes(:user, :commune, versions: :user)
      .find(params[:id])
  end

  def load_version_context
    @versions = @law_proposal.versions.order(created_at: :desc)
    @selected_version = @versions.find_by(id: params[:version_id]) if params[:version_id].present?
    @viewing_historical_version = @selected_version.present?
    @displayed_text = @selected_version&.text || @law_proposal.current_text
  end

  def filtered_law_proposals
    LawProposal
      .includes(:user, :commune)
      .by_commune(@selected_commune_id)
      .by_category(@selected_category)
      .by_status(@selected_status)
      .recent
  end

  def selected_status_param
    return unless params[:status].present?
    return unless LawProposal.statuses.key?(params[:status])

    params[:status]
  end
end
