# frozen_string_literal: true

# gk_compat: the one place that knows which Redmine version is running. Every other plugin asks for an ability
# or calls a shim, never for a version number: GkCompat.can?(:css_variables) does this Redmine have the
# ability?
#   GkCompat.call(:name, *args)        a shim: the same answer on every version, done each version's way
#   GkCompat.series                    '7.0' (for showing, never for deciding)
# What differs lives in one file per supported series (versions/v6_0.rb, v6_1.rb, v7_0.rb). When a series is
# no longer supported its file is removed and nothing else changes. Version checks exist only in this plugin.
#
# The rule: the newest supported Redmine decides which technique the plugins use. An older way is given up for
# the newer one, and what an older series then lacks is put right here, in compat, never in the plugins.
#
# A version file:
#   GkCompat.define '7.0' do
#     can :css_variables, true
#     can :bulk_status_callbacks, since: '7.0.2'   # from that release in the series on
#     shim(:name) { |arg| ... }
#   end
# A difference that came within a series (a fix in 6.1.5) is stated with since: the release it came in; an
# ability is then yes from that release on.
#
# Backports (backports.rb): where the newest core fixed something an older one still does wrong and the
# plugins depend on it, compat brings the fix to the older release, guarded by the ability. Removed with the
# version file.
# Every file states every ability and every shim (GkCompat.gaps lists what one lacks), so a question has an
# answer on every series. An ability or shim nobody declared is a spelling mistake and raises.
#
# A Redmine series without a file (7.1 when it comes) runs on the nearest older file, with a warning in the log
# and on the administration pages. Older than every file: the oldest, same warning.
module GkCompat
  class Unknown < KeyError; end

  Version = Struct.new(:series, :abilities, :shims)

  class Builder
    def initialize(version) = @v = version
    def can(name, yes = nil, since: nil)
      @v.abilities[name.to_sym] = since ? since.to_s : (yes ? true : false)
    end
    def shim(name, &block) = @v.shims[name.to_sym] = block
  end

  module_function

  def versions = (@versions ||= {})

  def define(series, &block)
    v = Version.new(series.to_s, {}, {})
    Builder.new(v).instance_eval(&block)
    versions[v.series] = v
  end

  def key(series) = series.to_s.split('.').first(2).map(&:to_i)

  # The running Redmine's series: major.minor
  def series = "#{Redmine::VERSION::MAJOR}.#{Redmine::VERSION::MINOR}"

  # The running release: major.minor.tiny (for since:, never for deciding anywhere else)
  def release = "#{series}.#{Redmine::VERSION::TINY}"

  def supported = versions.keys.sort_by { |s| key(s) }
  def known? = versions.key?(series)

  # The file this instance runs on: its own, else the nearest older, else the oldest there is
  def used
    return versions[series] if known?

    older = supported.select { |s| (key(s) <=> key(series)) == -1 }
    versions[older.last || supported.first] or raise Unknown, 'gk_compat has no version file at all'
  end

  def can?(name)
    a = used.abilities
    raise Unknown, "gk_compat: no ability #{name.inspect} (declared: #{abilities.join(', ')})" unless a.key?(name.to_sym) || abilities.include?(name.to_sym)

    v = a[name.to_sym]
    v.is_a?(String) ? since?(v) : v == true
  end

  # Is the running release this one or later? A series that runs on another series' file (unknown, newer) counts
  # as later than everything in it.
  def since?(rel)
    return (key(series) <=> key(rel)) == 1 unless known?

    (Gem::Version.new(release) <=> Gem::Version.new(rel)) >= 0
  end

  def call(name, *args, **opts, &block)
    s = used.shims[name.to_sym] or raise Unknown, "gk_compat: no shim #{name.inspect} for #{used.series}"
    s.call(*args, **opts, &block)
  end

  def abilities = versions.values.flat_map { |v| v.abilities.keys }.uniq.sort
  def shims = versions.values.flat_map { |v| v.shims.keys }.uniq.sort

  # What some version file lacks: { '6.0' => { abilities: [...], shims: [...] } }; empty when all is stated
  def gaps
    versions.values.each_with_object({}) do |v, h|
      a = abilities - v.abilities.keys
      s = shims - v.shims.keys
      h[v.series] = { abilities: a, shims: s } if a.any? || s.any?
    end
  end

  # Does compat put core's colour variables (--oc-*) in place itself? Yes where core does not draw with them:
  # the plugins write their stylesheets once, for the newest core, and compat supplies what an older core
  # lacks. The values are Open Color's, the same file core carries from 7.0
  # (assets/stylesheets/gk_compat_open_color.css). When no supported series needs it the file is removed.
  def fills_css_variables? = !can?(:css_variables)

  # nil when all is well, else the words for the warning
  def warning
    return nil if known?

    "Redmine #{series} has no file in gk_compat; running on the one for #{used.series} (supported: #{supported.join(', ')})"
  end

  def load_versions!
    @versions = {}
    Dir[File.join(__dir__, 'versions', 'v*.rb')].sort.each { |f| load f }
    versions
  end

  if defined?(Redmine::Hook::ViewListener)
    # The warning on the administration pages, for administrators only
    class Hooks < Redmine::Hook::ViewListener
      # core's colour variables on every page, the login page too, where core lacks them
      def view_layouts_base_html_head(_context = {})
        return '' unless GkCompat.fills_css_variables?

        # and core's elements drawn with them under html.gk-core-vars, which only a GK plugin sets (tools/core_vars.rb)
        stylesheet_link_tag('gk_compat_open_color', plugin: 'gk_compat') + stylesheet_link_tag('gk_compat_core_vars', plugin: 'gk_compat')
      rescue StandardError => e
        Rails.logger.error("[gk_compat] colour variables not loaded: #{e.class}: #{e.message}")
        ''
      end

      def view_layouts_base_content(context = {})
        c = context[:controller]
        return '' unless c && User.current.admin? && c.class.name.to_s.match?(/\A(Admin|Settings)Controller\z/) && GkCompat.warning

        content_tag('div', l(:text_gk_compat_unknown, series: GkCompat.series, used: GkCompat.used.series, supported: GkCompat.supported.join(', ')),
                    class: 'warning', id: 'gk-compat-warning')
      rescue StandardError => e
        Rails.logger.error("[gk_compat] warning not shown: #{e.class}: #{e.message}")
        ''
      end
    end
  end
end
