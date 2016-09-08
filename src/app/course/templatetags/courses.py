from django import template

register = template.Library()

from ..models import Course

@register.filter(name='courses_attending')
def courses_attending(user):
    '''
    Returns all courses a user is attending
    '''
    return Course.objects.filter(groups__in=user.groups.all())