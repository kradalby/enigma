from django.contrib.auth.models import User
from django.db import models
from django.db.models import signals

class UserGroupManager(models.Manager):
    def hidden(self):
        return super(UserGroupManager, self).filter(is_hidden=True)
        
    def non_hidden(self):
        return super(UserGroupManager, self).filter(is_hidden=False)

class UserGroup(models.Model):
    name = models.CharField(max_length=255, unique=True)
    is_hidden = models.BooleanField(default=False)
    prefix = models.CharField(max_length=255, null=True, blank=True)
    
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
    autogenerated = models.BooleanField(default=False)
    password = models.CharField(max_length=255)
    has_changed_password = models.BooleanField(default=False)
    
    def __str__(self):
        return self.user.username
        
    class Meta:
        ordering = ["user__username"]
        
        
def delete_user(sender, instance=None, **kwargs):
    try:
        instance.user
    except User.DoesNotExist:
        pass
    else:
        instance.user.delete()
        
signals.post_delete.connect(delete_user, sender=UserProfile)