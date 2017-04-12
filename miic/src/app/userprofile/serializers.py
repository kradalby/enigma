from django.contrib.auth.models import User
from rest_framework import serializers

from .models import UserGroup, UserProfile


class UserSerializer(serializers.HyperlinkedModelSerializer):

    class Meta:
        model = User
        field = '__all__'


class UserGroupSerializer(serializers.HyperlinkedModelSerializer):

    class Meta:
        model = UserGroup
        field = '__all__'


class UserProfileSerializer(serializers.HyperlinkedModelSerializer):

    class Meta:
        model = UserProfile
        field = '__all__'
