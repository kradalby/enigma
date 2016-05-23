from django.contrib.auth.models import User
from django.db import transaction

from .models import UserProfile
import random

@transaction.atomic
def generate_users(amount, group, prefix):
    created = 0
    while created < amount:
        user = generate_user(prefix, created)
        user.groups.add(group)
        created+=1
        
@transaction.atomic
def generate_user(prefix, suffix_count = 1, password = "question"):
    user = User()
    user.username = _generate_username(prefix, suffix_count)
    user.set_password(password)
    user.save()
    userprofile = UserProfile()
    userprofile.user = user
    userprofile.save()
    return userprofile
    
def _generate_username(prefix, suffix_count):
    username = "{0}-{1:02}".format(prefix, suffix_count)
    if User.objects.filter(username=username).exists():
        return _generate_username(prefix, suffix_count + 1)
    return username