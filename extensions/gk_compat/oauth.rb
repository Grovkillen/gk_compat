# frozen_string_literal: true

module GkCompat
  # OAuth scopes, for the series that have OAuth (the version files' shims :scope_allows? and :project_condition call
  # this). A token is limited to its scopes: core checks them in User#allowed_to? (Role#allowed_to? with the scope), but
  # Project.allowed_to_condition asks the roles without it, so a list built from it shows a token everything the
  # person's roles allow, whatever its scopes (core issue, the same in 6.1 and 7.0). Here a scope is a permission's
  # name, or :admin, which lets an administrator act as one.
  module OAuthScope
    module_function

    # The token's scopes (symbols), or nil when the person is not signed in by OAuth. Core keeps them in @oauth_scope
    # with a writer only (User#oauth_scope=, set by ApplicationController#find_current_user).
    def of(user) = user&.instance_variable_get(:@oauth_scope)

    # Whether the token lets the person use what the permission covers: true without a token, for a public
    # permission (core adds them to every application) and for a scope the token has; :admin covers it only for an
    # administrator. Who may do it is still decided by the caller (a role, the admin flag, the login).
    def allows?(user, permission)
      scope = of(user)
      return true if scope.nil?

      perm = permission.to_sym
      return true if scope.include?(perm)
      return true if Redmine::AccessControl.public_permissions.any? { |p| p.name == perm }

      scope.include?(:admin) && user.admin?
    end

    # Whether an administrator may use what the permission covers: the person is an administrator (the account's
    # flag; User#admin? is false under a token without :admin) and the token, if any, has the permission or :admin.
    # So a token can be narrowed to one administrative API without being given all of them.
    def admin_allows?(user, permission)
      return false unless user&.logged? && user.read_attribute(:admin)

      allows?(user, permission)
    end

    # Project.allowed_to_condition with the token's scopes: nothing when the token does not have the permission
    def project_condition(user, permission, options = {}, &block)
      return '1=0' unless allows?(user, permission)

      Project.allowed_to_condition(user, permission, options, &block)
    end
  end
end
