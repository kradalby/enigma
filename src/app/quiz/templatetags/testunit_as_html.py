from django import template

from ..models import *
    
def multiple_choice_as_html(test_unit):
    return "MULTIPLE CHOICE!"
    
def multiple_choice_with_image_as_html(test_unit):
    return "MULTIPLE CHOICE WITH IMAGE!"
    
test_unit_mapping = {
    MultipleChoiceQuestion: multiple_choice_as_html,
    MultipleChoiceQuestionWithImage: multiple_choice_with_image_as_html,
}

register = template.Library()

@register.filter
def as_html(test_unit):
    return test_unit_mapping.get(type(test_unit), type(test_unit))