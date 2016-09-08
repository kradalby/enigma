from django.contrib import messages
from django.contrib.admin.views.decorators import staff_member_required
from django.contrib.auth.models import User
from django.core.exceptions import ObjectDoesNotExist
from django.db import transaction
from django.shortcuts import render, get_object_or_404, redirect

from app.userprofile.models import UserProfile, UserGroup
from app.userprofile.forms import UserProfileForm
from app.quiz.models import TestResult


@staff_member_required
@transaction.atomic
def new_user(request):
    if request.method == 'POST':
        form = UserProfileForm(request.POST)
        if form.is_valid():
            user = form.save(commit=False)
            if User.objects.filter(username=user.user.username).exists():
                messages.warning(
                    request, 'Username "%s" already exists. Try another one.' % user.user.username)
            else:
                user = form.save()
                messages.success(
                    request, 'Successfully created user %s.' % user)
                return redirect(view_user, user.id)
    else:
        form = UserProfileForm()

    return render(request, 'userprofile/admin/new_user.html', {'form': form})


@staff_member_required
def view_user(request, user_id):
    userprofile = UserProfile.objects.get(id=user_id)
    groups = userprofile.groups.non_hidden()
    test_results = TestResult.objects.filter(user=userprofile.user)
    return render(request, 'userprofile/admin/view_user.html', {
        'userprofile': userprofile,
        'groups': groups,
        'test_results': test_results
    })


@staff_member_required
def edit_user(request, user_id):
    user = get_object_or_404(UserProfile, id=user_id)
    form = UserProfileForm(request.POST or None, instance=user)
    if request.method == 'POST':
        if form.is_valid():
            user = form.save(commit=False)
            if User.objects.filter(username=user.user.username).exists():
                messages.warning(
                    request, 'Username "%s" already exists. Try another one.' % user)
            else:
                user = form.save()
                messages.success(
                    request, 'Successfully changed name of user to %s.' % user)
                return redirect(view_user, user.id)

    return render(request, 'userprofile/admin/edit_user.html', {
        'form': form,
        'user': user
    })


@staff_member_required
def list_groups_user_is_not_member_of(request, user_id):
    userprofile = get_object_or_404(UserProfile, id=user_id)
    group_id_to_exclude = [g.id for g in userprofile.groups.all()]
    groups = UserGroup.objects.non_hidden().exclude(id__in=group_id_to_exclude)
    return render(request, 'userprofile/admin/list_groups_user_is_not_member_of.html', {
        'user': userprofile,
        'groups': groups
    })


@staff_member_required
def list_users(request):
    users = UserProfile.objects.all()
    return render(request, 'userprofile/admin/list_users.html', {
        'users': users
    })


@staff_member_required
def delete_user(request, user_id):
    try:
        user = UserProfile.objects.get(id=user_id)
        username = user.user.username
        for hidden_group in user.groups.hidden():
            hidden_group.delete()
        user.delete()
        messages.success(request, 'Successfully deleted user %s.' % username)
    except ObjectDoesNotExist:
        messages.warning(
            request, 'The user has already been deleted. You may have clicked twice.')
    return redirect(list_users)


@staff_member_required
def delete_user_from_course(request, user_id, course_id):
    try:
        user = get_object_or_404(UserProfile, id=user_id)
        username = user.user.username
        for hidden_group in user.groups.hidden():
            hidden_group.delete()
        if user.groups.all().exists():
            user.delete()
        messages.success(request, 'Successfully deleted user %s.' % username)
    except ObjectDoesNotExist:
        messages.warning(
            request, 'The user has already been deleted. You may have clicked twice.')
    return redirect("admin_view_course", course_id)


@transaction.atomic
@staff_member_required
def reset_password_for_user(request, user_id, view_user_after=None):
    user = get_object_or_404(UserProfile, id=user_id)
    user.user.set_password(user.user.username)
    user.user.save()
    user.password = user.user.username
    user.save()
    messages.success(
        request, 'Successfully reset password for user %s.' % user.user.username)

    if view_user_after:
        return redirect(view_user, user_id)
    return redirect(list_users)
