from django.contrib import admin
from django.contrib.auth.models import Group, User

admin.site.unregister(Group)
admin.site.unregister(User)

from .models import *

admin.site.register(Test)

#admin.site.register(TestResult)
#admin.site.register(TestUnitResult)