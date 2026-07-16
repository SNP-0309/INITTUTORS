"""Shared role-based access control (RBAC) permission classes.

Enforced server-side per BR-F / FR-1.3. This is the single shared policy layer
(backend.md §5.4) — role checks are defined here once and reused across modules
rather than duplicated per endpoint. Resource-level (ownership) checks belong in
the relevant service layer, not here.
"""

from rest_framework.permissions import BasePermission

from apps.common.constants import Role


class HasRole(BasePermission):
    """Factory-style permission: allow only the given role(s).

    Usage:
        permission_classes = [HasRole.of(Role.ADMIN, Role.TEACHER)]
    """

    allowed_roles: tuple[str, ...] = ()

    @classmethod
    def of(cls, *roles: str):
        role_values = tuple(
            r.value if isinstance(r, Role) else r for r in roles
        )
        return type(
            f"HasRole_{'_'.join(role_values)}",
            (cls,),
            {"allowed_roles": role_values},
        )

    def has_permission(self, request, view) -> bool:
        user = request.user
        if not (user and user.is_authenticated):
            return False
        return user.role in self.allowed_roles


class IsAdmin(BasePermission):
    def has_permission(self, request, view) -> bool:
        user = request.user
        return bool(user and user.is_authenticated and user.role == Role.ADMIN)


class IsTeacher(BasePermission):
    def has_permission(self, request, view) -> bool:
        user = request.user
        return bool(user and user.is_authenticated and user.role == Role.TEACHER)


class IsParent(BasePermission):
    def has_permission(self, request, view) -> bool:
        user = request.user
        return bool(user and user.is_authenticated and user.role == Role.PARENT)


class IsStudent(BasePermission):
    def has_permission(self, request, view) -> bool:
        user = request.user
        return bool(user and user.is_authenticated and user.role == Role.STUDENT)


class IsAdminOrTeacher(BasePermission):
    def has_permission(self, request, view) -> bool:
        user = request.user
        return bool(
            user
            and user.is_authenticated
            and user.role in (Role.ADMIN, Role.TEACHER)
        )
