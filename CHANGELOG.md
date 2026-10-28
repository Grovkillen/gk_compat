# Changelog

All notable changes to GK Compat are documented in this file.

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
