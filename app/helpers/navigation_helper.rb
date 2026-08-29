module NavigationHelper
  BOTTOM_NAV_ITEMS = [
    { key: :home, label: "Inicio", path_helper: :root_path, controllers: %w[home political_contexts] },
    { key: :community, label: "Comunidad", path_helper: :topics_path, controllers: %w[topics threads comments news initiatives law_proposals] },
    { key: :events, label: "Eventos", path_helper: :events_path, controllers: %w[events attendances] },
    { key: :training, label: "Formación", path_helper: :training_materials_path, controllers: %w[training_materials] },
    { key: :profile, label: "Perfil", path_helper: :profile_path, controllers: %w[profiles], signed_in_only: true, signed_out_path_helper: :new_user_session_path }
  ].freeze

  def hide_bottom_nav?
    controller_name.in?(%w[onboardings]) || controller_path.start_with?("admin/", "moderation/")
  end

  def show_app_shell?
    !hide_bottom_nav?
  end

  def listing_grid_class(columns: 3)
    base = "grid grid-cols-1 gap-3 lg:gap-4"

    case columns
    when 2
      "#{base} lg:grid-cols-2"
    when 4
      "#{base} sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4"
    else
      "#{base} lg:grid-cols-2 xl:grid-cols-3"
    end
  end

  def bottom_nav_active?(item)
    if item[:key] == :home
      return current_page?(root_path) || controller_name.in?(item[:controllers])
    end

    controller_name.in?(item[:controllers])
  end

  def bottom_nav_path(item)
    if item[:signed_in_only] && !user_signed_in?
      send(item[:signed_out_path_helper])
    else
      send(item[:path_helper])
    end
  end

  def bottom_nav_link_class(active)
    base = "touch-target flex flex-1 flex-col items-center justify-center gap-1 rounded-lg px-2 py-2 text-xs font-medium transition focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700"

    if active
      "#{base} bg-blue-50 text-blue-800"
    else
      "#{base} text-gray-700 hover:bg-gray-100 hover:text-gray-900"
    end
  end

  def sidebar_link_class(active)
    base = "touch-target flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700"

    if active
      "#{base} bg-blue-50 text-blue-800"
    else
      "#{base} text-gray-700 hover:bg-gray-100 hover:text-gray-900"
    end
  end

  def header_action_class
    "touch-target inline-flex items-center justify-center rounded-lg px-3 py-2 text-sm font-medium text-blue-800 hover:bg-blue-50 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700"
  end

  def header_primary_action_class
    "touch-target inline-flex items-center justify-center rounded-lg bg-blue-700 px-3 py-2 text-sm font-medium text-white hover:bg-blue-800 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700"
  end

  def page_heading_class(extra = nil)
    [ "font-brand text-xl font-semibold text-primary", extra ].compact.join(" ")
  end

  def page_subtitle_class
    "mt-1 text-sm text-gray-500"
  end

  def secondary_nav_class(path)
    base = "touch-target inline-flex items-center rounded-full px-3 py-2 text-sm font-medium focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700"

    if current_page?(path)
      "#{base} bg-blue-700 text-white"
    else
      "#{base} bg-white text-gray-700 ring-1 ring-gray-300 hover:bg-gray-50"
    end
  end

  def filter_sticky_class
    "sticky top-14 z-20 -mx-4 space-y-3 border-b border-gray-300 bg-gray-50/95 px-4 pb-4 backdrop-blur lg:mx-0 lg:rounded-lg lg:border lg:px-4 lg:shadow-sm"
  end

  def filter_label_class
    "mb-1 block text-xs font-medium text-gray-700"
  end

  def filter_input_class
    "w-full min-h-11 rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm text-gray-900 focus:border-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-700"
  end

  def primary_button_class(full_width: true)
    width = full_width ? "w-full " : ""

    "#{width}touch-target inline-flex min-h-11 items-center justify-center rounded-lg bg-blue-700 px-4 py-2.5 text-sm font-semibold text-white hover:bg-blue-800 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700"
  end

  def secondary_button_class(full_width: false)
    width = full_width ? "w-full " : ""

    "#{width}touch-target inline-flex min-h-11 items-center justify-center rounded-lg border border-gray-300 bg-white px-4 py-2.5 text-sm font-semibold text-gray-800 hover:border-blue-300 hover:bg-gray-50 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700"
  end

  def danger_button_class(full_width: false)
    width = full_width ? "w-full " : ""

    "#{width}touch-target inline-flex min-h-11 items-center justify-center rounded-lg border border-red-300 bg-red-50 px-4 py-2.5 text-sm font-semibold text-red-800 hover:bg-red-100 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-red-700"
  end

  def disabled_button_class
    "touch-target inline-flex w-full min-h-11 cursor-not-allowed items-center justify-center rounded-lg bg-gray-200 px-4 py-2.5 text-sm font-semibold text-gray-600"
  end

  def action_link_class
    primary_button_class(full_width: false) + " shrink-0 px-3 py-2"
  end

  def card_link_class
    "block rounded-lg border border-gray-200 bg-white p-4 shadow-sm transition hover:border-blue-200 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700"
  end

  def list_card_link_class
    "flex gap-3 rounded-lg border border-gray-200 bg-white p-3 shadow-sm transition hover:border-blue-200 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700"
  end

  def text_link_class
    "inline-flex items-center rounded text-sm font-medium text-blue-800 underline-offset-2 hover:text-blue-900 hover:underline focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700"
  end

  def chip_filter_class(active:)
    base = "touch-target inline-flex shrink-0 items-center rounded-full border px-3 py-2 text-xs font-medium focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700"

    if active
      "#{base} border-blue-300 bg-blue-50 text-blue-900"
    else
      "#{base} border-gray-300 bg-white text-gray-700 hover:border-blue-300"
    end
  end

  def error_alert_class
    "rounded-lg border border-red-300 bg-red-50 px-4 py-3 text-sm text-red-900"
  end

  def file_input_class
    "block w-full text-sm text-gray-700 file:mr-3 file:rounded-lg file:border-0 file:bg-blue-50 file:px-3 file:py-2 file:text-sm file:font-semibold file:text-blue-800 hover:file:bg-blue-100"
  end

  def bottom_nav_icon(key)
    case key
    when :home
      nav_svg("M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8h5z")
    when :community
      nav_svg("M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2z")
    when :events
      nav_svg("M19 4h-1V2h-2v2H8V2H6v2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 16H5V10h14v10z")
    when :training
      nav_svg("M18 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zM6 4h5v8l-2.5-1.5L6 12V4z")
    when :profile
      nav_svg("M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z")
    end
  end

  private

  def nav_svg(path_data)
    tag.svg(viewBox: "0 0 24 24", fill: "currentColor", class: "h-4 w-4", aria: { hidden: true }) do
      tag.path(d: path_data)
    end
  end
end
