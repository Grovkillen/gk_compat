# frozen_string_literal: true

module GkCompat
  # Icons the newest series has on a core link and an older one lacks. compat changes no link: it says which links
  # lack their icon in the running series and draws the icon with core's own sprite_icon, for a plugin that shows a
  # page's links as icons only. An icon the older sprite lacks comes from compat's own (assets/images/icons.svg).
  module MissingIcons
    module_function

    # rows: [[key, selector, icon, plugin or nil]] from the series' file; returns [{ 'key', 'selector', 'svg' }]
    def draw(view, rows)
      return [] unless view.respond_to?(:sprite_icon)

      rows.map do |key, selector, icon, plugin|
        svg = plugin ? view.sprite_icon(icon, plugin: plugin) : view.sprite_icon(icon)
        { 'key' => key, 'selector' => selector, 'svg' => svg.to_s }
      end
    end
  end
end
