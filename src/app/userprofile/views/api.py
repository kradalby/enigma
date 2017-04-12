from django.contrib.auth.models import User
from rest_framework import viewsets

from ..models import UserGroup, UserProfile
from ..serializers import (UserGroupSerializer, UserProfileSerializer,
                           UserSerializer)


class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer


class UserGroupViewSet(viewsets.ModelViewSet):
    queryset = UserGroup.objects.all()
    serializer_class = UserGroupSerializer


class UserProfileViewSet(viewsets.ModelViewSet):
    queryset = UserProfile.objects.all()
    serializer_class = UserProfileSerializer
