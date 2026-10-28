# frozen_string_literal: true

module GkCompat
  # Core patches, all applied from here. compat's only ones are the backports (backports.rb): a fix the newest
  # supported series has, brought to an older one where the ability says it is missing, each core's own code from the
  # release that fixed it.
  # * UsersController#bulk_update_status (Backports::BulkStatus): only where :bulk_status_callbacks is missing; core's
  #   private method of the same name and arguments, saving account by account.
  # Applied directly from init.rb, which Redmine runs inside to_prepare at start and again after every reload in
  # development mode; the prepend is guarded, so a reload never adds it twice.
  module Patches
    module_function

    def apply! = Backports.apply!
  end
end
