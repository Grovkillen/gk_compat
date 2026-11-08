# frozen_string_literal: true

# Redmine 7.0: what this series can and how it does it. Remove this file when the series is no longer supported.
GkCompat.define '7.0' do
  # core draws itself with CSS variables (--oc-*), which a theme sets; without them a theme restyles fixed colours.
  # Checked on 7.0.3: application.css imports open-color.css, which defines 264 --oc-* variables on :root;
  # application.css uses 59 of them in 342 places and has 74 fixed hex colours left (counted as in 7.0.1, which has
  # the same 59 and 342 and 73 hex colours). In a 7.0.1 instance, setting --oc-gray-9 on :root recoloured the body text.
  can :css_variables, true

  # core asks an administrator for the password again before administrative pages (sudo mode) unless
  # configuration.yml says otherwise. It is a default, not a fact about the instance: what the instance does is
  # Redmine::SudoMode.enabled?, on every series. Checked on 7.0.1 and 7.0.3: lib/redmine/configuration.rb has
  # 'sudo_mode' => true among the defaults; in a 7.0.1 instance the settings pages answered with the password form
  # once the login was older than the timeout (15 minutes).
  can :sudo_mode_by_default, true

  # right to left: core marks the direction with dir on <html> and lays out with logical properties, so a plugin's
  # own logical properties follow by themselves. Without it core loads rtl.css for an rtl language and sets no dir,
  # and a plugin needs its own rtl overrides. Checked on 7.0.1 and 7.0.3: layouts/base.html.erb has dir="<%= l(:direction)
  # %>" on <html>, there is no rtl.css, and application.css has 15 [dir="rtl"] rules.
  can :rtl_dir_attribute, true

  # icons: sprite_icon takes style: (:outline or :filled) and a theme can supply its own icons (sprite_source).
  # Without it sprite_icon has no style: keyword and passing one raises ArgumentError. Checked on 7.0.1 and 7.0.3:
  # app/helpers/icons_helper.rb has sprite_source and style: :outline in sprite_icon.
  can :icon_style, true

  # icons: core's stylesheet still carries the raster icons as classes (.icon-add and the rest as background
  # images), so a link with only the class gets its icon. Without it a plugin uses sprite_icon, or imports core's
  # legacy-icons-compat.css, which core says it will remove. Checked on 7.0.1 and 7.0.3: application.css has
  # no .icon-* background images (only one rule that removes it for .icon-attachment in the attachment fields);
  # legacy-icons-compat.css has them (96 .icon-* rules) and the layout does not load it.
  can :raster_icon_classes, false

  # Locking or unlocking several accounts at once saves account by account, so the model's callbacks run.
  # Without it core writes the status with update_all and compat brings the newer code (backports.rb). Checked
  # on 7.0.1, 7.0.2 and 7.0.3: 7.0.1 has users.update_all status: status in UsersController#bulk_update_status,
  # 7.0.2 and 7.0.3 have users.each { |user| user.update_attribute(:status, status) }.
  can :bulk_status_callbacks, since: '7.0.2'

  # icons: core links the newest series draws with an icon and an older one as bare text; none here. Checked on 7.0.3:
  # the subtasks' and the relations' Lägg till have sprite_icon('add') and sprite_icon('link-add') with their classes.
  shim(:missing_icons) { |_view| [] }

  # icons: names the newest series' sprite has and this one's lacks, with the plugin whose sprite carries them; none
  # here, this is the newest.
  shim(:sprite_icons) { {} }

  # code blocks: core has a copy button on each one (a.copy-pre-content-link in div.pre-wrapper). Without it compat draws
  # the same markup. Checked on 7.0.3: lib/redmine/wiki_formatting/copypre_scrubber.rb draws it on the server.
  can :code_copy_button, true

  # the account: the logged-in person's account is a dropdown in the profile menu (.profile-menu > #account.dropdown with
  # a.dropdown-trigger), where account_menu's rows are drawn. Without it account_menu is a row of links in #top-menu
  # (#account) and the name stands beside it in #loggedas. Checked on 7.0.3: layouts/base.html.erb has
  # <div class="profile-menu"> with <div id="account" class="dropdown"> and <a class="dropdown-trigger">, and no loggedas.
  can :account_dropdown, true

  # custom fields: the format Progress bar (Redmine::FieldFormat::ProgressbarFormat). Without it a custom field has no such
  # format, and a plugin that adds to it does nothing. Checked on 7.0.3: lib/redmine/field_format.rb has class
  # ProgressbarFormat < Numeric.
  can :progressbar_field_format, true

  # % done as text beside the bar in lists, with a setting for where it stands (progress_bar_text, #5284). Without it
  # core_stuff's done_ratio_text adds the text. Checked on 7.0.3: config/settings.yml has no progress_bar_text.
  can :progress_bar_text, false

  # the mark after an external link as Tabler's external-link icon, grey, kept on the line with the link (#44691).
  # Without it core_stuff's external_links draws it. Checked on 7.0.3: application.css has div.wiki .external with
  # background-image url(/external.png).
  can :external_link_icon, false

  # avatars: a register of picture sources (Redmine::AvatarSources) that avatar asks before Gravatar. Without it avatar
  # knows only Gravatar (and the initials where core has them), and core_stuff's avatar_sources is the register.
  # Checked on 7.0.3: app/helpers/avatars_helper.rb has avatar(user, options) and no sources, and lib/redmine has no
  # AvatarSources.
  can :avatar_sources, false

  # tabs: a register where a plugin adds a tab to a settings page or the issue's history (Redmine::Tabs, and
  # settings_tab with its siblings on Redmine::Plugin). Without it the helpers' lists are fixed, and core_stuff's
  # settings_tabs is the register. Checked on 7.0.3: ProjectsHelper#project_settings_tabs is a fixed list, lib/redmine
  # has no tabs.rb, and lib/redmine/plugin.rb has no settings_tab.
  can :settings_tabs, false

  # history lines: a register where a plugin says how its own journal details are drawn (Redmine::JournalDetails,
  # and journal_detail on Redmine::Plugin). Without it IssuesHelper#show_detail knows only core's properties, and
  # core_stuff's journal_details is the register. Checked on 7.0.3: show_detail is a fixed case over the property,
  # lib/redmine has no journal_details.rb, and lib/redmine/plugin.rb has no journal_detail.
  can :journal_details, false

  # the layout's hooks (step 01 of view_hooks): hooks at the top and bottom of the header and footer, the top of the
  # content and the sidebar, after the page title, and around div.issue on the issue page. Without them core_stuff's
  # layout_hooks adds them. Checked on 7.0.3: layouts/base.html.erb calls view_layouts_base_html_head,
  # view_layouts_base_body_top, view_layouts_base_sidebar, view_layouts_base_content and view_layouts_base_body_bottom
  # only, and ApplicationHelper has no view_layouts_base_sidebar_top_hook_response.
  can :layout_hooks, false

  # the button row and the menus (step 04 of view_hooks): _contextual and _actions_menu hooks, and menus a plugin adds
  # items to for an issue, the issue list's context menu, a project, a user and a version. Without them core_stuff's
  # action_menus adds them. Checked on 7.0.3: lib/redmine/menu_manager.rb has no render_object_menu_items, and
  # news/index.html.erb calls no _contextual hook.
  can :action_menus, false

  # the forms (step 05 of view_hooks): hooks at the top and bottom of seven forms and after sections of the issue and
  # user forms. Without them core_stuff's form_hooks adds them. Checked on 7.0.3: projects/_form.html.erb calls no
  # view_projects_form_top.
  can :form_hooks, false

  # the lists (step 06 of view_hooks): a row's classes and content after the row in the issue, project and user lists.
  # Without them core_stuff's list_hooks adds them. Checked on 7.0.3: ApplicationHelper has no css_classes_from_hook.
  can :list_hooks, false

  # the issue page's sections (step 08 of view_hooks): data-section on the container of the description, the files,
  # the subtasks and the related issues, and the class section-heading on each one's heading, so that a plugin finds a
  # section without matching its label. Without them core_stuff's section_marks adds them. Checked on 7.0.3:
  # issues/show.html.erb, _subtasks.html.erb and _relations.html.erb have neither data-section nor section-heading.
  can :section_marks, false

  # the marks on parts of core's pages (step 09 of view_hooks): h1.site-title, h2.issue-heading and h3.subject-heading,
  # the workflow matrix's th/td.current-status, the field permissions matrix's th/td.field-name, data-report-column
  # (with data-status-id and data-status-closed) in the detailed issue report, tr[data-attachment-id], p[data-field]
  # (also in the issue bulk edit form), the version control table's column classes,
  # data-query-action and data-query-part in the query forms, li[data-menu-item=delete] in the issue context menu,
  # fieldset[data-section=attributes], a#issue_description_edit_link, a[data-section-action=add] for subtasks and
  # relations, and input[data-form-action=save]. Without them core_stuff's anchor_marks adds them. Checked on 7.0.3:
  # app/ has none of these classes, ids or data attributes; issues/show.html.erb has the class issue-heading only on the sticky header's span, not on the h2.
  can :anchor_marks, false

  # more hooks in core's views (step 10 of view_hooks): view_layouts_base_footer_powered_by_after,
  # view_issues_show_author_after, view_documents_show_details_bottom, view_settings_form_save_after,
  # view_my_account_information_after, view_issues_index_list_before and view_issues_list_before (at the top of
  # issues/_list, so in the issue list and in My page's issue blocks). Without them core_stuff's more_view_hooks adds
  # them. Checked on 7.0.3: app/ calls none of them, issues/_list included.
  can :more_view_hooks, false

  # the formatting processors (the proposal formatting_processors): one pass after textilizable over a formatted text's
  # links and runs of text, which plugins register with Redmine::WikiFormatting::Processors. Without it core_stuff's
  # formatting_processors runs the pass. Checked on 7.0.3: lib/redmine/wiki_formatting has no processors.rb and
  # ApplicationHelper#textilizable calls nothing after the table of contents.
  can :formatting_processors, false

  # the issue reports' marks (core_stuff's report_marks): every count ReportsHelper#aggregate_link draws stands in a
  # span with data-report-column (status, open, closed or total), and a status's count also has data-status-id and
  # data-status-closed, so that a plugin knows a column from its mark. Without them core_stuff's report_marks adds
  # them. Checked on 7.0.3: ReportsHelper#aggregate_link returns link_to(h(a), ...) or '-' with no mark, and
  # reports/_details.html.erb has no data-report-column.
  can :report_marks, false

  # the custom values' pass of the formatting processors (core_stuff's formatting_processors_values): the links of a
  # custom field's formatted value (the format Link, and a link pattern) go through the link processors after
  # Redmine::FieldFormat::Base#formatted_custom_value, with the custom value in the context. Without it core_stuff
  # runs that pass, also once core has the registry for formatted text (formatting_processors). Checked on 7.0.3:
  # lib/redmine/wiki_formatting has no processors, and formatted_custom_value only calls formatted_value.
  can :formatting_processors_values, false

  # the principal's mark (core_stuff's principal_marks): ApplicationHelper#link_to_principal gives the link to a user
  # or a group data-principal-id with the principal's id. Without it core_stuff's principal_marks adds it. Checked on
  # 7.0.3: link_to_principal draws link_to(name, url, :class => css_classes) with no data attribute.
  can :principal_marks, false

  # the breadcrumb's marks (core_stuff's breadcrumb_marks): the project links ApplicationHelper#page_header_title
  # draws (a.root and a.ancestor) carry data-project with the project's identifier. Without it core_stuff's
  # breadcrumb_marks adds it. Checked on 7.0.3: page_header_title passes link_to_project only :class ('root' or
  # 'ancestor').
  can :breadcrumb_marks, false

  # the menus' marks (core_stuff's menu_marks): every link Redmine::MenuManager::MenuHelper#render_menu draws carries
  # data-menu with the menu's name. Without it core_stuff's menu_marks adds it. Checked on 7.0.3: render_single_menu_node
  # draws link_to(label, url, item.html_options(selected:)) with no such attribute.
  can :menu_marks, false

  # the footer: a setting that shows Redmine's version after Powered by Redmine (footer_show_version). Without it
  # core_stuff's footer_version shows it. Checked on 7.0.3: config/settings.yml has no footer_show_version.
  can :footer_version_setting, false

  # the Gantt chart as PNG with the ImageMagick that configuration.yml names: core gives MiniMagick the command's
  # folder (cli_path). Without it MiniMagick runs convert from the PATH, and core_stuff's minimagick_path gives it the
  # command. Checked on 7.0.3: the Gemfile has mini_magick ~> 5.2.0, whose configuration has cli_prefix and no
  # cli_path, and lib/redmine/helpers/gantt.rb sets cli_path only when MiniMagick responds to it.
  can :minimagick_cli_path, false

  # OAuth: applications under Administration, a token limited to its scopes (the permissions' names and :admin).
  # Without it there is no OAuth and every API call is made with the person's own rights. Checked on 7.0.3:
  # app/views/doorkeeper/applications/_form.html.erb lists the permissions as scopes, ApplicationController#
  # find_current_user sets user.oauth_scope from the token, and User#allowed_to? passes it to Role#allowed_to?
  # (OAuthScope in oauth.rb).
  can :oauth2_provider, true

  # OAuth: Project.allowed_to_condition asks the roles with the token's scopes (Defect #44625), so a list built from it
  # shows a token only what its scopes cover, and project_condition is core's own condition. Before, it asked the
  # roles without them and project_condition limits it (OAuthScope in oauth.rb). Checked on 7.0.2: project.rb has
  # role.allowed_to?(permission); on 7.0.3: role.allowed_to?(permission, oauth_scope) with oauth_scope = user.oauth_scope,
  # and User has attr_accessor :oauth_scope.
  can :oauth_scope_project_condition, since: '7.0.3'

  # OAuth: a token without scopes ([]) is allowed nothing, so scope_allows? says no for it. Before, core treated an
  # empty list as no limit (the role's permissions and the public ones), and scope_allows? says yes as core does.
  # Checked on 7.0.0 to 7.0.2: Role#allowed_permissions has scope.present? ? unscoped & scope : unscoped; on 7.0.3:
  # scope ? unscoped & scope : unscoped.
  can :oauth_empty_scope_denies, since: '7.0.3'

  # whether the token lets the person use what a permission covers (always true without a token); who may is still
  # the caller's check
  shim(:scope_allows?) { |user, permission| GkCompat::OAuthScope.allows?(user, permission) }

  # an administrator whose token, if any, has the permission or :admin (an administrative API narrowed to one scope)
  shim(:admin_allows?) { |user, permission| GkCompat::OAuthScope.admin_allows?(user, permission) }

  # Project.allowed_to_condition with the token's scopes: core's own from the release where core asks with them
  shim(:project_condition) do |user, permission, options = {}, &block|
    GkCompat::OAuthScope.project_condition(user, permission, options, &block)
  end
end
