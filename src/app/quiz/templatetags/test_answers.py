from django import template
register = template.Library()


@register.assignment_tag(takes_context=True)
def has_been_answered(context, test):
    user = context['request'].user
    return test.answered_by_user(user)


@register.filter
def answered_by_user(test, user):
    return test.answered_by_user(user.user)


@register.filter
def score_fraction(test_result):
    return test_result.score_fraction()
