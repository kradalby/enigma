from django.conf.urls.static import static
from django.conf.urls import include, url
from django.conf import settings
from django.contrib.auth import views as auth_views
from django.contrib import admin
from app.course.views import api as course_api
from app.quiz.views import api as quiz_api
from app.userprofile.views import api as userprofile_api

from rest_framework import routers

router = routers.DefaultRouter()
router.register(r'course', course_api.CourseViewSet)

router.register(r'quiz/test', quiz_api.TestViewSet)
router.register(r'quiz/testresult', quiz_api.TestResultViewSet)
# router.register(r'quiz/testunit', quiz_api.TestUnitViewSet)
router.register(r'quiz/testunitresult', quiz_api.TestUnitResultViewSet)
router.register(r'quiz/mcq', quiz_api.MultipleChoiceQuestionViewSet)
router.register(r'quiz/mcq/image',
                quiz_api.MultipleChoiceQuestionWithImageViewSet)
router.register(r'quiz/mcq/video',
                quiz_api.MultipleChoiceQuestionWithVideoViewSet)
router.register(r'quiz/landmarkquestion', quiz_api.LandmarkQuestionViewSet)
router.register(r'quiz/landmarkregion', quiz_api.LandmarkRegionViewSet)
router.register(r'quiz/outline/question', quiz_api.OutlineQuestionViewSet)
router.register(r'quiz/outline/region', quiz_api.OutlineRegionViewSet)
router.register(r'quiz/outline/solution',
                quiz_api.OutlineSolutionQuestionViewSet)

router.register(r'userprofile/user', userprofile_api.UserViewSet)
router.register(r'userprofile/userprofile', userprofile_api.UserProfileViewSet)
router.register(r'userprofile/usergroup', userprofile_api.UserGroupViewSet)

urlpatterns = [
    url(r'^', include('app.base.urls')),
    url(r'^test/', include('app.quiz.urls')),
    url(r'^course/', include('app.course.urls')),
    url(r'^profile/', include('app.userprofile.urls')),
    url(r'^accounts/login/$', auth_views.login, name='login'),
    url(r'^accounts/logout/$', auth_views.logout, name='logout'),
    url(r'^api/', include(router.urls)),

]

urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)

if settings.DEBUG:
    urlpatterns.append(url(r'^djangoadmin/', include(admin.site.urls)))
