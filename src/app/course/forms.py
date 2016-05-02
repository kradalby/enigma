from django.contrib import messages
from django.forms import ModelForm, CharField, IntegerField

from .util import generate_users_for_course
from .models import Course

class CourseForm(ModelForm):
    generated_participants_amount = IntegerField(min_value=0)
    generated_participants_prefix = CharField()
        
    class Meta:
        model = Course
        fields = ['name',]
        
    def clean(self):
        super(CourseForm, self).clean()
        amount = self.cleaned_data.get("generated_participants_amount")
        prefix = self.cleaned_data.get("generated_participants_prefix")
        print("amount %s" % amount)
        print("prefix %s" % prefix)
        if (not amount or amount == 0) and self._errors.get('generated_participants_amount'):
            del self._errors['generated_participants_amount']
        if not prefix and self._errors.get('generated_participants_prefix'):
            del self._errors['generated_participants_prefix']
        if amount and amount > 0 and not prefix:
            self.add_error(None, "Generated participants prefix and amount have to be specified together")
        print(self._errors)
        
    def save(self, commit=True):
        amount = self.cleaned_data.get('generated_participants_amount')
        prefix = self.cleaned_data.get('generated_participants_prefix')
        saved_instance = super(CourseForm, self).save(commit=commit)
        if amount and prefix:
            generate_users_for_course(saved_instance, prefix, amount)
        return saved_instance
        
class EditCourseForm(ModelForm):
    class Meta:
        model = Course
        fields = ['name',]
    