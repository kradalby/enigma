from django.forms import ModelForm

from .models import (GenericImage, LandmarkQuestion, MultipleChoiceQuestion,
                     MultipleChoiceQuestionWithImage,
                     MultipleChoiceQuestionWithVideo, OutlineQuestion,
                     OutlineSolutionQuestion, Test, Rating)


class TestForm(ModelForm):
    class Meta:
        model = Test
        fields = [
            'name',
            'course',
            'user_can_see_test_result',
            'user_can_delete_test_result',
        ]


class MultipleChoiceQuestionForm(ModelForm):
    class Meta:
        model = MultipleChoiceQuestion
        fields = [
            'question',
            'correct_answer',
            'wrong_answer_1',
            'wrong_answer_2',
        ]


class MultipleChoiceQuestionWithImageForm(ModelForm):
    class Meta:
        model = MultipleChoiceQuestionWithImage
        fields = [
            'question',
            'correct_answer',
            'wrong_answer_1',
            'wrong_answer_2',
            'image',
        ]


class MultipleChoiceQuestionWithVideoForm(ModelForm):
    class Meta:
        model = MultipleChoiceQuestionWithVideo
        fields = [
            'question',
            'correct_answer',
            'wrong_answer_1',
            'wrong_answer_2',
            'video',
        ]


class LandmarkQuestionForm(ModelForm):
    class Meta:
        model = LandmarkQuestion
        fields = [
            'question',
            'original_image',
        ]

    def __init__(self, *args, **kwargs):
        super(LandmarkQuestionForm, self).__init__(*args, **kwargs)

        self.fields['question'].label = 'Name'
        self.fields['question'].required = False


class OutlineQuestionForm(ModelForm):
    class Meta:
        model = OutlineQuestion
        fields = [
            'question',
            'original_image',
        ]

    def __init__(self, *args, **kwargs):

        super(OutlineQuestionForm, self).__init__(*args, **kwargs)
        self.fields['question'].label = 'Name'
        self.fields['question'].required = False


class OutlineSolutionQuestionForm(ModelForm):
    class Meta:
        model = OutlineSolutionQuestion
        fields = [
            'question',
            'outline_region',
            'original_image',
        ]

    def __init__(self, *args, **kwargs):
        super(OutlineSolutionQuestionForm, self).__init__(*args, **kwargs)
        self.fields['question'].label = 'Name'


class GenericImageForm(ModelForm):
    class Meta:
        model = GenericImage
        fields = ['image', 'name', 'machine']

    def __init__(self, *args, **kwargs):
        super(GenericImageForm, self).__init__(*args, **kwargs)
        self.fields['image'].label = 'Image'
        self.fields['name'].label = 'Name'
        self.fields['machine'].label = 'Modalitet'


class RatingForm(ModelForm):
    class Meta:
        model = Rating
        fields = ['rating']
