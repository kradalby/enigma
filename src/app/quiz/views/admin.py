from django.contrib.admin.views.decorators import staff_member_required
from django.shortcuts import render
from django.http import HttpResponseRedirect

from ..forms import *
from ..models import *

@staff_member_required
def index (request):
    return render(request, 'quiz/admin/index.html')
  
@staff_member_required
def new_test(request):
    if request.method == 'POST':
        form = TestForm(request.POST)
        if form.is_valid():
            test = form.save()
            return HttpResponseRedirect('/admin/test/' + str(test.id))
    else:
        form = TestForm()

    return render(request, 'quiz/admin/new_test.html', {'form': form})
    
@staff_member_required
def add_questions_to_test(request, test_id):
    test = Test.objects.get(id=test_id)
    return render(request, 'quiz/admin/add_questions_to_test.html', {
        "test" : test
    })
    
@staff_member_required
def add_mpc_to_test(request, test_id):
    test = Test.objects.get(id=test_id)
    if request.method == 'POST':
        form = MultipleChoiceQuestionForm(request.POST)
        if form.is_valid():
            question = form.save(commit=False)
            question.test_id = test_id
            question.save()
            return HttpResponseRedirect('/admin/test/' + str(test.id))
    else:
        form = MultipleChoiceQuestionForm()

    return render(request, 'quiz/admin/add_question_to_test.html', {
        "test" : test,
        "form" : form
    })
    
@staff_member_required
def add_mpci_to_test(request, test_id):
    test = Test.objects.get(id=test_id)
    if request.method == 'POST':
        form = MultipleChoiceQuestionWithImageForm(request.POST, request.FILES)
        if form.is_valid():
            question = form.save(commit=False)
            question.test_id = test_id
            question.save()
            return HttpResponseRedirect('/admin/test/' + str(test.id))
    else:
        form = MultipleChoiceQuestionWithImageForm()

    return render(request, 'quiz/admin/add_question_to_test.html', {
        "test" : test,
        "form" : form
    })
    
    
@staff_member_required
def add_landmark_to_test(request, test_id):
    test = Test.objects.get(id=test_id)
    if request.method == 'POST':
        form = LandmarkQuestionForm(request.POST, request.FILES)
        if form.is_valid():
            question = form.save(commit=False)
            question.test_id = test_id
            question.save()
            return HttpResponseRedirect('draw/' + str(question.id))
    else:
        form = LandmarkQuestionForm()

    return render(request, 'quiz/admin/new_landmark_question.html', {
        "test" : test,
        "form" : form
    })
    
def draw_landmark(request, test_id, question_id):
    test = Test.objects.get(id=test_id)
    question = LandmarkQuestion.objects.get(id=question_id)
    if request.method == 'POST':
        return HttpResponseRedirect('/admin/test/' + test_id)
    return render(request, 'quiz/admin/draw_landmark.html', {
        "test" : test,
        "question" : question
    })
    
    
@staff_member_required
def list_tests(request):
    tests = Test.objects.all()
    return render(request, 'quiz/admin/test_list.html', {
        "tests" : tests
    })
   
@staff_member_required 
def delete_test_results(request):
    TestResult.objects.all().delete()
    return HttpResponseRedirect('/admin/')