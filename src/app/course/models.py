from django.contrib.auth.models import User
from django.db import models

class Course(models.Model):
    name = models.CharField(max_length=255, unique=True)
    participants = models.IntegerField()
    
    def __str__(self):
        return self.name
        
    class Meta:
        ordering = ['name']