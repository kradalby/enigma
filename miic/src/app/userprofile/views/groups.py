from django.contrib import messages
from django.contrib.admin.views.decorators import staff_member_required
from django.core.exceptions import ObjectDoesNotExist
from django.db import transaction
from django.shortcuts import get_object_or_404, redirect, render

from ..forms import UserGroupForm
from ..models import UserGroup, UserProfile
from ..util import generate_user


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
    return render(request, 'usergroup/admin/view_group.html', {'group': group})


@staff_member_required
def list_users_not_in_group(request, group_id):
    group = get_object_or_404(UserGroup, id=group_id)
    users = UserProfile.objects.exclude(groups=group)

    return render(request, 'usergroup/admin/list_users_not_in_group.html',
                  {'group': group,
                   'users': users})


@staff_member_required
def list_groups(request):
    groups = UserGroup.objects.all().exclude(name__startswith="custom_group")
    return render(request, 'usergroup/admin/list_groups.html',
                  {'groups': groups})


@staff_member_required
def delete_group(request, group_id):
    try:
        group = UserGroup.objects.get(id=group_id)
        groupname = group.name
        group.delete()
        messages.success(request, 'Successfully deleted group %s.' % groupname)
    except ObjectDoesNotExist:
        messages.warning(
            request,
            'The group has already been deleted. You may have clicked twice.')
    return redirect(list_groups)


@staff_member_required
def register_user_in_group(request, group_id, user_id):
    group = get_object_or_404(UserGroup, id=group_id)
    user = get_object_or_404(UserProfile, id=user_id)
    user.groups.add(group)
    return redirect(view_group, group_id)


@staff_member_required
def unregister_user_from_group(request, group_id, user_id):
    group = get_object_or_404(UserGroup, id=group_id)
    user = get_object_or_404(UserProfile, id=user_id)
    user.groups.remove(group)
    messages.success(request,
                     'Successfully removed %s from %s.' % (user, group))
    return redirect("admin_view_user", user_id)


@staff_member_required
def generate_user_for_group(request, group_id):
    group = get_object_or_404(UserGroup, id=group_id)
    user = generate_user(group.prefix)
    user.groups.add(group)
    messages.success(request,
                     'Successfully generated a user for %s.' % group.name)
    return redirect(view_group, group_id)


@staff_member_required
def group_print_preview(request, group_id):
    group = get_object_or_404(UserGroup, id=group_id)
    return render(request, 'usergroup/admin/group_print_preview.html',
                  {'group': group})


@staff_member_required
def remove_user_from_group(request, group_id, user_id):
    try:
        user = get_object_or_404(UserProfile, id=user_id)
        group = get_object_or_404(UserGroup, id=group_id)
        user.groups.remove(group)
        messages.success(request,
                         'Successfully removed user from %s.' % group.name)
    except ObjectDoesNotExist:
        messages.warning(
            request,
            'The user has already been removed. You may have clicked twice.')
    return redirect(view_group, group_id)
