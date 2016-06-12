from django.shortcuts import render
from django.contrib.auth.decorators import login_required

from app.quiz.models import Test
from app.course.models import Course
from app.userprofile.models import UserProfile, UserGroup

@login_required
def index(request):
    user = request.user
    if user.is_superuser:
        courses = Course.objects.all()
    else:
        userprofile = UserProfile.objects.get(user=user)
        groups = userprofile.groups.all()
        courses = Course.objects.filter(groups=groups)
    tests = Test.objects.all()
    return render(request, 'base/site/index.html', {
        "courses" : courses,
        "tests" : tests
    })
    
@login_required
def survey(request):
    return render(request, 'base/site/survey.html')