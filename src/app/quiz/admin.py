from django.contrib import admin

from .models import OutlineQuestion, OutlineRegion, OutlineSolutionQuestion, Test, TestResult, TestUnit, MultipleChoiceQuestion, MultipleChoiceQuestionWithImage, MultipleChoiceQuestionWithVideo, LandmarkQuestion, LandmarkRegion, TestUnitResult


class OutlineQuestionAdmin(admin.ModelAdmin):
    pass


class OutlineRegionAdmin(admin.ModelAdmin):
    pass


class OutlineSolutionQuestionAdmin(admin.ModelAdmin):
    pass


admin.site.register(OutlineQuestion, OutlineQuestionAdmin)
admin.site.register(OutlineRegion, OutlineRegionAdmin)
admin.site.register(OutlineSolutionQuestion, OutlineSolutionQuestionAdmin)


class TestAdmin(admin.ModelAdmin):
    pass


admin.site.register(Test, TestAdmin)


class TestResultAdmin(admin.ModelAdmin):
    pass


admin.site.register(TestResult, TestResultAdmin)


class TestUnitAdmin(admin.ModelAdmin):
    pass


admin.site.register(TestUnit, TestUnitAdmin)


class MultipleChoiceQuestionAdmin(admin.ModelAdmin):
    pass


admin.site.register(MultipleChoiceQuestion, MultipleChoiceQuestionAdmin)


class MultipleChoiceQuestionWithImageAdmin(admin.ModelAdmin):
    pass


admin.site.register(MultipleChoiceQuestionWithImage,
                    MultipleChoiceQuestionWithImageAdmin)


class MultipleChoiceQuestionWithVideoAdmin(admin.ModelAdmin):
    pass


admin.site.register(MultipleChoiceQuestionWithVideo,
                    MultipleChoiceQuestionWithVideoAdmin)


class LandmarkQuestionAdmin(admin.ModelAdmin):
    pass


admin.site.register(LandmarkQuestion, LandmarkQuestionAdmin)


class LandmarkRegionAdmin(admin.ModelAdmin):
    pass


admin.site.register(LandmarkRegion, LandmarkRegionAdmin)


class TestUnitResultAdmin(admin.ModelAdmin):
    pass


admin.site.register(TestUnitResult, TestUnitResultAdmin)