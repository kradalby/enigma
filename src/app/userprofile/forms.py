from django.contrib.auth.models import User
from django.core.exceptions import ObjectDoesNotExist
from django.core.validators import validate_slug
from django.forms import ModelForm, TextInput, CharField

from .models import UserProfile, UserGroup

class UserProfileForm(ModelForm):
    username = CharField()
    
    def __init__(self, *args, **kwargs):
        super(UserProfileForm, self).__init__(*args, **kwargs)
        try:
            self.fields['username'].initial = self.instance.user.username
        except User.DoesNotExist:
            pass

    class Meta:
        model = UserProfile
        exclude = ["groups", "user",]
        
    def save(self, commit=True):
        user = User()
        user.username = self.cleaned_data['username']
        user.set_password("question")
        if commit:
            user.save()
            try:
                UserProfile.objects.get(id=self.instance.id).delete()
            except ObjectDoesNotExist:
                pass
        self.instance.user = user
        return super(UserProfileForm, self).save(commit=commit)
        
class UserGroupForm(ModelForm):
    class Meta:
        model = UserGroup
        fields = ["name",]