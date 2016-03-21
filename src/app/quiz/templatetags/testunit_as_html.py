from django import template
    
register = template.Library()

@register.filter
def as_html(test_unit):
    return test_unit.as_html()