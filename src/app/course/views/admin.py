from django.contrib import messages
from django.contrib.admin.views.decorators import staff_member_required
from django.core.exceptions import ObjectDoesNotExist
from django.db import transaction
from django.shortcuts import render, redirect

from ..forms import CourseForm
from ..models import Course

from app.userprofile.views import create_users

@transaction.atomic
@staff_member_required
def new_course(request):
    if request.method == 'POST':
        form = CourseForm(request.POST)
        if form.is_valid():
            course = form.save()
            create_users(amount = course.participants, prefix = course.id)
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
        course = Course.objects.get(id = course_id)
        course_name = course.name
        course.delete()
        messages.success(request, 'Successfully deleted course: %s.' % course_name)
    except ObjectDoesNotExist:
        messages.warning(request, 'The course has already been deleted. You may have clicked twice.')
    return redirect(list_courses)