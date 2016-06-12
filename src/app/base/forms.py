from django.forms import ModelForm

from .models import GlobalSettings

class GlobalSettingsForm(ModelForm):
    class Meta:
        model = GlobalSettings
        fields = ['mpc_points','mpci_points','mpcv_points','landmark_points','outline_points','outline_min_threshold','outline_max_threshold',]