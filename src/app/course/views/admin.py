from django.shortcuts import render, redirect
from django.db import transaction
from django.contrib.admin.views.decorators import staff_member_required
from django.contrib import messages

from ..forms import CourseForm
from app.userprofile.views import create_users

@transaction.atomic
@staff_member_required
def new_course(request):
    if request.method == 'POST':
        form = CourseForm(request.POST)
        if form.is_valid():
            course = form.save()
            create_users(amount = course.participants, prefix = course.id)
            messages.success(request, 'Successfully created new course: %s' % course.name)
            return redirect('/admin')
    else:
        form = CourseForm()

    return render(request, 'course/admin/new_course.html', {'form': form})