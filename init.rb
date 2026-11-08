# frozen_string_literal: true
# The one place that knows which Redmine version runs: abilities (GkCompat.can?) and shims (GkCompat.call),
# one file per supported series.
require_relative 'extensions/gk_compat/core'
require_relative 'extensions/gk_compat/backports'
require_relative 'extensions/gk_compat/icons'
require_relative 'extensions/gk_compat/instant'
require_relative 'extensions/gk_compat/oauth'
require_relative 'extensions/gk_compat/patches'
GkCompat.load_versions!

Redmine::Plugin.register :gk_compat do
  name        'GK Compat'
  author      'Jimmy Westberg'
  description 'Connects every GK plugin that needs it to Redmine in the same way, whatever the version: mends older versions backwards and tells the plugins how to behave'
  version     '1.02.000'
  requires_redmine version_or_higher: '6.0.0'

  settings default: {}, partial: 'settings/gk_compat_settings'
end

# The core patches (extensions/gk_compat/patches.rb), applied here and again on every reload
GkCompat::Patches.apply!
Redmine::Hook.add_listener(GkCompat::Hooks) unless Redmine::Hook.listeners.any?(GkCompat::Hooks)
Rails.logger.warn("[gk_compat] #{GkCompat.warning}") if GkCompat.warning
GkCompat.gaps.each { |s, g| Rails.logger.warn("[gk_compat] the file for #{s} lacks: #{g.inspect}") }
