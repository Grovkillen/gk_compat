# frozen_string_literal: true

# Redmine 7.0: what this series can and how it does it. Remove this file when the series is no longer supported.
GkCompat.define '7.0' do
  # core draws itself with CSS variables (--oc-*), which a theme sets; without them a theme restyles fixed colours.
  # Checked on 7.0.1: application.css imports open-color.css, which defines 264 --oc-* variables on:root;
  # application.css uses 61 of them in 349 places and has 73 fixed hex colours left. Setting --oc-gray-9 on:root
  # recolours the body text in the running instance.
  can :css_variables, true

  # core asks an administrator for the password again before administrative pages (sudo mode) unless
  # configuration.yml says otherwise. It is a default, not a fact about the instance: what the instance does is
  # Redmine::SudoMode.enabled?, on every series. Checked on 7.0.1: lib/redmine/configuration.rb has 'sudo_mode'
  # => true among the defaults, and the settings pages answered with the password form once the login was older
  # than the timeout (15 minutes).
  can :sudo_mode_by_default, true

  # right to left: core marks the direction with dir on <html> and lays out with logical properties, so a plugin's
  # own logical properties follow by themselves. Without it core loads rtl.css for an rtl language and sets no dir,
  # and a plugin needs its own rtl overrides. Checked on 7.0.1: layouts/base.html.erb has dir="<%= l(:direction)
  # %>" on <html>, there is no rtl.css, and application.css has 15 [dir="rtl"] rules.
  can :rtl_dir_attribute, true

  # icons: sprite_icon takes style: (:outline or :filled) and a theme can supply its own icons (sprite_source).
  # Without it sprite_icon has no style: keyword and passing one raises ArgumentError. Checked on 7.0.1:
  # app/helpers/icons_helper.rb has sprite_source and style::outline in sprite_icon.
  can :icon_style, true

  # icons: core's stylesheet still carries the raster icons as classes (.icon-add and the rest as background
  # images), so a link with only the class gets its icon. Without it a plugin uses sprite_icon, or imports core's
  # legacy-icons-compat.css, which core says it will remove. Checked on 7.0.1: application.css has no.icon-*
  # background images; legacy-icons-compat.css has 98 of them and is not loaded by the layout.
  can :raster_icon_classes, false

  # Locking or unlocking several accounts at once saves account by account, so the model's callbacks run.
  # Without it core writes the status with update_all and compat brings the newer code (backports.rb). Checked
  # 2026-10-01: 7.0.1 has users.update_all status: status in UsersController#bulk_update_status, 7.0.2 has
  # users.each { |user| user.update_attribute(:status, status) }.
  can :bulk_status_callbacks, since: '7.0.2'

  # icons: core links the newest series draws with an icon and an older one as bare text; none here. Checked on 7.0.2:
  # the subtasks' and the relations' Lägg till have sprite_icon('add') and sprite_icon('link-add') with their classes.
  shim(:missing_icons) { |_view| [] }

  # the account: the logged-in person's account is a dropdown in the profile menu (.profile-menu > #account.dropdown with
  # a.dropdown-trigger), where account_menu's rows are drawn. Without it account_menu is a row of links in #top-menu
  # (#account) and the name stands beside it in #loggedas. Checked on 7.0.2: layouts/base.html.erb has
  # <div class="profile-menu"> with <div id="account" class="dropdown"> and <a class="dropdown-trigger">, and no loggedas.
  can :account_dropdown, true

  # custom fields: the format Progress bar (Redmine::FieldFormat::ProgressbarFormat). Without it a custom field has no such
  # format, and a plugin that adds to it does nothing. Checked on 7.0.2: lib/redmine/field_format.rb has class
  # ProgressbarFormat < Numeric.
  can :progressbar_field_format, true
end
