from django.contrib import admin

from .models import *

admin.site.register(Test)
admin.site.register(MultipleChoiceQuestion)
admin.site.register(MultipleChoiceQuestionWithImage)
admin.site.register(LandmarkQuestion)