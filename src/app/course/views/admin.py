from django.shortcuts import render
from django.db import transaction

from ..forms import CourseForm
from app.userprofile.views import create_users

@transaction.atomic
def new_course(request):
    if request.method == 'POST':
        form = CourseForm(request.POST)
        if form.is_valid():
            course = form.save()
            create_users(amount = course.participants, prefix = course.id)
    else:
        form = CourseForm()

    return render(request, 'course/admin/new_course.html', {'form': form})