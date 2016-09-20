from django.conf.urls import url, include

from .views import api

from rest_framework import routers

router = routers.DefaultRouter()
router.register(r'test', api.TestViewSet)
router.register(r'testresult', api.TestResultViewSet)
router.register(r'testunit', api.TestUnitViewSet)
router.register(r'testunitresult', api.TestUnitResultViewSet)
router.register(r'mcq', api.MultipleChoiceQuestionViewSet)
router.register(r'mcq/image', api.MultipleChoiceQuestionWithImageViewSet)
router.register(r'mcq/video', api.MultipleChoiceQuestionWithVideoViewSet)
router.register(r'landmarkquestion', api.LandmarkQuestionViewSet)
router.register(r'landmarkregion', api.LandmarkRegionViewSet)
router.register(r'outline/question', api.OutlineQuestionViewSet)
router.register(r'outline/region', api.OutlineRegionViewSet)
router.register(r'outline/solution', api.OutlineSolutionQuestionViewSet)

urlpatterns = [
    url(r'^', include(router.urls)),
]
