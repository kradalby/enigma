from ..models import Course
from django import template

register = template.Library()


@register.filter(name='courses_attending')
def courses_attending(user):
    '''
    Returns all courses a user is attending
    '''
    return Course.objects.filter(groups__in=user.groups.all())
