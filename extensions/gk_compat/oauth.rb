# frozen_string_literal: true

module GkCompat
  # OAuth scopes, for the series that have OAuth (the version files' shims :scope_allows? and :project_condition call
  # this). A token is limited to its scopes: core checks them in User#allowed_to? (Role#allowed_to? with the scope),
  # and core keeps a permission only when the token has it as a scope (Role#allowed_permissions: the role's
  # permissions and the public ones, & the scope). A token without scopes ([]) has nothing where core says so (the
  # ability :oauth_empty_scope_denies) and is not limited where core treats an empty list as no limit. Where
  # Project.allowed_to_condition also asks the roles with the scope (the ability :oauth_scope_project_condition),
  # project_condition is core's own condition; where it asks without it, a list built from it would show a token
  # everything the person's roles allow, and project_condition limits it here. A scope is a permission's name, or
  # :admin, which lets an administrator act as one.
  module OAuthScope
    module_function

    # The token's scopes (symbols), or nil when the person is not signed in by OAuth. Core keeps them in @oauth_scope,
    # set by ApplicationController#find_current_user; read from the variable, since not every release has a reader
    # (User#oauth_scope).
    def of(user) = user&.instance_variable_get(:@oauth_scope)

    # Whether the token lets the person use what the permission covers, as core's Role#allowed_permissions(scope)
    # decides it: true without a token and for a scope the token has, also a public permission only when the token
    # has it (core gives every application the public permissions, but a token may be asked for fewer); for a token
    # without scopes, nothing where core denies it (:oauth_empty_scope_denies) and true where core does not limit it;
    # :admin covers it only for an administrator. Who may do it is still decided by the caller (a role, the admin
    # flag, the login).
    def allows?(user, permission)
      scope = of(user)
      return true if scope.nil?
      return !GkCompat.can?(:oauth_empty_scope_denies) if scope.empty?

      in_scope?(user, scope, permission)
    end

    # Whether an administrator may use what the permission covers: the person is an administrator (the account's
    # flag; User#admin? is false under a token without :admin) and the token, if any, has the permission or :admin.
    # So a token can be narrowed to one administrative API without being given all of them. A token without scopes
    # never acts as an administrator, in any release (User#admin? asks for :admin in the scope).
    def admin_allows?(user, permission)
      return false unless user&.logged? && user.read_attribute(:admin)

      scope = of(user)
      scope.nil? || in_scope?(user, scope, permission)
    end

    # the token has the permission as a scope, or :admin and the person is an administrator
    def in_scope?(user, scope, permission)
      return true if scope.include?(permission.to_sym)

      scope.include?(:admin) && user.admin?
    end

    # Project.allowed_to_condition with the token's scopes: core's own where it limits the roles to the scopes
    # itself, else nothing when the token does not allow the permission
    def project_condition(user, permission, options = {}, &block)
      return Project.allowed_to_condition(user, permission, options, &block) if GkCompat.can?(:oauth_scope_project_condition)
      return '1=0' unless allows?(user, permission)

      Project.allowed_to_condition(user, permission, options, &block)
    end
  end
end
