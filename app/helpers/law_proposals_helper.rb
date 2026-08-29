module LawProposalsHelper
  STATUS_LABELS = {
    "idea" => "Idea",
    "discussion" => "Discusión",
    "collaborative_development" => "Desarrollo colaborativo",
    "review" => "Revisión",
    "consolidated_proposal" => "Propuesta consolidada",
    "political_review" => "Revisión política",
    "result" => "Resultado"
  }.freeze

  STATUS_BADGE_VARIANTS = {
    "idea" => :neutral,
    "discussion" => :pending,
    "collaborative_development" => :progress,
    "review" => :pending,
    "consolidated_proposal" => :info,
    "political_review" => :pending,
    "result" => :approved
  }.freeze

  def law_proposal_status_label(status)
    STATUS_LABELS.fetch(status.to_s, status.to_s.humanize)
  end

  def law_proposal_status_badge_class(status)
    status_badge_class(STATUS_BADGE_VARIANTS.fetch(status.to_s, :neutral))
  end

  def law_proposal_status_flow_items(law_proposal)
    current_index = LawProposal.statuses[law_proposal.status]

    LawProposal.statuses.keys.each_with_index.map do |status, index|
      dot_fill_class = nil

      if index < current_index
        dot_class = "border-green-500"
        title_class = "text-gray-700"
        meta = "Completado"
      elsif index == current_index
        dot_class = "border-primary"
        dot_fill_class = "bg-primary"
        title_class = "text-gray-900"
        meta = "Estado actual"
      else
        dot_class = "border-gray-300"
        title_class = "text-gray-400"
        meta = nil
      end

      {
        title: law_proposal_status_label(status),
        meta: meta,
        dot_class: dot_class,
        dot_fill_class: dot_fill_class,
        title_class: title_class
      }.compact
    end
  end

  def law_proposal_version_options(law_proposal, versions)
    options = [ [ "Texto actual (vigente)", "" ] ]
    options + versions.map do |version|
      [
        "Versión del #{version.created_at.to_fs(:short)} — #{version.user.first_name}",
        version.id
      ]
    end
  end
end
