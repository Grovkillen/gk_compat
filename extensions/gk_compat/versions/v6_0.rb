# frozen_string_literal: true

# Redmine 6.0: what this series can and how it does it. Remove this file when the series is no longer supported.
GkCompat.define '6.0' do
  # core draws itself with CSS variables (--oc-*), which a theme sets; without them a theme restyles fixed colours.
  # Checked on 6.0.11: no open-color.css; the only variable is --fonts-main, and application.css has 391 fixed hex
  # colours.
  can :css_variables, false

  # core asks an administrator for the password again before administrative pages (sudo mode) unless
  # configuration.yml says otherwise. It is a default, not a fact about the instance: what the instance does
  # is Redmine::SudoMode.enabled?, on every series. Checked on 6.0.11: no sudo_mode among the defaults in
  # lib/redmine/configuration.rb, and the settings pages never asked.
  can :sudo_mode_by_default, false

  # right to left: core marks the direction with dir on <html> and lays out with logical properties, so a plugin's
  # own logical properties follow by themselves. Without it core loads rtl.css for an rtl language and sets no dir,
  # and a plugin needs its own rtl overrides. Checked on 6.0.11: layouts/base.html.erb loads rtl.css when
  # l(:direction) is rtl, <html> has no dir, and application.css has no [dir="rtl"] rules.
  can :rtl_dir_attribute, false

  # icons: sprite_icon takes style: (:outline or :filled) and a theme can supply its own icons (sprite_source).
  # Without it sprite_icon has no style: keyword and passing one raises ArgumentError. Checked on 6.0.11:
  # app/helpers/icons_helper.rb has sprite_icon with plugin: but without style:, and no sprite_source.
  can :icon_style, false

  # icons: core's stylesheet still carries the raster icons as classes (.icon-add and the rest as background
  # images), so a link with only the class gets its icon. Without it a plugin uses sprite_icon, or imports core's
  # legacy-icons-compat.css, which core says it will remove. Checked on 6.0.11: application.css has the same raster
  # icon classes as 6.1.
  can :raster_icon_classes, true

  # Locking or unlocking several accounts at once saves account by account, so the model's callbacks run.
  # Without it core writes the status with update_all and compat brings the newer code (backports.rb). Checked on
  # 6.0.11: UsersController#bulk_update_status has users.update_all status: status. No 6.0 release with the fix
  # yet; when one comes, this becomes since: that release.
  can :bulk_status_callbacks, false

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
  # format, and a plugin that adds to it does nothing. Checked on 6.0.11: lib/redmine/field_format.rb has no class
  # ProgressbarFormat.
  can :progressbar_field_format, false

  # % done as text beside the bar in lists, with a setting for where it stands (progress_bar_text, #5284). Without it
  # core_stuff's done_ratio_text adds the text. Checked on 6.0.11: config/settings.yml has no progress_bar_text.
  can :progress_bar_text, false

  # avatars: a register of picture sources (Redmine::AvatarSources) that avatar asks before Gravatar. Without it avatar
  # knows only Gravatar (and the initials where core has them), and core_stuff's avatar_sources is the register.
  # Checked on 6.0.11: app/helpers/avatars_helper.rb has avatar(user, options) and no sources, and lib/redmine has no
  # AvatarSources.
  can :avatar_sources, false

  # tabs: a register where a plugin adds a tab to a settings page or the issue's history (Redmine::Tabs, and
  # settings_tab with its siblings on Redmine::Plugin). Without it the helpers' lists are fixed, and core_stuff's
  # settings_tabs is the register. Checked on 6.0.11: ProjectsHelper#project_settings_tabs is a fixed list, lib/redmine
  # has no tabs.rb, and lib/redmine/plugin.rb has no settings_tab.
  can :settings_tabs, false

  # history lines: a register where a plugin says how its own journal details are drawn (Redmine::JournalDetails,
  # and journal_detail on Redmine::Plugin). Without it IssuesHelper#show_detail knows only core's properties, and
  # core_stuff's journal_details is the register. Checked on 6.0.11: show_detail is a fixed case over the property,
  # lib/redmine has no journal_details.rb, and lib/redmine/plugin.rb has no journal_detail.
  can :journal_details, false

  # the layout's hooks (step 01 of view_hooks): hooks at the top and bottom of the header and footer, the top of the
  # content and the sidebar, after the page title, and around div.issue on the issue page. Without them core_stuff's
  # layout_hooks adds them. Checked on 6.0.11: layouts/base.html.erb calls view_layouts_base_html_head,
  # view_layouts_base_body_top, view_layouts_base_sidebar, view_layouts_base_content and view_layouts_base_body_bottom
  # only, and ApplicationHelper has no view_layouts_base_sidebar_top_hook_response.
  can :layout_hooks, false

  # the button row and the menus (step 04 of view_hooks): _contextual and _actions_menu hooks, and menus a plugin adds
  # items to for an issue, the issue list's context menu, a project, a user and a version. Without them core_stuff's
  # action_menus adds them. Checked on 6.0.11: lib/redmine/menu_manager.rb has no render_object_menu_items, and
  # news/index.html.erb calls no _contextual hook.
  can :action_menus, false

  # the forms (step 05 of view_hooks): hooks at the top and bottom of seven forms and after sections of the issue and
  # user forms. Without them core_stuff's form_hooks adds them. Checked on 6.0.11: projects/_form.html.erb calls no
  # view_projects_form_top.
  can :form_hooks, false

  # the lists (step 06 of view_hooks): a row's classes and content after the row in the issue, project and user lists.
  # Without them core_stuff's list_hooks adds them. Checked on 6.0.11: ApplicationHelper has no css_classes_from_hook.
  can :list_hooks, false

  # the footer: a setting that shows Redmine's version after Powered by Redmine (footer_show_version). Without it
  # core_stuff's footer_version shows it. Checked on 6.0.11: config/settings.yml has no footer_show_version.
  can :footer_version_setting, false

  # the Gantt chart as PNG with the ImageMagick that configuration.yml names: core gives MiniMagick the command's
  # folder (cli_path). Without it MiniMagick runs convert from the PATH, and core_stuff's minimagick_path gives it the
  # command. Checked on 6.0.11: the Gemfile has mini_magick ~> 5.0.1, whose configuration has cli_prefix and no
  # cli_path, and lib/redmine/helpers/gantt.rb sets cli_path only when MiniMagick responds to it.
  can :minimagick_cli_path, false

  # OAuth: applications under Administration, a token limited to its scopes. Without it there is no OAuth and every
  # API call is made with the person's own rights (API key or login). Checked on 6.0.11: no app/views/doorkeeper, no
  # doorkeeper in the Gemfile, and User has no oauth_scope.
  can :oauth2_provider, false

  # no token, so nothing to limit: what a permission covers is the caller's check alone
  shim(:scope_allows?) { |_user, _permission| true }

  # an administrator, as core says
  shim(:admin_allows?) { |user, _permission| user&.admin? ? true : false }

  # core's own condition
  shim(:project_condition) do |user, permission, options = {}, &block|
    Project.allowed_to_condition(user, permission, options, &block)
  end
end
