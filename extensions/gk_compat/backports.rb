# frozen_string_literal: true

module GkCompat
  # Fixes the newest core has and an older release lacks, brought to the older one. Each is applied only where
  # the ability says no, and each is core's own code from the release that fixed it, so that the older release
  # behaves the same.
  module Backports
    # Locking or unlocking several accounts at once in the account list (Administration > Users). Before 7.0.2
    # and 6.1.5 core wrote the status with update_all, which skips the model's callbacks, so nothing that follows
    # an account (people's account events, the account's person) heard of it. From 7.0.2 and 6.1.5 core saves
    # account by account (app/controllers/users_controller.rb, bulk_update_status); this is that code.
    module BulkStatus
      private

      def bulk_update_status(user_ids, status)
        users = User.logged.where(id: user_ids).where.not(id: User.current)
        (render_404; return) unless users.any?

        users.each { |user| user.update_attribute(:status, status) }
        flash[:notice] = l(:notice_successful_update)
        redirect_to users_path
      end
    end

    module_function

    # The backports this release gets: [name, applied?]
    def apply!
      done = []
      if !GkCompat.can?(:bulk_status_callbacks) && ::UsersController.private_method_defined?(:bulk_update_status)
        ::UsersController.prepend(BulkStatus) unless ::UsersController < BulkStatus
        done << :bulk_status_callbacks
      end
      @applied = done
    end

    def applied = (@applied || [])
  end
end
