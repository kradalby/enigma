import random
from django import template
from django.core.exceptions import ObjectDoesNotExist
register = template.Library()

from ..models import *

question_types = {
    LandmarkQuestion: "Landmark questions",
    MultipleChoiceQuestion: "Multiple choice questions",
    MultipleChoiceQuestionWithImage: "Multiple choice questions with image",
    MultipleChoiceQuestionWithVideo: "Multiple choice questions with video",
    OutlineQuestion: "Outline questions",
    OutlineSolutionQuestion: "Outline solution question"
}


@register.filter
def question_type(question):
    return question_types.get(type(question), "Questions")

question_type_ids = [
    None,
    MultipleChoiceQuestion,
    MultipleChoiceQuestionWithImage,
    MultipleChoiceQuestionWithVideo,
    LandmarkQuestion,
    OutlineQuestion,
    OutlineSolutionQuestion
]


@register.filter
def question_type_id(question):
    return question_type_ids.index(type(question))


@register.filter
def question_type_from_id(question_id):
    return question_type_ids[int(question_id)]


@register.filter
def is_landmark(test):
    if type(test) is LandmarkQuestion:
        return True
    try:
        return type(test) is TestUnit and test.landmarkquestion
    except ObjectDoesNotExist:
        pass
    return False


@register.filter
def is_outline(test):
    if type(test) is OutlineQuestion:
        return True
    try:
        return type(test) is TestUnit and test.outlinequestion
    except ObjectDoesNotExist:
        pass
    return False


@register.filter
def is_outline_solution_question(test):
    if type(test) is OutlineSolutionQuestion:
        return True
    try:
        return type(test) is TestUnit and test.outlinesolutionquestion
    except ObjectDoesNotExist:
        pass
    return False


@register.filter
def is_multiple_choice_question(test):
    if type(test) is MultipleChoiceQuestion:
        return True
    try:
        return type(test) is TestUnit and test.multiplechoicequestion
    except ObjectDoesNotExist:
        pass
    return False


@register.filter
def is_multiple_choice_question_with_image(test):
    if type(test) is MultipleChoiceQuestionWithImage:
        return True
    try:
        return type(test) is TestUnit and test.multiplechoicequestionwithimage
    except ObjectDoesNotExist:
        pass
    return False


@register.filter
def is_multiple_choice_question_with_video(test):
    if type(test) is MultipleChoiceQuestionWithVideo:
        return True
    try:
        return type(test) is TestUnit and test.multiplechoicequestionwithvideo
    except ObjectDoesNotExist:
        pass
    return False


@register.filter
def get_random_region(question):
    return random.choice(question.regions())
