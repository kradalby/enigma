from django.contrib import messages
from django.contrib.admin.views.decorators import staff_member_required
from django.contrib.auth.models import User
from django.core.exceptions import ObjectDoesNotExist
from django.db import IntegrityError, transaction
from django.shortcuts import render, get_object_or_404, redirect

import random

from .models import UserProfile, UserGroup
from .forms import UserProfileForm, UserGroupForm

@staff_member_required
@transaction.atomic
def new_user(request):
    if request.method == 'POST':
        form = UserProfileForm(request.POST)
        if form.is_valid():
            userprofile = form.save()
            return redirect(view_user, userprofile.id)
    else:
        form = UserProfileForm()

    return render(request, 'userprofile/admin/new_user.html', {'form': form})
    
@staff_member_required
def view_user(request, user_id):
    userprofile = UserProfile.objects.get(id=user_id)
    return render(request, 'userprofile/admin/view_user.html',{
        'user' : userprofile
    })
    
@staff_member_required
def add_group_to_user(request, user_id):
    userprofile = get_object_or_404(UserProfile, id=user_id)
    group_id_to_exclude = [g.id for g in userprofile.groups.all()]
    groups = UserGroup.objects.exclude(id__in=group_id_to_exclude).exclude(name__startswith="custom_group")
    return render(request, 'userprofile/admin/add_group_to_user.html',{
        'user' : userprofile,
        'groups' : groups
    })
    
@staff_member_required
def list_users(request):
    users = UserProfile.objects.all()
    return render(request, 'userprofile/admin/list_users.html',{
        'users' : users
    })
    
@staff_member_required
def delete_user(request, user_id):
    try:
        user = UserProfile.objects.get(id=user_id)
        username = user.user.username
        user.delete()
        messages.success(request, 'Successfully deleted user %s.' % username)
    except ObjectDoesNotExist:
        messages.warning(request, 'The user has already been deleted. You may have clicked twice.')
    return redirect("admin_list_users")

@staff_member_required
@transaction.atomic
def new_group(request):
    if request.method == 'POST':
        form = UserGroupForm(request.POST)
        if form.is_valid():
            usergroup = form.save()
            return redirect(view_group, usergroup.id)
    else:
        form = UserGroupForm()

    return render(request, 'usergroup/admin/new_group.html', {'form': form})
     
@staff_member_required
def view_group(request, group_id):
    group = UserGroup.objects.get(id=group_id)
    return render(request, 'usergroup/admin/view_group.html',{
        'group' : group
    })  
    
@staff_member_required
def add_user_to_group(request, group_id):
    group = get_object_or_404(UserGroup, id=group_id)
    users = UserProfile.objects.exclude(groups = group)

    return render(request, 'usergroup/admin/add_user_to_group.html',{
        'group' : group,
        'users' : users
    }) 
    
@staff_member_required
def list_groups(request):
    groups = UserGroup.objects.all().exclude(name__startswith="custom_group")
    return render(request, 'usergroup/admin/list_groups.html',{
        'groups' : groups
    })
    
@staff_member_required
def delete_group(request, group_id):
    try:
        group = UserGroup.objects.get(id=group_id)
        groupname = group.name
        group.delete()
        messages.success(request, 'Successfully deleted group %s.' % groupname)
    except ObjectDoesNotExist:
        messages.warning(request, 'The group has already been deleted. You may have clicked twice.')
    return redirect("admin_list_groups")
    
@staff_member_required
def register_user_in_group(request, group_id, user_id):
    group = get_object_or_404(UserGroup, id=group_id)
    user = get_object_or_404(UserProfile, id=user_id)
    user.groups.add(group)
    return redirect("admin_view_group", group_id)

@transaction.atomic
def create_users(amount, group, prefix):
    created = 0
    while created < amount:
        add_user_to_group(group, prefix, created)
        created+=1
        
@transaction.atomic
def add_user_to_group(group, prefix, suffix):
    user = User()
    user.username = _generate_username(prefix, suffix)
    user.set_password("question")
    user.save()
    userprofile = UserProfile()
    userprofile.user = user
    userprofile.save()
    userprofile.groups.add(group)
    
def _generate_username(prefix, suffix):
    username = "%s-%s" % (prefix, suffix)
    if User.objects.filter(username=username).exists():
        return _generate_username(prefix, suffix + 1)
    return username
    
@staff_member_required
@transaction.atomic
def delete_userprofile(request, userprofile_id, course_id):
    try:
        userprofile = UserProfile.objects.get(id=userprofile_id)
        if userprofile.groups.first().name.startswith("custom_group"):
            userprofile.groups.first().delete()
        username = userprofile.user.username
        userprofile.delete()
        messages.success(request, 'Successfully deleted user %s.' % username)
    except ObjectDoesNotExist:
        messages.warning(request, 'The user has already been deleted. You may have clicked twice.')
    return redirect("admin_view_course", course_id)