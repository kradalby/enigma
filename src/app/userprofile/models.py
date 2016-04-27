from django.contrib.auth.models import User
from django.db import models

class UserGroupManager(models.Manager):
    def hidden(self):
        return super(UserGroupManager, self).filter(is_hidden=True)
        
    def non_hidden(self):
        return super(UserGroupManager, self).filter(is_hidden=False)

class UserGroup(models.Model):
    name = models.CharField(max_length=255, unique=True)
    is_hidden = models.BooleanField(default=True)
    
    objects = UserGroupManager()
    
    def __str__(self):
        return self.name
    
    def users(self):
        return UserProfile.objects.filter(groups=self)
        
    class Meta:
        ordering = ["name"]
        
class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    groups = models.ManyToManyField(UserGroup)
    
    def __str__(self):
        return self.user.username
        
    class Meta:
        ordering = ["user"]