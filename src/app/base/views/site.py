from django.shortcuts import render
from django.contrib.auth.decorators import login_required

from app.quiz.models import Test

@login_required
def index(request):
    tests = Test.objects.all()
    return render(request, 'base/site/index.html', {
        "tests" : tests
    })