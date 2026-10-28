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

  # % done as text beside the bar in lists, with a setting for where it stands (progress_bar_text, #5284). Without it
  # core_stuff's done_ratio_text adds the text. Checked on 7.0.2: config/settings.yml has no progress_bar_text.
  can :progress_bar_text, false

  # avatars: a register of picture sources (Redmine::AvatarSources) that avatar asks before Gravatar. Without it avatar
  # knows only Gravatar (and the initials where core has them), and core_stuff's avatar_sources is the register.
  # Checked on 7.0.2: app/helpers/avatars_helper.rb has avatar(user, options) and no sources, and lib/redmine has no
  # AvatarSources.
  can :avatar_sources, false

  # tabs: a register where a plugin adds a tab to a settings page or the issue's history (Redmine::Tabs, and
  # settings_tab with its siblings on Redmine::Plugin). Without it the helpers' lists are fixed, and core_stuff's
  # settings_tabs is the register. Checked on 7.0.2: ProjectsHelper#project_settings_tabs is a fixed list, lib/redmine
  # has no tabs.rb, and lib/redmine/plugin.rb has no settings_tab.
  can :settings_tabs, false

  # history lines: a register where a plugin says how its own journal details are drawn (Redmine::JournalDetails,
  # and journal_detail on Redmine::Plugin). Without it IssuesHelper#show_detail knows only core's properties, and
  # core_stuff's journal_details is the register. Checked on 7.0.2: show_detail is a fixed case over the property,
  # lib/redmine has no journal_details.rb, and lib/redmine/plugin.rb has no journal_detail.
  can :journal_details, false

  # the layout's hooks (step 01 of view_hooks): hooks at the top and bottom of the header and footer, the top of the
  # content and the sidebar, after the page title, and around div.issue on the issue page. Without them core_stuff's
  # layout_hooks adds them. Checked on 7.0.2: layouts/base.html.erb calls view_layouts_base_html_head,
  # view_layouts_base_body_top, view_layouts_base_sidebar, view_layouts_base_content and view_layouts_base_body_bottom
  # only, and ApplicationHelper has no view_layouts_base_sidebar_top_hook_response.
  can :layout_hooks, false

  # the button row and the menus (step 04 of view_hooks): _contextual and _actions_menu hooks, and menus a plugin adds
  # items to for an issue, the issue list's context menu, a project, a user and a version. Without them core_stuff's
  # action_menus adds them. Checked on 7.0.2: lib/redmine/menu_manager.rb has no render_object_menu_items, and
  # news/index.html.erb calls no _contextual hook.
  can :action_menus, false

  # the forms (step 05 of view_hooks): hooks at the top and bottom of seven forms and after sections of the issue and
  # user forms. Without them core_stuff's form_hooks adds them. Checked on 7.0.2: projects/_form.html.erb calls no
  # view_projects_form_top.
  can :form_hooks, false

  # the lists (step 06 of view_hooks): a row's classes and content after the row in the issue, project and user lists.
  # Without them core_stuff's list_hooks adds them. Checked on 7.0.2: ApplicationHelper has no css_classes_from_hook.
  can :list_hooks, false

  # the footer: a setting that shows Redmine's version after Powered by Redmine (footer_show_version). Without it
  # core_stuff's footer_version shows it. Checked on 7.0.2: config/settings.yml has no footer_show_version.
  can :footer_version_setting, false

  # the Gantt chart as PNG with the ImageMagick that configuration.yml names: core gives MiniMagick the command's
  # folder (cli_path). Without it MiniMagick runs convert from the PATH, and core_stuff's minimagick_path gives it the
  # command. Checked on 7.0.2: the Gemfile has mini_magick ~> 5.2.0, whose configuration has cli_prefix and no
  # cli_path, and lib/redmine/helpers/gantt.rb sets cli_path only when MiniMagick responds to it.
  can :minimagick_cli_path, false

  # OAuth: applications under Administration, a token limited to its scopes (the permissions' names and :admin).
  # Without it there is no OAuth and every API call is made with the person's own rights. Checked on 7.0.2:
  # app/views/doorkeeper/applications/_form.html.erb lists the permissions as scopes, ApplicationController#
  # find_current_user sets user.oauth_scope from the token, User#allowed_to? passes it to Role#allowed_to?, and
  # Project.allowed_to_condition does not (OAuthScope in oauth.rb).
  can :oauth2_provider, true

  # whether the token lets the person use what a permission covers (always true without a token); who may is still
  # the caller's check
  shim(:scope_allows?) { |user, permission| GkCompat::OAuthScope.allows?(user, permission) }

  # an administrator whose token, if any, has the permission or :admin (an administrative API narrowed to one scope)
  shim(:admin_allows?) { |user, permission| GkCompat::OAuthScope.admin_allows?(user, permission) }

  # Project.allowed_to_condition with the token's scopes
  shim(:project_condition) do |user, permission, options = {}, &block|
    GkCompat::OAuthScope.project_condition(user, permission, options, &block)
  end
end
