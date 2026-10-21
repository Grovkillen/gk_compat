# frozen_string_literal: true

# Redmine 6.1: what this series can and how it does it. Remove this file when the series is no longer supported.
GkCompat.define '6.1' do
  # core draws itself with CSS variables (--oc-*), which a theme sets; without them a theme restyles fixed colours.
  # Checked on 6.1.4: no open-color.css; the only variable is --fonts-main, and application.css has 428 fixed hex
  # colours.
  can :css_variables, false

  # core asks an administrator for the password again before administrative pages (sudo mode) unless
  # configuration.yml says otherwise. It is a default, not a fact about the instance: what the instance does
  # is Redmine::SudoMode.enabled?, on every series. Checked on 6.1.4: no sudo_mode among the defaults in
  # lib/redmine/configuration.rb, and the settings pages never asked.
  can :sudo_mode_by_default, false

  # right to left: core marks the direction with dir on <html> and lays out with logical properties, so a plugin's
  # own logical properties follow by themselves. Without it core loads rtl.css for an rtl language and sets no dir,
  # and a plugin needs its own rtl overrides. Checked on 6.1.4: layouts/base.html.erb loads rtl.css when
  # l(:direction) is rtl, <html> has no dir, and application.css has no [dir="rtl"] rules.
  can :rtl_dir_attribute, false

  # icons: sprite_icon takes style: (:outline or :filled) and a theme can supply its own icons (sprite_source).
  # Without it sprite_icon has no style: keyword and passing one raises ArgumentError. Checked on 6.1.4:
  # app/helpers/icons_helper.rb has sprite_source and style::outline in sprite_icon.
  can :icon_style, true

  # icons: core's stylesheet still carries the raster icons as classes (.icon-add and the rest as background
  # images), so a link with only the class gets its icon. Without it a plugin uses sprite_icon, or imports core's
  # legacy-icons-compat.css, which core says it will remove. Checked on 6.1.4: application.css
  # has.icon-add:not(:has(svg)) { background-image: url(/add.png) } and the rest.
  can :raster_icon_classes, true

  # Locking or unlocking several accounts at once saves account by account, so the model's callbacks run.
  # Without it core writes the status with update_all and compat brings the newer code (backports.rb). Checked
  # 2026-10-01: 6.1.4 has users.update_all status: status in UsersController#bulk_update_status, 6.1.5 has
  # users.each { |user| user.update_attribute(:status, status) }.
  can :bulk_status_callbacks, since: '6.1.5'

  # icons: core links the newest series draws with an icon and this one as bare text: the subtasks' Lägg till (the newest
  # has sprite_icon('add')) and the relations' (sprite_icon('link-add'), which this sprite lacks; compat's own has it).
  # compat changes neither link; a plugin that shows a page's links as icons only asks, and gets the icon drawn with
  # core's sprite_icon (MissingIcons). Checked on 6.0.11 and 6.1.5: issues_helper.rb has link_to(l(:button_add),
  # url_for_new_subtask(issue)), issues/_relations.html.erb has toggle_link l(:button_add), 'new-relation-form', and
  # icons.svg has no icon--link-add.
  shim(:missing_icons) do |view|
    GkCompat::MissingIcons.draw(view, [['issue_add_subtask', '#issue_tree .contextual > a:not(.icon)', 'add', nil],
                                       ['issue_add_relation', '#relations .contextual > a:not(.icon)', 'link-add', :gk_compat]])
  end

  # the account: the logged-in person's account is a dropdown in the profile menu (.profile-menu > #account.dropdown with
  # a.dropdown-trigger), where account_menu's rows are drawn. Without it account_menu is a row of links in #top-menu
  # (#account) and the name stands beside it in #loggedas. Checked on 6.0.11 and 6.1.5: layouts/base.html.erb has
  # <div id="account"> with render_menu :account_menu and content_tag('div', ..., :id => 'loggedas'), and no profile-menu.
  can :account_dropdown, false

  # custom fields: the format Progress bar (Redmine::FieldFormat::ProgressbarFormat). Without it a custom field has no such
  # format, and a plugin that adds to it does nothing. Checked on 6.1.5: lib/redmine/field_format.rb has class
  # ProgressbarFormat < Numeric.
  can :progressbar_field_format, true
end
