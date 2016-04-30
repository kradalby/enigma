from django.forms import ModelForm
from .models import *

class TestForm(ModelForm):
    class Meta:
        model = Test
        fields = ["name","course",]
        
class MultipleChoiceQuestionForm(ModelForm):
    class Meta:
        model = MultipleChoiceQuestion
        fields = ["question", "correct_answer", "wrong_answer_1", "wrong_answer_2",]
        
class MultipleChoiceQuestionWithImageForm(ModelForm):
    class Meta:
        model = MultipleChoiceQuestionWithImage
        fields = ["question", "correct_answer", "wrong_answer_1", "wrong_answer_2", "image",]
        
class MultipleChoiceQuestionWithVideoForm(ModelForm):
    class Meta:
        model = MultipleChoiceQuestionWithVideo
        fields = ["question", "correct_answer", "wrong_answer_1", "wrong_answer_2", "video",]
        
class LandmarkQuestionForm(ModelForm):
    class Meta:
        model = LandmarkQuestion
        fields = ["question", "original_image", ]
        
    def __init__(self, *args, **kwargs):
        super(LandmarkQuestionForm, self).__init__(*args, **kwargs)
        self.fields['question'].label = "Name"