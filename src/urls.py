from django.conf import settings
from django.conf.urls import include, url
from django.conf.urls.static import static
from django.contrib import admin
from django.contrib.auth import views as auth_views
from rest_framework import routers

from app.course.views import api as course_api
from app.quiz.views import api as quiz_api
from app.userprofile.views import api as userprofile_api

router = routers.DefaultRouter()
router.register(
    r'quiz/mcq', quiz_api.MultipleChoiceQuestionViewSet, base_name='quiz/mcq')
router.register(
    r'quiz/mcq_image',
    quiz_api.MultipleChoiceQuestionWithImageViewSet,
    base_name='quiz/mcq_image/')
router.register(
    r'quiz/mcq_video',
    quiz_api.MultipleChoiceQuestionWithVideoViewSet,
    base_name='quiz/mcq_video/')
router.register(
    r'quiz/mcq_all',
    quiz_api.MultipleChoiceQuestionAllViewSet,
    base_name='quiz/mcq_all/')
router.register(
    r'quiz/landmarkquestion',
    quiz_api.LandmarkQuestionViewSet,
    base_name='quiz/landmarkquestion/')
router.register(
    r'quiz/outlinequestion',
    quiz_api.OutlineQuestionViewSet,
    base_name='quiz/outlinequestion')

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
