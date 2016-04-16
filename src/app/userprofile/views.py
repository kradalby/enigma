from django.contrib import messages
from django.contrib.admin.views.decorators import staff_member_required
from django.contrib.auth.models import User
from django.core.exceptions import ObjectDoesNotExist
from django.db import IntegrityError, transaction
from django.shortcuts import render, get_object_or_404, redirect

import random

from .models import UserProfile

@staff_member_required
@transaction.atomic
def delete_userprofile(request, userprofile_id, course_id):
    try:
        userprofile = UserProfile.objects.get(id=userprofile_id)
        course = userprofile.course 
        course.participants -= 1
        course.save()
        username = userprofile.user.username
        userprofile.delete()
        messages.success(request, 'Successfully deleted user %s.' % username)
    except ObjectDoesNotExist:
        messages.warning(request, 'The user has already been deleted. You may have clicked twice.')
    return redirect("admin_view_course", course_id)

@transaction.atomic
def create_users(amount, course):
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
 
def _generate_random_username(prefix):
    username = "%s-%s-%s" % (prefix, random.choice(colors), random.choice(animals))
    if UserProfile.objects.filter(user__username=username).exists():
        return _generate_random_username(prefix)
    return username
    
colors = ["red","blue","yellow","orange","green","purple","teal","dark","white","grey","pink"]
animals = ["cat","fox","turtle","snake","dog","cow","sheep","bull","mouse"]