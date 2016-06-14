from django.contrib.auth import authenticate, login, logout
from django.core.exceptions import ObjectDoesNotExist
from django.contrib.auth.decorators import login_required
from django.core.files.base import ContentFile
from django.db import transaction
from django.shortcuts import render, get_object_or_404, redirect
from django.contrib import messages
import base64
import json
import re
import random
import string

from ..models import *
from app.base.models import GlobalSettings

from app.base.views.site import index
   
@login_required
def single_test (request, test_id):
    test = get_object_or_404(Test, pk=test_id)
    already_answered = test.answered_by_user(request.user)
    if already_answered:
        return render(request, 'quiz/site/single_test_answered.html', {
            "answers" : already_answered
        })
    multiple_choice = test.multiple_choice_questions()
    multiple_choice_image = test.multiple_choice_questions_with_image()
    multiple_choice_video = test.multiple_choice_questions_with_video()
    landmark = [question for question in test.landmark_questions() if question.regions()]
    outline = [question for question in test.outline_questions() if question.regions()]
    questions = [multiple_choice, multiple_choice_image, landmark, multiple_choice_video, outline]
    questions = [item for sublist in questions for item in sublist]
    return render(request, 'quiz/site/single_test.html', {
        "test" : test,
        "questions" : questions,
    })

def _get_score(question_type, correct_answer, distance = None):
    if not correct_answer:
        return 0
    settings = GlobalSettings.objects.all().first()
    if question_type == MultipleChoiceQuestion:
        return settings.mpc_points
    elif question_type == MultipleChoiceQuestionWithImage:
        return settings.mpci_points
    elif question_type == MultipleChoiceQuestionWithVideo:
        return settings.mpcv_points
    elif question_type == LandmarkQuestion:
        return settings.landmark_points
    elif question_type == OutlineQuestion:
        if settings.outline_max_threshold < distance:
            return 0
        elif settings.outline_min_threshold > distance:
            return settings.outline_points
        else:
            max = settings.outline_max_threshold
            min = settings.outline_min_threshold
            points = settings.outline_points
            return int((max-distance)/(max-min)*points)

def _add_test_result(question_type, question_id, testresult, answer, max_score):
    test_unit_result = TestUnitResult()
    test_unit_result.test_result = testresult
    test_unit_result.test_unit = question_type.objects.get(id=question_id)
    test_unit_result.correct_answer = test_unit_result.test_unit.correct_answer == answer
    test_unit_result.answer = answer
    test_unit_result.score = _get_score(question_type, test_unit_result.correct_answer)
    test_unit_result.max_score = max_score
    test_unit_result.save()
    
def _json_color_to_rgb(json_color):
    try:
        selected_color = json.loads(json_color)
        red = selected_color["red"]
        green = selected_color["green"]
        blue = selected_color["blue"]
        return '#' + format(red, 'x') + format(green, 'x') + format(blue, 'x')
    except KeyError:
        return None
    
def _colors_match(json_color, target_color):
    return _json_color_to_rgb(json_color) == target_color
    
def _randomword(length):
   return ''.join(random.choice(string.ascii_lowercase) for i in range(length))
        
def _get_answer_image(request, question_id):
    dataUrlPattern = re.compile('data:image/(png|jpeg);base64,(.*)$')
    image_data = request.POST.get('hidden-image-data-' + question_id)
    try:
        image_data = dataUrlPattern.match(image_data).group(2)
    except AttributeError:
        return
    if (image_data == None or len(image_data) == 0):
        return
    image_data = base64.b64decode(image_data)
    return ContentFile(image_data, _randomword(15) + ".png")

@login_required   
@transaction.atomic 
def submit_test(request, test_id):
    if not request.method == 'POST':
        return redirect('/')
    testresult = TestResult()
    testresult.test = get_object_or_404(Test, pk=test_id)
    testresult.user = request.user
    testresult.save()
    settings = GlobalSettings.objects.all().first()
    for testunit_name in request.POST:
        answer = request.POST[testunit_name]
        if testunit_name.startswith("mpc-"):
            question_id = testunit_name.split("-", 1)[1]
            _add_test_result(MultipleChoiceQuestion, question_id, testresult, answer, settings.mpc_points)
        elif testunit_name.startswith("mpci-"):
            question_id = testunit_name.split("-", 1)[1]
            _add_test_result(MultipleChoiceQuestionWithImage, question_id, testresult, answer, settings.mpci_points)
        elif testunit_name.startswith("mpcv-"):
            question_id = testunit_name.split("-", 1)[1]
            _add_test_result(MultipleChoiceQuestionWithVideo, question_id, testresult, answer, settings.mpcv_points)
        elif testunit_name.startswith("landmark_question-"):
            question_id = testunit_name.split("-", 1)[1]
            question_model = LandmarkQuestion.objects.get(id=question_id)
            test_unit_result = TestUnitResult()
            test_unit_result.test_result = testresult
            test_unit_result.test_unit = question_model
            test_unit_result.correct_answer = False
            for k,v in request.POST.items():
                if k == "region-%s-color" % question_model.id:
                    test_unit_result.correct_answer = _colors_match(answer, v)
                    test_unit_result.answer = _json_color_to_rgb(answer)
                    test_unit_result.target_color_region = v
            test_unit_result.answer_image = _get_answer_image(request, question_id)
            test_unit_result.score = _get_score(LandmarkQuestion, test_unit_result.correct_answer)
            test_unit_result.max_score = settings.landmark_points
            test_unit_result.save()
        elif testunit_name.startswith("outline_question-"):
            question_id = testunit_name.split("-", 1)[1]
            question_model = OutlineQuestion.objects.get(id=question_id)
            test_unit_result = TestUnitResult()
            test_unit_result.test_result = testresult
            test_unit_result.test_unit = question_model
            for k,v in request.POST.items():
                if k == "outline_question-%s" % question_model.id:
                    test_unit_result.answer = answer
                elif k == "region-%s-color" % question_model.id:
                    test_unit_result.target_color_region = v
            test_unit_result.answer_image = _get_answer_image(request, question_id)
            test_unit_result.score = _get_score(OutlineQuestion, True, float(answer) if answer else 99999)
            test_unit_result.correct_answer = 0 < test_unit_result.score
            test_unit_result.max_score = settings.outline_points
            test_unit_result.save()
           
    return redirect('/survey/')
    
@login_required
def view_test_result(request, test_result_id):
    test_result = get_object_or_404(TestResult, id=test_result_id)
    test = test_result.test
    user = request.user
    test_unit_results = TestUnitResult.objects.filter(test_result=test_result)
    test_units = TestUnit.objects.filter(test=test)
    return render(request, 'quiz/site/view_test_result.html', {
        "test_unit_results" : test_unit_results,
        "user" : user,
        "test" : test,
        "test_result" : test_result,
        "test_units" : test_units
    })
    
@login_required
def delete_test_result(request, test_result_id):
    try:
        test_result = TestResult.objects.get(id=test_result_id)
        test_result.delete()
        messages.success(request, 'Successfully deleted test result.')
    except ObjectDoesNotExist:
        messages.warning(request, 'The test result has already been deleted. You may have clicked twice.')
    return redirect(index)