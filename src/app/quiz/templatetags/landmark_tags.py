import random
from django import template
register = template.Library()

from ..models import LandmarkQuestion

@register.filter
def is_landmark(test):
    return type(test) is LandmarkQuestion
    
@register.filter
def get_random_region(landmark_question):
    return random.choice(landmark_question.regions())