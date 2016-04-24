from django.contrib.auth.models import User
from django.core.validators import validate_slug
from django.forms import ModelForm, TextInput, CharField

from .models import UserProfile, UserGroup

class UserProfileForm(ModelForm):
    username = CharField()
    
    class Meta:
        model = UserProfile
        exclude = ["groups", "user",]
        
    def save(self, commit=True):
        user = User()
        user.username = self.cleaned_data['username']
        user.set_password("question")
        user.save()
        self.instance.user = user
        return super(UserProfileForm, self).save(commit=commit)
        
class UserGroupForm(ModelForm):
    class Meta:
        model = UserGroup
        fields = ["name",]