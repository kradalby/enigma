from django.conf.urls import url, include

from .views import api

from rest_framework import routers

router = routers.DefaultRouter()
router.register(r'user', api.UserViewSet)
router.register(r'userprofile', api.UserProfileViewSet)
router.register(r'usergroup', api.UserGroupViewSet)


urlpatterns = [
    url(r'^', include(router.urls)),
]
