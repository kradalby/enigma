from django.conf.urls import url, include

from .views import api

from rest_framework import routers

router = routers.DefaultRouter()
router.register(r'', api.CourseViewSet)


urlpatterns = [
    url(r'^', include(router.urls)),
]
