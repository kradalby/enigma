from django.core.exceptions import ObjectDoesNotExist
from django.core.files.base import ContentFile
from django.contrib.admin.views.decorators import staff_member_required
from django.contrib import messages
from django.shortcuts import render, redirect, get_object_or_404
import re
import base64
import os

from ..forms import *
from ..models import *
  
#
# Test related
#

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
def list_tests(request):
    tests = Test.objects.all()
    return render(request, 'quiz/admin/test_list.html', {
        "tests" : tests
    })
    
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
    
#
# Test result related
#
   
@staff_member_required 
def delete_test_results(request):
    TestResult.objects.all().delete()
    messages.success(request, 'Successfully deleted all test results.')
    return redirect('/admin')
    
#
# Questions related
#
@staff_member_required
def list_questions(request):
    multiple_choice_questions = MultipleChoiceQuestion.objects.all()
    multiple_choice_questions_with_image = MultipleChoiceQuestionWithImage.objects.all()
    multiple_choice_questions_with_video = MultipleChoiceQuestionWithVideo.objects.all()
    landmark_questions = LandmarkQuestion.objects.all()
    return render(request, 'quiz/admin/list_questions.html', {
        "multiple_choice_questions" : multiple_choice_questions,
        "multiple_choice_questions_with_image" : multiple_choice_questions_with_image,
        "multiple_choice_questions_with_video" : multiple_choice_questions_with_video,
        "landmark_questions" : landmark_questions
    })

#
# Generic functions
#
@staff_member_required
def _generic_add_multiple_choice_question_to_test(request, form_type, test_id):
    test = Test.objects.get(id=test_id)
    if request.method == 'POST':
        form = form_type(request.POST, request.FILES)
        if form.is_valid():
            question = form.save()
            question.test.add(test)
            return redirect('admin_add_questions_to_test', test.id)
    else:
        form = form_type()

    return render(request, 'quiz/admin/add_question_to_test.html', {
        "test" : test,
        "form" : form
    })
    
@staff_member_required
def _generic_delete_question(request, question_type, question_id):
    try:
        question = question_type.objects.get(id=question_id)
        question_text = question.question
        question.delete()
        messages.success(request, 'Successfully deleted question: %s.' % question_text)
    except ObjectDoesNotExist:
        messages.warning(request, 'The question has already been deleted. You may have clicked twice.')

@staff_member_required
def _generic_remove_question_from_test(request, question_type, test_id, question_id):
    question = question_type.objects.get(id=question_id)
    test = Test.objects.get(id=test_id)
    question.test.remove(test)
    messages.success(request, 'Successfully removed question from test: %s.' % question.question)
    
@staff_member_required
def _generic_new_question(request, form_type):
    if request.method == 'POST':
        form = form_type(request.POST, request.FILES)
        if form.is_valid():
            question = form.save()
            messages.success(request, 'Successfully created new question: %s.' % question)
            return redirect(list_questions)
    else:
        form = form_type()

    return render(request, 'quiz/admin/new_question.html', {
        'form': form
    })
    
@staff_member_required
def _generic_edit_question(request, form_type, object_type, id):
    instance = get_object_or_404(object_type, id=id)
    form = form_type(request.POST or None, instance=instance)
    if request.method == 'POST':
        if form.is_valid():
            question = form.save()
            messages.success(request, 'Successfully saved question: %s.' % question)
            return redirect(list_questions)

    return render(request, 'quiz/admin/edit_question.html',{
        'form' : form,
        'question' : instance
    })
#
# MPC related
#

@staff_member_required
def new_multiple_choice_question(request):
    return _generic_new_question(request, MultipleChoiceQuestionForm)
    
@staff_member_required
def edit_multiple_choice_question(request, question_id):
    return _generic_edit_question(request, MultipleChoiceQuestionForm, MultipleChoiceQuestion, question_id)

@staff_member_required
def add_multiple_choice_question_to_test(request, test_id):
    return _generic_add_multiple_choice_question_to_test(request, MultipleChoiceQuestionForm, test_id)
           
@staff_member_required
def delete_multiple_choice_question_from_test(request, test_id, question_id):
    _generic_remove_question_from_test(request, MultipleChoiceQuestion, test_id, question_id)
    return redirect('admin_add_questions_to_test', test_id)
    
@staff_member_required
def delete_multiple_choice_question(request, question_id):
    _generic_delete_question(request, MultipleChoiceQuestion, question_id)
    return redirect(list_questions)
        
#
# MPCI related
#
    
@staff_member_required
def new_multiple_choice_question_with_image(request):
    return _generic_new_question(request, MultipleChoiceQuestionWithImageForm)
    
@staff_member_required
def edit_multiple_choice_question_with_image(request, question_id):
    return _generic_edit_question(request, MultipleChoiceQuestionWithImageForm, MultipleChoiceQuestionWithImage, question_id)
    
@staff_member_required
def add_multiple_choice_question_with_image_to_test(request, test_id):
    return _generic_add_multiple_choice_question_to_test(request, MultipleChoiceQuestionWithImageForm, test_id)
    
@staff_member_required
def delete_multiple_choice_question_with_image_from_test(request, test_id, question_id):
    _generic_remove_question_from_test(request, MultipleChoiceQuestionWithImage, test_id, question_id)
    return redirect('admin_add_questions_to_test', test_id)
    
@staff_member_required
def delete_multiple_choice_question_with_image(request, question_id):
    _generic_delete_question(request, MultipleChoiceQuestionWithImage, question_id)
    return redirect(list_questions)
    
#
# MPCV related
#
    
@staff_member_required
def new_multiple_choice_question_with_video(request):
    return _generic_new_question(request, MultipleChoiceQuestionWithVideoForm)
    
@staff_member_required
def edit_multiple_choice_question_with_video(request, question_id):
    return _generic_edit_question(request, MultipleChoiceQuestionWithVideoForm, MultipleChoiceQuestionWithVideo, question_id)

@staff_member_required
def add_multiple_choice_question_with_video_to_test(request, test_id):
    return _generic_add_multiple_choice_question_to_test(request, MultipleChoiceQuestionWithVideoForm, test_id)
    
@staff_member_required
def delete_multiple_choice_question_with_video_from_test(request, test_id, question_id):
    _generic_remove_question_from_test(request, MultipleChoiceQuestionWithVideo, test_id, question_id)
    return redirect('admin_add_questions_to_test', test_id)
    
@staff_member_required
def delete_multiple_choice_question_with_video(request, question_id):
    _generic_delete_question(request, MultipleChoiceQuestionWithVideo, question_id)
    return redirect(list_questions)
    
#
# Landmark related
#

@staff_member_required
def add_landmark_question_to_test(request, test_id):
    test = Test.objects.get(id=test_id)
    if request.method == 'POST':
        form = LandmarkQuestionForm(request.POST, request.FILES)
        if form.is_valid():
            question = form.save()
            question.test.add(test)
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
        return redirect('admin_add_questions_to_test', test.id)
    return render(request, 'quiz/admin/draw_landmark.html', {
        "test" : test,
        "question" : question
    })
    
@staff_member_required
def add_landmark_regions(request, test_id, question_id):
    test = Test.objects.get(id=test_id)
    question = LandmarkQuestion.objects.get(id=question_id)
    
@staff_member_required
def delete_landmark_question_from_test(request, test_id, question_id):
    _generic_remove_question_from_test(request, LandmarkQuestion, test_id, question_id)
    return redirect('admin_add_questions_to_test', test_id)