from django.forms import CharField, Form, ModelForm, PasswordInput

from .models import GlobalSettings


class GlobalSettingsForm(ModelForm):

    class Meta:
        model = GlobalSettings
        fields = [
            'mpc_points',
            'mpci_points',
            'mpcv_points',
            'landmark_points',
            'outline_solution_points',
            'outline_points',
            'outline_min_threshold',
            'outline_max_threshold',
        ]


class ChangePasswordForm(Form):
    password = CharField(widget=PasswordInput(), label='New password')
    verify_password = CharField(widget=PasswordInput(), label='Once more')
