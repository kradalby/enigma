from django.contrib import admin

from .models import OutlineQuestion, OutlineRegion, OutlineSolutionQuestion


class OutlineQuestionAdmin(admin.ModelAdmin):
    pass


class OutlineRegionAdmin(admin.ModelAdmin):
    pass


class OutlineSolutionQuestionAdmin(admin.ModelAdmin):
    pass


admin.site.register(OutlineQuestion, OutlineQuestionAdmin)
admin.site.register(OutlineRegion, OutlineRegionAdmin)
admin.site.register(OutlineSolutionQuestion, OutlineSolutionQuestionAdmin)
