module NewsHelper
  CATEGORY_LABELS = {
    "party" => "Partido",
    "regional" => "Regional",
    "national" => "Nacional",
    "legislative" => "Legislativo",
    "analysis" => "Análisis",
    "statement" => "Declaración",
    "activity" => "Actividad"
  }.freeze

  def news_category_label(category)
    CATEGORY_LABELS.fetch(category.to_s, category.to_s.humanize)
  end
end
