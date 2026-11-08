# Changelog

All notable changes to GK Compat are documented in this file.

## 1.02.000 (2026-11-07)

### Added

* The ability `external_link_icon`: whether Redmine itself marks an external link with Tabler's external-link icon after the link (Feature #44691). No supported series has it yet, so the answer is no on Redmine 6.0, 6.1 and 7.0, and GK Core Stuff draws the icon.
* `GkCompat::Instant`, an ActiveRecord type for a plugin's own time columns: every instant is written in UTC with the offset written out (`+00:00`), so what is stored never depends on the database session's time zone. `GkCompat::Instant.attributes!(model, *columns)` gives a model's columns the type, and `GkCompat::Instant.text(time)` gives the same text for a time compared in SQL without changing the caller's time.
* The shim `sprite_icons`: the icons the newest supported Redmine has in its sprite and the running one lacks, with the plugin whose sprite carries them. On Redmine 6.0 and 6.1 it names `maximize`, and on 6.0 also `unwatch`, which GK Compat's own sprite now carries, copied unchanged from Redmine 7.0; on 7.0 it is empty.
* The ability `section_marks`: whether Redmine itself marks the issue page's sections (`data-section` on the description, the files, the subtasks and the related issues, and the class `section-heading` on each one's heading). No supported series has them, so the answer is no on Redmine 6.0, 6.1 and 7.0, and GK Core Stuff adds them.
* The ability `anchor_marks`: whether Redmine itself puts fixed marks on the parts of its pages that plugins change (the header's title, the issue's heading and subject, the workflow table's name column, the detailed issue report's columns, attachment rows, the issue form's attribute rows, the version control table's columns, the query forms' buttons and view controls, Delete in the issue context menu, the issue form's attributes box and description link, Add for subtasks and related issues, and Save in bulk editing and the settings). No supported series has them, so the answer is no on Redmine 6.0, 6.1 and 7.0, and GK Core Stuff adds them.
* The ability `more_view_hooks`: whether Redmine calls the hooks after the footer's link to Redmine, after the issue's author line, under a document's details, beside Save in the settings forms, after the Information box on My account, before the issue list page's list and at the top of every issue list (also My page's issue blocks). No supported series calls them, so the answer is no on Redmine 6.0, 6.1 and 7.0, and GK Core Stuff adds them.
* The ability `formatting_processors_values`: whether Redmine runs the links of a custom field's formatted value (the format Link, and a link pattern) through a registry of link processors. No in every supported series, so GK Core Stuff runs that pass.
* The ability `principal_marks`: whether Redmine's link to a user or a group carries the principal's id (`data-principal-id`). No in every supported series, so GK Core Stuff adds it.
* The ability `breadcrumb_marks`: whether the project links of the header's project path carry the project's identifier (`data-project`). No in every supported series, so GK Core Stuff adds it.
* The ability `formatting_processors`: whether Redmine has a registry of processors for the links and text of formatted text, run after the text is formatted. No in every supported series, so GK Core Stuff runs the pass.
* The ability `report_marks`: whether Redmine itself marks the counts of its issue reports with what each count is (`data-report-column`, and on a status's count `data-status-id` and `data-status-closed`). No in every supported series, so GK Core Stuff adds the marks.
* The ability `oauth_scope_project_condition`: whether Redmine's `Project.allowed_to_condition` itself limits the roles to an OAuth token's scopes (Defect #44625). Yes from Redmine 6.1.6 and 7.0.3, no on 6.0 (no OAuth) and on older 6.1 and 7.0 releases. Where it is yes, the shim `project_condition` is Redmine's own condition; where it is no, the shim limits it as before.
* The ability `oauth_empty_scope_denies`: whether Redmine allows an OAuth token without scopes nothing. Yes from Redmine 6.1.6 and 7.0.3, no on 6.0 (no OAuth) and on older 6.1 and 7.0 releases, where Redmine reads an empty scope list as no limit.
* The ability `menu_marks`: whether Redmine marks every link it draws in a menu with the menu's name (`data-menu`). No supported Redmine version does, so GK Core Stuff adds the mark.
* The ability `code_copy_button`: whether Redmine itself has a copy button on code blocks. On Redmine 6.0, which has none, GK Compat draws the same button, so that it and what other plugins do with it work on every supported series.

### Changed

* The shim `scope_allows?` answers as Redmine's roles do under a token: a permission is allowed only when the token has it as a scope, a public permission included. A token without scopes is allowed nothing from Redmine 6.1.6 and 7.0.3, and is not limited by its scopes on older 6.1 and 7.0 releases, as Redmine does there. Before, a public permission was always allowed and an empty scope list allowed only the public permissions.
* Every ability's notes are checked against Redmine 6.0.12, 6.1.6 and 7.0.3, and name the release they were checked on; no other answer changed.
* The shim `missing_icons` on Redmine 6.0 and 6.1 points at Add for subtasks and for related issues by the mark GK Core Stuff puts on them (`data-section-action="add"`), instead of by a link without a class in the section's button row. Without GK Core Stuff those links keep Redmine's own text and get no icon.
* Texts say Redmine and Redmine's where they said core, core's or the Swedish word for it.
* The copy button on code blocks in Redmine 6.0 asks the browser's clipboard whenever the browser offers it, as the newer Redmine does, so that GK GUI Stuff can confirm it with the whisper on every page.

### Fixed

* On Redmine 6.0 and 6.1, a page marked to have Redmine drawn with its colour variables no longer gives every heading, the page body and every table cell the colours and font of Redmine's wiki syntax help page. Those rules belong to the help page's own stylesheet, which Redmine loads only on that page, and are no longer copied into `gk_compat_core_vars.css`.
* On Redmine 6.1.5 and later 6.1 releases, locking or unlocking several accounts at once in Administration > Users wrote the status without the model's callbacks, because the ability `bulk_status_callbacks` said yes from 6.1.5. No 6.1 release has that fix (6.1.4, 6.1.5 and 6.1.6 all use `update_all`), so the ability is now no on all of 6.1 and GK Compat's backport applies there, as on 6.0.
* Redmine 6.0: under a theme, a note or a forum reply that is the address's target no longer keeps its fixed light band behind light text in dark mode.

## 1.01.000 (2026-10-28)

### Added

* The ability `oauth2_provider` (Redmine 6.1 and 7.0) and three shims for the GK plugins' REST API: `scope_allows?` says whether an OAuth token has a permission as its scope, `admin_allows?` lets an administrator's token be narrowed to one administrative scope instead of the whole admin scope, and `project_condition` is Redmine's project condition with the token's scopes. Redmine's own condition does not look at the scopes, so a list built on it showed a token everything the person's roles allow. On Redmine 6.0, which has no OAuth, they give Redmine's own answers.
* The abilities `progress_bar_text`, `avatar_sources`, `settings_tabs`, `journal_details`, `footer_version_setting` and `minimagick_cli_path`: whether Redmine itself has what a GK Core Stuff module adds. No supported series has any of them yet, so the answer is no on Redmine 6.0, 6.1 and 7.0; GK Core Stuff asks here instead of looking for Redmine's classes and settings itself.
* The abilities layout_hooks, action_menus, form_hooks and list_hooks: whether Redmine calls hooks in the page's frame, the button rows and object menus, the forms and the lists (no in any supported series).
* GkCompat.series_dir(base): the folder made for the running Redmine series under base, so that a plugin with data per series (GK Core Stuff's views) never compares versions itself.

### Changed

* Uninstalling (migrating the plugin down to 0) removes the plugin's row in Redmine's settings. The plugin has one migration for that, which does nothing when it is installed.

## 1.00.000 (2026-10-21)

* First release.
