from django.contrib import messages
from django.contrib.admin.views.decorators import staff_member_required
from django.core.exceptions import ObjectDoesNotExist
from django.db import transaction
from django.shortcuts import render, redirect, get_object_or_404

from ..forms import CourseForm, EditCourseForm
from ..models import Course

from app.userprofile.models import UserProfile
from app.userprofile.views import create_users

@transaction.atomic
@staff_member_required
def new_course(request):
    if request.method == 'POST':
        form = CourseForm(request.POST)
        if form.is_valid():
            course = form.save()
            create_users(amount = course.participants, course = course)
            messages.success(request, 'Successfully created new course: %s.' % course.name)
            return redirect(list_courses)
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
        course = get_object_or_404(Course, id = course_id)
        course_name = course.name
        course.delete()
        messages.success(request, 'Successfully deleted course: %s.' % course_name)
    except ObjectDoesNotExist:
        messages.warning(request, 'The course has already been deleted. You may have clicked twice.')
    return redirect(list_courses)
    
@staff_member_required
def view_course(request, course_id):
    course = get_object_or_404(Course, id = course_id)
    participants = UserProfile.objects.filter(course = course)
    return render(request, 'course/admin/view_course.html',{
        'course' : course,
        'participants' : participants
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
    create_users(amount = 1, course = course)
    course.participants += 1
    course.save()
    messages.success(request, 'Successfully added user to %s.' % course.name)
    return redirect(view_course, course_id=course_id)