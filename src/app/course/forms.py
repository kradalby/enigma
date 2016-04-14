from django.forms import ModelForm
from .models import Course

class CourseForm(ModelForm):
    class Meta:
        model = Course
        fields = ['name','participants',]
        
class EditCourseForm(ModelForm):
    class Meta:
        model = Course
        fields = ['name',]