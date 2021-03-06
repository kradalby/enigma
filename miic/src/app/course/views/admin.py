from django.contrib import messages
from django.contrib.admin.views.decorators import staff_member_required
from django.core.exceptions import ObjectDoesNotExist
from django.db import transaction
from django.shortcuts import get_object_or_404, redirect, render

from app.quiz.models import Test
from app.userprofile.models import UserGroup, UserProfile

from ..forms import CourseForm, EditCourseForm
from ..models import Course
from ..util import generate_user_for_course as util_generate_user_for_course
from ..util import create_hidden_group_for_course


#
# Course specific
#


@transaction.atomic
@staff_member_required
def new_course(request):
    if request.method == 'POST':
        form = CourseForm(request.POST)
        if form.is_valid():
            course = form.save()
            messages.success(
                request,
                'Successfully created new course: {}.'.format(course.name))
            return redirect(view_course, course.id)
    else:
        form = CourseForm()

    return render(request, 'course/admin/new_course.html', {'form': form})


@staff_member_required
def list_courses(request):
    courses = Course.objects.all()
    return render(request, 'course/admin/list_courses.html',
                  {'courses': courses})


@staff_member_required
def delete_course(request, course_id):
    try:
        course = Course.objects.get(id=course_id)
        course_name = course.name
        course.delete()
        messages.success(request,
                         'Successfully deleted course: {}.'.format(course_name))
    except ObjectDoesNotExist:
        messages.warning(
            request,
            'The course has already been deleted. You may have clicked twice.')
    return redirect(list_courses)


@staff_member_required
def view_course(request, course_id):
    course = get_object_or_404(Course, id=course_id)
    group_id_to_exclude = [g.id for g in course.groups.hidden()]
    groups = course.groups.exclude(id__in=group_id_to_exclude)
    participants_without_groups = UserProfile.objects.filter(
        groups__id__in=group_id_to_exclude)
    tests = Test.objects.filter(course=course)
    return render(request, 'course/admin/view_course.html', {
        'course': course,
        'participants': participants_without_groups,
        'groups': groups,
        'tests': tests
    })


@staff_member_required
def edit_course(request, course_id):
    course = get_object_or_404(Course, id=course_id)
    form = EditCourseForm(request.POST or None, instance=course)
    if request.method == 'POST':
        if form.is_valid():
            course = form.save()
            messages.success(
                request, 'Successfully changed name of course to {}.'.format(
                    course.name))
            return redirect(view_course, course_id=course.id)
    else:
        form = EditCourseForm()

    return render(request, 'course/admin/edit_course.html',
                  {'form': form,
                   'course': course})


#
# Course and user related
#


def generate_user_for_course(request, course_id):
    course = get_object_or_404(Course, id=course_id)
    util_generate_user_for_course(course)
    messages.success(
        request, 'Successfully generated a user for {}.'.format(course.name))
    return redirect(view_course, course_id=course_id)


@staff_member_required
def list_courses_user_is_not_attending(request, user_id):
    user = get_object_or_404(UserProfile, id=user_id)
    courses = Course.objects.exclude(groups=user.groups.all())
    return render(request,
                  'course/admin/list_courses_user_is_not_attending.html',
                  {'user': user,
                   'courses': courses})


@staff_member_required
def register_user_to_course(request, user_id, course_id):
    course = get_object_or_404(Course, id=course_id)
    user = get_object_or_404(UserProfile, id=user_id)
    if user.groups.filter(id__in=course.groups.all()):
        messages.warning(request, '{} is already attending {}.'
                         .format(user, course.name))
    else:
        group = create_hidden_group_for_course(course)
        user.groups.add(group)
        course.groups.add(group)
        messages.success(
            request,
            'Successfully added %s user to {}.'.format(user, course.name))
    return redirect('admin_view_user', user_id=user_id)


@staff_member_required
def list_users_not_attending_course(request, course_id):
    course = get_object_or_404(Course, id=course_id)
    group_id_to_exclude = [g.id for g in course.groups.all()]
    users_not_attending_course = UserProfile.objects.exclude(
        groups__id__in=group_id_to_exclude)
    return render(request, 'course/admin/list_users_not_attending_course.html',
                  {'users': users_not_attending_course,
                   'course': course})


@staff_member_required
def register_existing_user_to_course(request, user_id, course_id):
    course = get_object_or_404(Course, id=course_id)
    user = get_object_or_404(UserProfile, id=user_id)
    if user.groups.filter(id__in=course.groups.all()):
        messages.warning(request, '{} is already attending {}.'
                         .format(user, course.name))
    else:
        group = create_hidden_group_for_course(course)
        user.groups.add(group)
        course.groups.add(group)
        messages.success(
            request,
            'Successfully added {} user to {}.'.format(user, course.name))
    return redirect('admin_view_course', course_id=course_id)


@staff_member_required
def unregister_user_from_course(request, course_id, user_id):
    user = get_object_or_404(UserProfile, id=user_id)
    course = get_object_or_404(Course, id=course_id)
    hidden_group = user.groups.hidden().get(id__in=course.groups.all())
    hidden_group.delete()
    messages.success(request, 'Successfully removed user from course')
    return redirect('admin_view_course', course_id)


#
# Course and group related
#


@staff_member_required
def list_all_groups_not_attending_course(request, course_id):
    course = get_object_or_404(Course, id=course_id)
    ids_of_groups_attending_course = [g.id for g in course.groups.all()]
    groups = UserGroup.objects.non_hidden().exclude(
        id__in=ids_of_groups_attending_course)
    return render(request,
                  'course/admin/list_all_groups_not_attending_course.html',
                  {'groups': groups,
                   'course': course})


@staff_member_required
def register_group_to_course(request, course_id, group_id):
    group = get_object_or_404(UserGroup, id=group_id)
    course = get_object_or_404(Course, id=course_id)
    course.groups.add(group)
    return redirect('admin_view_course', course_id)


@staff_member_required
def unregister_group_from_course(request, course_id, group_id):
    group = get_object_or_404(UserGroup, id=group_id)
    course = get_object_or_404(Course, id=course_id)
    course.groups.remove(group)
    messages.success(request, 'Successfully removed group from course')
    return redirect('admin_view_course', course_id)
