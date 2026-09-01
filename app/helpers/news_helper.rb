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

  def news_chip_class(size: :default)
    size_class = size == :sm ? "text-[10px]" : "text-xs"

    "rounded-full bg-accent/10 px-2 py-0.5 #{size_class} font-medium text-accent"
  end
end
