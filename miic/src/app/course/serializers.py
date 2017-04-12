from rest_framework import serializers

from .models import Course


class CourseSerializer(serializers.HyperlinkedModelSerializer):

    class Meta:
        model = Course
        field = '__all__'
