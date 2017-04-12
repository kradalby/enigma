from django.db import models

from app.userprofile.models import UserGroup


class Course(models.Model):
    name = models.CharField(max_length=255, unique=True)
    groups = models.ManyToManyField(UserGroup)

    def __str__(self):
        return self.name

    class Meta:
        ordering = ['name']

    @property
    def get_users(self):
        return [user for group in self.groups.all() for user in group.users()]