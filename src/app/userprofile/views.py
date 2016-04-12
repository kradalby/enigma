from django.shortcuts import render
from django.contrib.auth.models import User
from django.db import IntegrityError, transaction

import random

from .models import UserProfile

@transaction.atomic
def create_users(amount, prefix):
    print("CREATING USERS: %d with prefix %s" % (amount, prefix))
    created = 0
    while created < amount:
        create_prefixed_user(prefix)
        created+=1
    
def create_prefixed_user(prefix):
    user = User()
    user.username = _generate_random_username(prefix)
    user.set_password("question")
    user.save()
    print("Created user %s" % user.username)
    
def _generate_random_username(prefix):
    username = "%s-%s-%s" % (prefix, random.choice(colors), random.choice(animals))
    if User.objects.filter(username=username).exists():
        return _generate_random_username(prefix)
    return username
    
colors = ["red","blue","yellow","orange","green","purple","teal","dark","white","grey"]
animals = ["cat","fox","turtle","snake","dog","cow","sheep","bull"]