import random
from django import template
register = template.Library()

from ..models import Test

@register.assignment_tag(takes_context=True)
def has_been_answered(context, test):
    user = context['request'].user
    return test.answered_by_user(user)