from django.contrib import messages
from django.contrib.admin.views.decorators import staff_member_required
from django.contrib.auth.models import User
from django.core.exceptions import ObjectDoesNotExist
from django.db import IntegrityError, transaction
from django.shortcuts import render, get_object_or_404, redirect

import random

from app.userprofile.models import UserProfile, UserGroup
from app.userprofile.forms import UserProfileForm, UserGroupForm

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
    groups = userprofile.groups.non_hidden()
    return render(request, 'userprofile/admin/view_user.html',{
        'user' : userprofile,
        'groups' : groups
    })
    
@staff_member_required
def list_groups_user_is_not_member_of(request, user_id):
    userprofile = get_object_or_404(UserProfile, id=user_id)
    group_id_to_exclude = [g.id for g in userprofile.groups.all()]
    print("HEI")
    print(group_id_to_exclude)
    groups = UserGroup.objects.non_hidden().exclude(id__in=group_id_to_exclude)
    print(groups)
    for g in UserGroup.objects.all():
        print(g.is_hidden)
    print("HEI")
    return render(request, 'userprofile/admin/list_groups_user_is_not_member_of.html',{
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
@transaction.atomic
def delete_user(request, user_id, redirect_view="admin_list_users", *args, **kwargs):
    try:
        user = UserProfile.objects.get(id=user_id)
        username = user.user.username
        if user.groups.first() and user.groups.first().is_hidden:
            user.groups.first().delete()
        user.delete()
        messages.success(request, 'Successfully deleted user %s.' % username)
    except ObjectDoesNotExist:
        messages.warning(request, 'The user has already been deleted. You may have clicked twice.')
    return redirect(redirect_view, *args, **kwargs)
    
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
    username = "%s-%s" % (prefix, suffix_count)
    if User.objects.filter(username=username).exists():
        return _generate_username(prefix, suffix_count + 1)
    return username