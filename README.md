# GK Compat

GK Compat is the one place in the GK plugins that knows which Redmine version is running. Other plugins ask it whether the running Redmine has an ability or call a shim through it, and what differs between the supported Redmine series (6.0, 6.1 and 7.0) is kept in one file per series.

## Features

- Answers whether the running Redmine has a given ability (`GkCompat.can?`), for example whether core draws with CSS variables, marks the reading direction with `dir`, supports icon styles in `sprite_icon`, still carries the raster icon classes, or asks administrators for their password again (sudo mode) by default.
- Calls shims (`GkCompat.call`) that give the same answer on every supported series, each done that series' way.
- States abilities per series, with an optional `since:` release for a change that came within a series (for example from 6.1.5 or 7.0.2).
- On Redmine 6.0 and 6.1, adds core's colour variables (`--oc-*`, Open Color 1.9.1, the same file Redmine 7.0 carries) to every page, so stylesheets can be written once for 7.0.
- Backports a core fix to older releases: locking or unlocking several accounts at once in Administration > Users saves account by account, so the model's callbacks run (core's own code from 6.1.5 and 7.0.2).
- When the running Redmine series has no version file, runs on the nearest older file and warns administrators in the log and on the administration and settings pages.

## Requirements

- Redmine 6.0.0 or higher.
- Ruby 3.2 or later, the version your Redmine release runs on.
- PostgreSQL.

This plugin is developed and tested on Windows 11 with PostgreSQL only. That is a deliberate choice made for the maintainer's own convenience: the production system and the whole toolchain run there, and supporting other platforms and databases would cost time without adding anything for our own use. The Ruby code avoids needless Windows or PostgreSQL specific constructs, so it may well run on Linux, but that is untested and not supported. Its migrations use PostgreSQL's own types, so PostgreSQL is required.

GK plugins: none required and none optional. Other GK plugins use gk_compat when it is installed.

## Installation

The plugin directory must be named `gk_compat` (it is the plugin id): `plugins/gk_compat/`.

1. Unpack the release package into Redmine's `plugins` directory.
2. Restart Redmine.

The plugin has no database tables and no Gemfile.

Uninstall: remove the `plugins/gk_compat` directory and restart Redmine.

## Configuration

There is nothing to set. Administration > Plugins > Configure (GK Compat) shows the running Redmine, Ruby and Rails versions, the version file in use, the backports applied, whether the colour variables are supplied, and a table of every ability and shim per supported series.

## Usage

GK Compat has no user interface of its own beyond the configuration page. Its effects are the colour variables on Redmine 6.0 and 6.1, the backported account locking in Administration > Users, and the abilities and shims other plugins use.

## Changelog

See CHANGELOG.md.

## License

GPL-2.0-or-later, the same license as Redmine. Copyright (C) 2026 Jimmy Westberg. See the LICENSE file for the full text.

The colour variables come from Open Color 1.9.1 (MIT License, Copyright (c) 2016 heeyeun), unchanged. Its license text is in LICENSE_OPEN_COLOR.txt.
