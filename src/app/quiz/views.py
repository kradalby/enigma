from django.shortcuts import render

from .models import Test

def index (request):
    tests = Test.objects.all()
    return render(request, 'test_list.html', locals())