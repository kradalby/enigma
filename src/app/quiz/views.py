from django.shortcuts import render, get_object_or_404, redirect

from .models import *

def index (request):
    tests = Test.objects.all()
    return render(request, 'test_list.html', {
        "tests" : tests
    })
    
def single_test (request, test_id):
    test = get_object_or_404(Test, pk=test_id)
    multiple_choice = test.multiple_choice_questions.all()
    multiple_choice_image = test.multiple_choice_questions_with_image.all()
    landmark = test.landmark_questions.all()
    questions = [multiple_choice, multiple_choice_image, landmark]
    questions = [item for sublist in questions for item in sublist]
    return render(request, 'single_test.html', {
        "test" : test,
        "questions" : questions
    })
    
def submit_test(request, test_id):
    if not request.method == 'POST':
        return redirect('/')
    test = get_object_or_404(Test, pk=test_id)
    return redirect('/')
