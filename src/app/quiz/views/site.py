from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.core.files.base import ContentFile
from django.db import transaction
from django.shortcuts import render, get_object_or_404, redirect
import base64
import json
import re
import random
import string

from ..models import *
   
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
    landmark = test.landmark_questions()
    outline = test.outline_questions()
    questions = [multiple_choice, multiple_choice_image, landmark, multiple_choice_video, outline]
    questions = [item for sublist in questions for item in sublist]
    return render(request, 'quiz/site/single_test.html', {
        "test" : test,
        "questions" : questions,
    })

def _add_test_result(question_type, question_id, testresult, answer):
    test_unit_result = TestUnitResult()
    test_unit_result.test_result = testresult
    test_unit_result.test_unit = question_type.objects.get(id=question_id)
    test_unit_result.correct_answer = test_unit_result.test_unit.correct_answer == answer
    test_unit_result.answer = answer
    test_unit_result.save()
    
def _colors_match(json_color, target_color):
    try:
        selected_color = json.loads(json_color)
        red = selected_color["red"]
        green = selected_color["green"]
        blue = selected_color["blue"]
        return '#' + format(red, 'x') + format(green, 'x') + format(blue, 'x') == target_color
    except KeyError:
        return False
    
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
    for testunit_name in request.POST:
        answer = request.POST[testunit_name]
        if testunit_name.startswith("mpc-"):
            question_id = testunit_name.split("-", 1)[1]
            _add_test_result(MultipleChoiceQuestion, question_id, testresult, answer)
        elif testunit_name.startswith("mpci-"):
            question_id = testunit_name.split("-", 1)[1]
            _add_test_result(MultipleChoiceQuestionWithImage, question_id, testresult, answer)
        elif testunit_name.startswith("mpcv-"):
            question_id = testunit_name.split("-", 1)[1]
            _add_test_result(MultipleChoiceQuestionWithVideo, question_id, testresult, answer)
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
            test_unit_result.answer_image = _get_answer_image(request, question_id)
            test_unit_result.save()
        elif testunit_name.startswith("outline_question-"):
            question_id = testunit_name.split("-", 1)[1]
            question_model = OutlineQuestion.objects.get(id=question_id)
            test_unit_result = TestUnitResult()
            test_unit_result.test_result = testresult
            test_unit_result.test_unit = question_model
            test_unit_result.correct_answer = False
            for k,v in request.POST.items():
                if k == "outline_question-%s" % question_model.id:
                    try:
                        result = json.loads(answer)
                        hit = result["pixelsHit"]
                        total = result["pixelsTotal"]
                        test_unit_result.correct_answer = (hit/total > 0.30)
                    except KeyError:
                        test_unit_result.correct_answer = False
            test_unit_result.answer_image = _get_answer_image(request, question_id)
            test_unit_result.save()
           
    return redirect('/')