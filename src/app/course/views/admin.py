from django.contrib import messages
from django.contrib.admin.views.decorators import staff_member_required
from django.core.exceptions import ObjectDoesNotExist
from django.db import transaction
from django.shortcuts import render, redirect, get_object_or_404
from random import randint

from ..forms import CourseForm, EditCourseForm
from ..models import Course

from app.userprofile.models import UserProfile, UserGroup
from app.userprofile.views import create_users

@transaction.atomic
@staff_member_required
def new_course(request):
    if request.method == 'POST':
        form = CourseForm(request.POST)
        if form.is_valid():
            course = form.save()
            messages.success(request, 'Successfully created new course: %s.' % course.name)
            return redirect(view_course, course.id)
    else:
        form = CourseForm()

    return render(request, 'course/admin/new_course.html', {
        'form': form
    })
    
@staff_member_required
def list_courses(request):
    courses = Course.objects.all()
    return render(request, 'course/admin/list_courses.html',{
        'courses' : courses
    })
    
@staff_member_required
def delete_course(request, course_id):
    try:
        course = Course.objects.get(id = course_id)
        course_name = course.name
        course.delete()
        messages.success(request, 'Successfully deleted course: %s.' % course_name)
    except ObjectDoesNotExist:
        messages.warning(request, 'The course has already been deleted. You may have clicked twice.')
    return redirect(list_courses)
    
@staff_member_required
def view_course(request, course_id):
    course = get_object_or_404(Course, id = course_id)
    group_id_to_exclude = [g.id for g in course.groups.filter(name__startswith="custom_group")]
    groups = course.groups.exclude(id__in=group_id_to_exclude)
    participants = UserProfile.objects.filter(groups__id__in = group_id_to_exclude)
    print(participants)
    return render(request, 'course/admin/view_course.html',{
        'course' : course,
        'participants' : participants,
        'groups' : groups
    })

@staff_member_required    
def edit_course(request, course_id):
    course = get_object_or_404(Course, id=course_id)
    form = EditCourseForm(request.POST or None, instance=course)
    if request.method == 'POST':
        if form.is_valid():
            course = form.save()
            messages.success(request, 'Successfully changed name of course to %s.' % course.name)
            return redirect(view_course, course_id=course.id)
    else:
        form = EditCourseForm()

    return render(request, 'course/admin/edit_course.html',{
        'form' : form,
        'course' : course
    })
    
@staff_member_required
def add_user_to_course(request, course_id):
    course = get_object_or_404(Course, id=course_id)
    group = UserGroup()
    group.name = "custom_group-%s-%s" % (course.name, randint(0,1000000)) 
    group.save()
    create_users(1, group, course.name)
    course.groups.add(group)
    course.save()
    messages.success(request, 'Successfully added a user to %s.' % course.name)
    return redirect(view_course, course_id=course_id)
    
@staff_member_required
def add_group_to_course(request, course_id):
    course = get_object_or_404(Course, id=course_id)
    group_id_to_exclude = [g.id for g in course.groups.all()]
    groups = UserGroup.objects.exclude(id__in=group_id_to_exclude).exclude(name__startswith="custom_group")

    return render(request, 'course/admin/add_group_to_course.html',{
        'groups' : groups,
        'course' : course
    }) 
    
@staff_member_required
def register_group_to_course(request, course_id, group_id):
    group = get_object_or_404(UserGroup, id=group_id)
    course = get_object_or_404(Course, id=course_id)
    course.groups.add(group)
    return redirect("admin_view_course", course_id)
    
@staff_member_required
def unregister_group_from_course(request, course_id, group_id):
    group = get_object_or_404(UserGroup, id=group_id)
    course = get_object_or_404(Course, id=course_id)
    course.groups.remove(group)
    messages.success(request, 'Successfully removed group from course')
    return redirect("admin_view_course", course_id)