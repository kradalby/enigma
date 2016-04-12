from django.contrib.auth.models import User
from django.db import models

from app.course.models import Course

class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    course = models.ForeignKey(Course)