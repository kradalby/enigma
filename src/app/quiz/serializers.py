from rest_framework import serializers

from .models import (LandmarkQuestion, LandmarkRegion, MultipleChoiceQuestion,
                     MultipleChoiceQuestionWithImage,
                     MultipleChoiceQuestionWithVideo, OutlineQuestion,
                     OutlineRegion, OutlineSolutionQuestion, Test, TestResult,
                     TestUnit, TestUnitResult)


class WrongAnswerListField(serializers.ListField):
    child = serializers.CharField(max_length=255)


class MultipleChoiceQuestionSerializer(serializers.Serializer):
    pk = serializers.IntegerField()
    correct_answer = serializers.CharField(max_length=255)
    wrong_answers = WrongAnswerListField()


class MultipleChoiceQuestionWithImageSerializer(
        MultipleChoiceQuestionSerializer):
    image = serializers.URLField()


class MultipleChoiceQuestionWithVideoSerializer(
        MultipleChoiceQuestionSerializer):
    video = serializers.URLField()


class LandmarkRegionSerializer(serializers.Serializer):
    color = serializers.CharField(max_length=50)
    name = serializers.CharField(max_length=255)


class LandmarkQuestionSerializer(serializers.Serializer):
    question = serializers.CharField(max_length=255)
    original_image = serializers.URLField()
    landmark_drawing = serializers.URLField()
    landmark_regions = LandmarkRegionSerializer(many=True, read_only=True)


class OutlineRegionSerializer(serializers.Serializer):
    color = serializers.CharField(max_length=50)
    name = serializers.CharField(max_length=255)


class OutlineQuestionSerializer(serializers.Serializer):
    original_image = serializers.URLField()
    outline_drawing = serializers.URLField()
    outline_regions = OutlineRegionSerializer(many=True, read_only=True)
