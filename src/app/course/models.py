from django.db import models

from app.userprofile.models import UserGroup

class Course(models.Model):
    name = models.CharField(max_length=255, unique=True)
    groups = models.ManyToManyField(UserGroup)
    
    def __str__(self):
        return self.name
        
    class Meta:
        ordering = ['name']