# frozen_string_literal: true

# GkCompat::Instant: an instant with its zone, one type for every GK plugin's own time columns.
# Redmine writes times as the server's local time without an offset (default_timezone local); into a timestamptz
# column the database would then read them in its own session's zone, which need not be the server's. This type
# writes every instant in UTC with the offset written out, so what is kept never depends on a zone, and reads the
# offset the database sends back.
#
#   GkCompat::Instant.attributes!(self, :created_at, :closed_at)   in a model: these columns use the type
#   GkCompat::Instant.text(time)                                   the same text for a time compared in SQL
#
# Loaded from init.rb with require_relative, outside every autoload path, so the constant is never reloaded and is
# there before any model of another plugin is loaded (models load lazily, after every plugin's init.rb has run).
# A model that uses it must not be touched from a plugin's init.rb while plugins are still loading.
module GkCompat
  class Instant < ActiveRecord::Type::DateTime
    def serialize(value)
      v = super
      v.respond_to?(:utc) ? self.class.text(v) : v
    end

    # "2025-10-25 23:30:00.000000+00:00": for a model's attribute and for a time compared in SQL
    # (getutc, not utc: utc would turn the caller's Time itself into UTC)
    def self.text(time) = time.getutc.strftime('%Y-%m-%d %H:%M:%S.%6N+00:00')

    # The plugin's own time columns, per model
    def self.attributes!(model, *names) = names.each { |n| model.attribute(n, new) }
  end
end
