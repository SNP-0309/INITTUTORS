"""Manager for the custom User model."""

from django.contrib.auth.base_user import BaseUserManager

from apps.common.constants import Role, UserStatus


class UserManager(BaseUserManager):
    """Creates users keyed by `phone` (USERNAME_FIELD), per database.md §5.1.

    Login is by email+password (api.md §3.4), but `phone` is the required,
    unique identifier of record in the schema.
    """

    use_in_migrations = True

    def _create_user(self, phone, full_name, password, *, email=None, role, **extra):
        if not phone:
            raise ValueError("A phone number is required.")
        if not role:
            raise ValueError("A role is required.")
        email = self.normalize_email(email) if email else None
        user = self.model(
            phone=phone,
            full_name=full_name,
            email=email,
            role=role,
            **extra,
        )
        # Uses the configured PASSWORD_HASHERS (bcrypt) — never stores plaintext.
        user.set_password(password)
        user.full_clean(exclude=["password"])
        user.save(using=self._db)
        return user

    def create_user(self, phone, full_name, password=None, *, email=None,
                     role=Role.TEACHER, **extra):
        extra.setdefault("is_staff", False)
        extra.setdefault("is_superuser", False)
        return self._create_user(
            phone, full_name, password, email=email, role=role, **extra
        )

    def create_superuser(self, phone, full_name, password, *, email=None, **extra):
        extra.setdefault("is_staff", True)
        extra.setdefault("is_superuser", True)
        extra.setdefault("role", Role.ADMIN)
        extra.setdefault("status", UserStatus.ACTIVE)
        if extra["is_staff"] is not True or extra["is_superuser"] is not True:
            raise ValueError("Superuser must have is_staff=True and is_superuser=True.")
        return self._create_user(
            phone, full_name, password, email=email, **extra
        )
