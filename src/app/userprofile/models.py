from django.contrib.auth.models import User
from django.db import models

from app.course.models import Course
        
class UserGroup(models.Model):
    name = models.CharField(max_length=255, unique=True)
    
    def __str__(self):
        return self.name
    
    def users(self):
        return UserProfile.objects.filter(groups=self)
        
class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    groups = models.ManyToManyField(UserGroup)
    
    def __str__(self):
        return self.user.username