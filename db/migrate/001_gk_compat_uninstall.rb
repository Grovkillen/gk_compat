# frozen_string_literal: true

# compat has no tables of its own; this first migration is where uninstalling it takes away what it kept in core's
# tables: its row in settings (compat keeps no keys in the users' preferences). Its down runs last at
# redmine:plugins:migrate NAME=gk_compat VERSION=0.
class GkCompatUninstall < ActiveRecord::Migration[6.1]
  def up
    # nothing to make: the settings row is core's own, made when the settings are first saved
  end

  def down
    Setting.where(name: 'plugin_gk_compat').delete_all
  end
end
