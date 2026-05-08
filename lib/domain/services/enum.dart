/// Enum for user roles
enum UserRole { admin, user, manager, unknown }

/// Utility class for role/permission checks
class RoleUtils {
  /// Check if user is admin - handles all case variations
  /// Supports: "admin", "Admin", "ADMIN", "isAdmin", "is_admin", "IsAdmin", etc.
  static bool isAdmin(String? role) {
    if (role == null || role.isEmpty) {
      return false;
    }

    // Normalize: convert to lowercase and remove spaces
    final normalizedRole = role.toLowerCase().trim();

    // Check for various admin role patterns
    return normalizedRole == 'admin' ||
        normalizedRole == 'is_admin' ||
        normalizedRole == 'isadmin' ||
        normalizedRole == '1' || // Sometimes API returns 1 for admin
        normalizedRole == 'true';
  }

  /// Check if user is manager
  static bool isManager(String? role) {
    if (role == null || role.isEmpty) {
      return false;
    }

    final normalizedRole = role.toLowerCase().trim();

    return normalizedRole == 'manager' ||
        normalizedRole == 'is_manager' ||
        normalizedRole == 'ismanager';
  }

  /// Check if user is regular user
  static bool isUser(String? role) {
    if (role == null || role.isEmpty) {
      return false;
    }

    final normalizedRole = role.toLowerCase().trim();

    return normalizedRole == 'user' ||
        normalizedRole == 'is_user' ||
        normalizedRole == 'isuser' ||
        normalizedRole == 'member' ||
        normalizedRole == 'employee';
  }

  /// Convert role string to UserRole enum
  static UserRole getRoleType(String? role) {
    if (isAdmin(role)) {
      return UserRole.admin;
    } else if (isManager(role)) {
      return UserRole.manager;
    } else if (isUser(role)) {
      return UserRole.user;
    }
    return UserRole.unknown;
  }

  /// Get readable role name
  static String getRoleName(String? role) {
    switch (getRoleType(role)) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.manager:
        return 'Manager';
      case UserRole.user:
        return 'User';
      case UserRole.unknown:
        return 'Unknown';
    }
  }

  /// Check if user has permission (can be extended based on your needs)
  static bool hasPermission(String? userRole, String requiredPermission) {
    final role = getRoleType(userRole);

    // Define permissions based on roles
    switch (role) {
      case UserRole.admin:
        return true; // Admin has all permissions

      case UserRole.manager:
        return requiredPermission != 'delete_user' &&
            requiredPermission != 'manage_roles';

      case UserRole.user:
        return requiredPermission == 'read_only' ||
            requiredPermission == 'view_profile';

      case UserRole.unknown:
        return false;
    }
  }
}
