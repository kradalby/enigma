from django.contrib.auth.models import User
from django.db import IntegrityError, transaction
from django.shortcuts import render

import random

from .models import UserProfile

@transaction.atomic
def create_users(amount, course):
    print("CREATING USERS: %d with prefix %s" % (amount, course.id))
    created = 0
    while created < amount:
        create_user_for_course(course)
        created+=1
    
@transaction.atomic
def create_user_for_course(course):
    user = User()
    user.username = _generate_random_username(course.id)
    user.set_password("question")
    user.save()
    userprofile = UserProfile()
    userprofile.user = user
    userprofile.course = course
    userprofile.save()
    print("Created user %s" % user.username)
    
def _generate_random_username(prefix):
    username = "%s-%s-%s" % (prefix, random.choice(colors), random.choice(animals))
    if UserProfile.objects.filter(user__username=username).exists():
        return _generate_random_username(prefix)
    return username
    
colors = ["red","blue","yellow","orange","green","purple","teal","dark","white","grey"]
animals = ["cat","fox","turtle","snake","dog","cow","sheep","bull"]