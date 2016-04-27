from django.forms import ModelForm, CharField, IntegerField
from .models import Course

from app.userprofile.views.users import generate_users

class CourseForm(ModelForm):
    #generated_participants_amount = IntegerField(min_value=0)
    #generated_participants_prefix = CharField()
        
    class Meta:
        model = Course
        fields = ['name',]
        
    def clean(self):
        super(CourseForm, self).clean()
        amount = self.cleaned_data.get("generated_participants_amount")
        prefix = self.cleaned_data.get("generated_participants_prefix")
        print("clean %s %s" % (amount, prefix))
        if (not amount or amount > 0) and self._errors.get('generated_participants_amount'):
            del self._errors['generated_participants_amount']
            if not prefix:
                del self._errors['generated_participants_prefix']
        
    def save(self, commit=True):
        amount = self.cleaned_data.get('generated_participants_amount')
        prefix = self.cleaned_data.get('generated_participants_prefix')
        if amount and prefix:
            generate_users(amount, self, prefix)
        return super(CourseForm, self).save(commit=commit)
        
class EditCourseForm(ModelForm):
    class Meta:
        model = Course
        fields = ['name',]
    