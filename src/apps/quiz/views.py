from django.shortcuts import render

from .models import Questionnaire

def index (request):
    questionnaires = Questionnaire.objects.all()
    return render(request, 'questionnaire_list.html', locals())