module NavigationHelper
  BOTTOM_NAV_ITEMS = [
    { key: :home, label: "Inicio", path_helper: :root_path, controllers: %w[home political_contexts] },
    { key: :community, label: "Foro", path_helper: :threads_path, controllers: %w[topics threads comments news initiatives law_proposals] },
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
    base = "touch-target flex flex-1 flex-col items-center justify-center gap-1 rounded-lg px-2 py-2 font-brand text-xs font-medium transition #{focus_ring_class}"

    if active
      "#{base} bg-primary/10 text-primary"
    else
      "#{base} text-gray-700 hover:bg-gray-100 hover:text-gray-900"
    end
  end

  def sidebar_link_class(active)
    base = "touch-target flex items-center gap-3 rounded-lg px-3 py-2.5 font-brand text-sm font-medium transition #{focus_ring_class}"

    if active
      "#{base} bg-primary/10 text-primary"
    else
      "#{base} text-gray-700 hover:bg-gray-100 hover:text-gray-900"
    end
  end

  def header_action_class
    "touch-target inline-flex items-center justify-center rounded-lg px-3 py-2 font-brand text-sm font-medium text-accent hover:bg-primary/5 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary"
  end

  def header_primary_action_class
    "touch-target inline-flex items-center justify-center rounded-lg bg-primary px-3 py-2 font-brand text-sm font-medium text-white hover:brightness-95 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary"
  end

  def page_heading_class(extra = nil)
    [ "font-brand text-xl font-semibold text-primary", extra ].compact.join(" ")
  end

  def page_subtitle_class
    "mt-1 text-sm text-gray-500"
  end

  def secondary_nav_class(path)
    base = "touch-target inline-flex items-center rounded-full px-3 py-2 font-brand text-sm font-medium #{focus_ring_class}"

    if current_page?(path)
      "#{base} bg-primary text-white"
    else
      "#{base} bg-white text-gray-700 ring-1 ring-gray-300 hover:bg-primary/5 hover:ring-primary/30"
    end
  end

  def filter_sticky_class
    "sticky top-14 z-20 -mx-4 space-y-3 border-b border-gray-300 bg-white/80 px-4 py-4 backdrop-blur lg:mx-0 lg:rounded-lg lg:border lg:px-4 lg:shadow-sm"
  end

  def filter_label_class
    "mb-1 block font-brand text-xs font-medium text-gray-700"
  end

  def form_label_class
    "mb-1 block font-brand text-sm font-medium text-gray-700"
  end

  def filter_input_class
    "w-full min-h-11 rounded-lg border border-gray-300 bg-white px-4 py-2.5 font-brand text-sm text-gray-900 focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/30"
  end

  def compact_input_class
    "w-full rounded-md border border-gray-300 bg-white px-3 py-2 font-brand text-sm text-gray-900 focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/30"
  end

  def checkbox_class
    "h-4 w-4 rounded border-gray-300 text-primary focus:ring-2 focus:ring-primary/30"
  end

  def primary_button_class(full_width: true)
    width = full_width ? "w-full " : ""

    "#{width}touch-target inline-flex min-h-11 items-center justify-center rounded-lg bg-primary px-4 py-2.5 font-brand text-sm font-semibold text-white hover:brightness-95 #{focus_ring_class}"
  end

  def secondary_button_class(full_width: false)
    width = full_width ? "w-full " : ""

    "#{width}touch-target inline-flex min-h-11 items-center justify-center rounded-lg border border-gray-300 bg-white px-4 py-2.5 font-brand text-sm font-semibold text-gray-800 hover:border-secondary hover:bg-secondary/5 hover:text-accent #{focus_ring_class}"
  end

  def danger_button_class(full_width: false)
    width = full_width ? "w-full " : ""

    "#{width}touch-target inline-flex min-h-11 items-center justify-center rounded-lg border border-red-300 bg-red-50 px-4 py-2.5 font-brand text-sm font-semibold text-red-800 hover:bg-red-100 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-red-700"
  end

  def disabled_button_class
    "touch-target inline-flex w-full min-h-11 cursor-not-allowed items-center justify-center rounded-lg bg-gray-200 px-4 py-2.5 font-brand text-sm font-semibold text-gray-600"
  end

  def action_link_class
    primary_button_class(full_width: false) + " shrink-0 px-3 py-2"
  end

  def card_link_class
    "block rounded-lg border border-gray-200 bg-white p-4 font-brand shadow-sm transition hover:border-primary/30 hover:shadow-md #{focus_ring_class}"
  end

  def list_card_link_class
    "flex gap-3 rounded-lg border border-gray-200 bg-white p-3 font-brand shadow-sm transition hover:border-primary/30 hover:shadow-md #{focus_ring_class}"
  end

  def card_title_class
    "font-brand text-base font-semibold text-gray-900"
  end

  def card_meta_class
    "text-xs text-gray-500"
  end

  def category_chip_class(size: :default)
    size_class = size == :sm ? "text-[10px]" : "text-xs"

    "rounded-full bg-primary/10 px-2 py-0.5 #{size_class} font-medium text-primary"
  end

  def date_badge_class
    "flex shrink-0 flex-col items-center justify-center rounded-lg bg-secondary/15 font-brand text-secondary"
  end

  def card_hover_class
    "hover:bg-primary/5"
  end

  def text_link_class
    "inline-flex items-center rounded font-brand text-sm font-medium text-accent underline-offset-2 hover:text-primary hover:underline #{focus_ring_class}"
  end

  def chip_filter_class(active:)
    base = "touch-target inline-flex shrink-0 items-center rounded-full border px-3 py-2 font-brand text-xs font-medium #{focus_ring_class}"

    if active
      "#{base} border-primary/30 bg-primary/10 text-primary"
    else
      "#{base} border-gray-300 bg-white text-gray-700 hover:border-primary/30 hover:text-primary"
    end
  end

  def error_alert_class
    "rounded-lg border border-red-300 bg-red-50 px-4 py-2.5 text-sm text-red-900"
  end

  def flash_notice_class
    "rounded-lg border border-green-300 bg-green-50 px-4 py-2.5 text-sm text-green-900"
  end

  def flash_warning_class
    "rounded-lg border border-amber-200 bg-amber-50 px-4 py-2.5 text-sm text-amber-800"
  end

  def flash_alert_class
    "rounded-lg border border-red-300 bg-red-50 px-4 py-2.5 text-sm text-red-900"
  end

  def discussion_post_class
    "rounded-md border border-gray-200 bg-white font-brand shadow-sm"
  end

  def discussion_comment_class
    "rounded-md border border-gray-200 bg-white font-brand"
  end

  def discussion_reply_class
    "rounded-md border border-gray-100 bg-gray-50/80 font-brand"
  end

  def discussion_feed_item_class
    "flex gap-2 rounded-md border border-gray-200 bg-white font-brand shadow-sm transition hover:border-primary/20 hover:shadow-md"
  end

  def discussion_action_class
    "touch-target inline-flex items-center rounded px-2 py-1 font-brand text-xs font-semibold text-gray-500 hover:bg-gray-100 hover:text-primary #{focus_ring_class}"
  end

  def discussion_section_class
    "rounded-lg bg-gray-50/50 p-4"
  end

  def file_input_class
    "block w-full font-brand text-sm text-gray-700 file:mr-3 file:rounded-lg file:border-0 file:bg-primary/10 file:px-3 file:py-2 file:font-brand file:text-sm file:font-semibold file:text-primary hover:file:bg-primary/15"
  end

  def focus_ring_class
    "focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary"
  end

  def pill_button_class(active:, active_style: :primary)
    base = "touch-target inline-flex min-h-11 items-center gap-1.5 rounded-full border px-4 py-2 font-brand text-xs font-medium transition #{focus_ring_class}"
    active_styles = {
      primary: "border-primary/30 bg-primary/10 text-primary",
      secondary: "border-secondary/40 bg-secondary/10 text-accent",
      success: "border-green-300 bg-green-50 text-green-900"
    }
    inactive = "border-gray-300 bg-white text-gray-800 hover:border-primary/30 hover:text-primary"

    active ? "#{base} #{active_styles.fetch(active_style)}" : "#{base} #{inactive}"
  end

  def nav_icon_class(active)
    active ? "bg-primary text-white" : "bg-gray-200 text-gray-700"
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
