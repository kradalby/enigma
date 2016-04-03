from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required

from ..models import *

@login_required
def index (request):
    tests = Test.objects.all()
    return render(request, 'quiz/site/test_list.html', {
        "tests" : tests
    })
   
@login_required
def single_test (request, test_id):
    test = get_object_or_404(Test, pk=test_id)
    already_answered = test.answered_by_user(request.user)
    multiple_choice = test.multiple_choice_questions()
    multiple_choice_image = test.multiple_choice_questions_with_image()
    landmark = test.landmark_questions()
    questions = [multiple_choice, multiple_choice_image, landmark]
    questions = [item for sublist in questions for item in sublist]
    print(already_answered)
    return render(request, 'quiz/site/single_test.html', {
        "test" : test,
        "questions" : questions,
        "answers" : already_answered
    })

def _add_test_result(question_type, question, testresult, answer):
    test_unit_result = TestUnitResult()
    test_unit_result.test_result = testresult
    test_unit_result.test_unit = question_type.objects.get(question=question)
    test_unit_result.correct_answer = test_unit_result.test_unit.correct_answer == answer
    test_unit_result.save()

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
            question = testunit_name.split("-", 1)[1]
            _add_test_result(MultipleChoiceQuestion, question, testresult, answer)
        elif testunit_name.startswith("mpci-"):
            question = testunit_name.split("-", 1)[1]
            _add_test_result(MultipleChoiceQuestionWithImage, question, testresult, answer)
        elif testunit_name.startswith("landmark-"):
            question = testunit_name.split("-", 1)[1]
            test_unit_result = TestUnitResult()
            test_unit_result.test_result = testresult
            test_unit_result.test_unit = LandmarkQuestion.objects.get(question=question)
            test_unit_result.correct_answer = answer != None and answer != "{}"
            test_unit_result.save()
           
    return redirect('/')