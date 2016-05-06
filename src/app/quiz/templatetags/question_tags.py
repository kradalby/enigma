import random
from django import template
register = template.Library()

from ..models import *

question_types = {
    LandmarkQuestion : "Landmark questions",
    MultipleChoiceQuestion : "Multiple choice questions",
    MultipleChoiceQuestionWithImage : "Multiple choice questions with image",
    MultipleChoiceQuestionWithVideo : "Multiple choice questions with video"
}

@register.filter
def question_type(question):
    return question_types.get(type(question),"Questions")
    
question_type_ids = [
    None,
    MultipleChoiceQuestion,
    MultipleChoiceQuestionWithImage,
    MultipleChoiceQuestionWithVideo,
    LandmarkQuestion
]

@register.filter
def question_type_id(question):
    return question_type_ids.index(type(question))

@register.filter
def question_type_from_id(question_id):
    return question_type_ids[int(question_id)]

@register.filter
def is_landmark(test):
    return type(test) is LandmarkQuestion
    
@register.filter
def is_outline(test):
    return type(test) is OutlineQuestion
    
@register.filter
def get_random_region(question):
    return random.choice(question.regions())