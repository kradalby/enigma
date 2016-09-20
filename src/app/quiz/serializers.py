from rest_framework import serializers

from .models import (Test,
                     TestResult,
                     TestUnit,
                     TestUnitResult,
                     MultipleChoiceQuestion,
                     MultipleChoiceQuestionWithImage,
                     MultipleChoiceQuestionWithVideo,
                     LandmarkQuestion,
                     LandmarkRegion,
                     OutlineQuestion,
                     OutlineRegion,
                     OutlineSolutionQuestion)


class TestResultSerializer(serializers.HyperlinkedModelSerializer):

    class Meta:
        model = TestResult
        field = '__all__'


class TestUnitSerializer(serializers.HyperlinkedModelSerializer):

    class Meta:
        model = TestUnit
        field = '__all__'


class TestUnitResultSerializer(serializers.HyperlinkedModelSerializer):

    class Meta:
        model = TestUnitResult
        field = '__all__'


class MultipleChoiceQuestionSerializer(serializers.HyperlinkedModelSerializer):

    class Meta:
        model = MultipleChoiceQuestion
        field = '__all__'


class MultipleChoiceQuestionWithImageSerializer(serializers.HyperlinkedModelSerializer):

    class Meta:
        model = MultipleChoiceQuestionWithImage
        field = '__all__'


class MultipleChoiceQuestionWithVideoSerializer(serializers.HyperlinkedModelSerializer):

    class Meta:
        model = MultipleChoiceQuestionWithVideo
        field = '__all__'


class LandmarkQuestionSerializer(serializers.HyperlinkedModelSerializer):

    class Meta:
        model = LandmarkQuestion
        field = '__all__'


class LandmarkRegionSerializer(serializers.HyperlinkedModelSerializer):

    class Meta:
        model = LandmarkRegion
        field = '__all__'


class OutlineQuestionSerializer(serializers.HyperlinkedModelSerializer):

    class Meta:
        model = OutlineQuestion
        field = '__all__'


class OutlineRegionSerializer(serializers.HyperlinkedModelSerializer):

    class Meta:
        model = OutlineRegion
        field = '__all__'


class OutlineSolutionQuestionSerializer(serializers.HyperlinkedModelSerializer):

    class Meta:
        model = OutlineSolutionQuestion
        field = '__all__'
