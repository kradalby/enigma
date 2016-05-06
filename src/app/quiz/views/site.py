from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
import json

from ..models import *
   
@login_required
def single_test (request, test_id):
    test = get_object_or_404(Test, pk=test_id)
    already_answered = test.answered_by_user(request.user)
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
        "answers" : already_answered
    })

def _add_test_result(question_type, question_id, testresult, answer):
    test_unit_result = TestUnitResult()
    test_unit_result.test_result = testresult
    test_unit_result.test_unit = question_type.objects.get(id=question_id)
    test_unit_result.correct_answer = test_unit_result.test_unit.correct_answer == answer
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

@login_required    
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
            for k,v in request.POST.items():
                if k == "landmark_region-%s" % question_model.id:
                    region = question_model.regions().get(color=v)
                    test_unit_result.correct_answer = _colors_match(answer, v)
            test_unit_result.save()
           
    return redirect('/')