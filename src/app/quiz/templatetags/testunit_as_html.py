from django import template
from random import shuffle

from ..models import *
    
def multiple_choice_as_html(test_unit):
    html = '<div><ul class="list-group">'
    alternatives = [test_unit.correct_answer, test_unit.wrong_answer_1, test_unit.wrong_answer_2]
    shuffle(alternatives)
    
    for alternative in alternatives:
        html += """
<li class="list-group-item">
    <input type='radio' name='%s' id="%s"/>
    <label for='%s'>%s</label>
    <div class="highlight"></div>
</li>
""" % (test_unit, alternative, alternative, alternative)
    html += "</ul></div>"
    return html
    
def multiple_choice_with_image_as_html(test_unit):
    return "MULTIPLE CHOICE WITH IMAGE!"
    
test_unit_mapping = {
    MultipleChoiceQuestion: multiple_choice_as_html,
    MultipleChoiceQuestionWithImage: multiple_choice_with_image_as_html,
}

register = template.Library()

@register.filter
def as_html(test_unit):
    return test_unit_mapping.get(type(test_unit), type(test_unit))(test_unit)