from django.contrib.admin.views.decorators import staff_member_required
from django.shortcuts import render
from django.db import transaction
from django.contrib import messages

from ..forms import GlobalSettingsForm
from ..models import GlobalSettings

@staff_member_required
def index (request):
    return render(request, 'base/admin/index.html')
    
@transaction.atomic
@staff_member_required
def settings(request):
    if request.method == 'POST':
        form = GlobalSettingsForm(request.POST)
        if form.is_valid():
            GlobalSettings.objects.all().delete()
            messages.success(request, 'Successfully updated global settings')
            form.save()
    else:
        instance = GlobalSettings.objects.all().first()
        form = GlobalSettingsForm(instance=instance)

    return render(request, 'base/admin/settings.html',{
        "form" : form
    })