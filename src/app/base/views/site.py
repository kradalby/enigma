from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required

from app.quiz.models import Test
from app.course.models import Course
from app.userprofile.models import UserProfile

from ..forms import ChangePasswordForm

@login_required
def index(request):
    user = request.user
    if user.is_superuser:
        courses = Course.objects.all()
    else:
        userprofile = UserProfile.objects.get(user=user)
        groups = userprofile.groups.all()
        courses = Course.objects.filter(groups__in=groups)
    tests = Test.objects.all()
    return render(request, 'base/site/index.html', {
        "courses" : courses,
        "tests" : tests
    })
    
@login_required
def survey(request):
    return render(request, 'base/site/survey.html')
    
@login_required
def change_password(request):
    user = request.user
    userprofile = UserProfile.objects.get(user=user)
    if request.method == 'POST':
        form = ChangePasswordForm(request.POST)
        if form.is_valid():
            password = form.cleaned_data['password']
            verify_password = form.cleaned_data['verify_password']
            if password == verify_password:
                user.set_password(password)
                user.save()
                userprofile.has_changed_password = True
                userprofile.save()
            return redirect(index)
    else:
        form = ChangePasswordForm()

    return render(request, 'base/site/change_password.html', {
        'form': form,
        'user': user,
        'userprofile': userprofile
    })