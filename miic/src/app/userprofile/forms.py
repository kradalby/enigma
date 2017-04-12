from django.contrib.auth.models import User
from django.core.exceptions import ObjectDoesNotExist
from django.forms import CharField, IntegerField, ModelForm, EmailField

from .models import UserGroup, UserProfile
from .util import generate_users


class UserProfileForm(ModelForm):
    username = CharField()
    email = EmailField()

    def __init__(self, *args, **kwargs):
        super(UserProfileForm, self).__init__(*args, **kwargs)
        try:
            self.fields['username'].initial = self.instance.user.username
            self.fields['email'].initial = self.instance.user.email
        except User.DoesNotExist:
            pass

    class Meta:
        model = UserProfile
        fields = ['username']

    def save(self, commit=True):
        user = User()
        user.username = self.cleaned_data['username']
        user.email = self.cleaned_data['email']
        user.set_password(user.username)
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
        fields = [
            "name",
        ]

    generated_participants_amount = IntegerField(min_value=0)
    generated_participants_prefix = CharField()

    def clean(self):
        super(UserGroupForm, self).clean()
        amount = self.cleaned_data.get("generated_participants_amount")
        prefix = self.cleaned_data.get("generated_participants_prefix")
        if (not amount or amount == 0
            ) and self._errors.get('generated_participants_amount'):
            del self._errors['generated_participants_amount']
        if not prefix and self._errors.get('generated_participants_prefix'):
            del self._errors['generated_participants_prefix']
        if amount and amount > 0 and not prefix:
            self.add_error(
                None,
                "Generated participants prefix and amount have to be specified together"
            )

    def save(self, commit=True):
        amount = self.cleaned_data.get('generated_participants_amount')
        prefix = self.cleaned_data.get('generated_participants_prefix')
        self.instance.prefix = prefix if prefix else self.instance.name
        saved_instance = super(UserGroupForm, self).save(commit=commit)
        if amount and prefix:
            generate_users(amount, saved_instance, prefix)
        return saved_instance
