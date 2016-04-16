from django.core.exceptions import ObjectDoesNotExist
from django.core.files.base import ContentFile
from django.contrib.admin.views.decorators import staff_member_required
from django.contrib import messages
from django.shortcuts import render, redirect
import re
import base64
import os


from ..forms import *
from ..models import *
  
@staff_member_required
def new_test(request):
    if request.method == 'POST':
        form = TestForm(request.POST)
        if form.is_valid():
            test = form.save()
            return redirect(add_questions_to_test, test.id)
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
            return redirect(add_questions_to_test, test.id)
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
            return redirect(add_questions_to_test, test.id)
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
            return redirect(draw_landmark, test.id, question.id)
    else:
        form = LandmarkQuestionForm()

    return render(request, 'quiz/admin/new_landmark_question.html', {
        "test" : test,
        "form" : form
    })
    
@staff_member_required
def draw_landmark(request, test_id, question_id):
    test = Test.objects.get(id=test_id)
    question = LandmarkQuestion.objects.get(id=question_id)
    if request.method == 'POST':
        dataUrlPattern = re.compile('data:image/(png|jpeg);base64,(.*)$')
        image_data = request.POST.get('hidden-image-data')
        image_data = dataUrlPattern.match(image_data).group(2)

        if (image_data == None or len(image_data) == 0):
            # TODO: PRINT ERROR MESSAGE HERE
            pass
        image_data = base64.b64decode(image_data)
        question.landmark_drawing = ContentFile(image_data, 'solution-' + os.path.basename( question.original_image.name ))
        question.save()
        for k,v in request.POST.items():
            if k.startswith('#') and len(k) == 7:
                region = LandmarkRegion()
                region.color = k
                region.name = v
                region.landmark_question = question
                region.save()
        return redirect(add_questions_to_test, test.id)
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
    messages.success(request, 'Successfully deleted all test results.')
    return redirect('/admin')
    
@staff_member_required
def add_landmark_regions(request, test_id, question_id):
    test = Test.objects.get(id=test_id)
    question = LandmarkQuestion.objects.get(id=question_id)
    
@staff_member_required
def delete_landmark_question(request, test_id, question_id):
    try:
        question = LandmarkQuestion.objects.get(id=question_id)
        question_text = question.question
        question.delete()
        messages.success(request, 'Successfully deleted question: %s.' % question_text)
    except ObjectDoesNotExist:
        messages.warning(request, 'The question has already been deleted. You may have clicked twice.')
    return redirect(add_questions_to_test, test_id)
    
@staff_member_required
def delete_test(request, test_id):
    try:
        test = Test.objects.get(id=test_id)
        test_name = test.name
        test.delete()
        messages.success(request, 'Successfully deleted test: %s.' % test_name)
    except ObjectDoesNotExist:
        messages.warning(request, 'The test has already been deleted. You may have clicked twice.')
    return redirect(list_tests)
    
@staff_member_required
def delete_multiple_choice_question(request, test_id, question_id):
    try:
        question = MultipleChoiceQuestion.objects.get(id=question_id)
        question_text = question.question
        question.delete()
        messages.success(request, 'Successfully deleted question: %s.' % question_text)
    except ObjectDoesNotExist:
        messages.warning(request, 'The question has already been deleted. You may have clicked twice.')
    return redirect(add_questions_to_test, test_id)
    
@staff_member_required
def delete_multiple_choice_question_with_image(request, test_id, question_id):
    try:
        question = MultipleChoiceQuestionWithImage.objects.get(id=question_id)
        question_text = question.question
        question.delete()
        messages.success(request, 'Successfully deleted question: %s.' % question_text)
    except ObjectDoesNotExist:
        messages.warning(request, 'The question has already been deleted. You may have clicked twice.')
    return redirect(add_questions_to_test, test_id)
    