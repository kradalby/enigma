from rest_framework import serializers

from .models import (LandmarkQuestion, LandmarkRegion, MultipleChoiceQuestion,
                     MultipleChoiceQuestionWithImage,
                     MultipleChoiceQuestionWithVideo, OutlineQuestion,
                     OutlineRegion, OutlineSolutionQuestion, Test, TestResult,
                     TestUnit, TestUnitResult)


class TestSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Test
        field = '__all__'


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


# class MultipleChoiceQuestionSerializer(serializers.HyperlinkedModelSerializer):

#     class Meta:
#         model = MultipleChoiceQuestion
#         field = '__all__'

# class MultipleChoiceQuestionWithImageSerializer(serializers.HyperlinkedModelSerializer):

#     class Meta:
#         model = MultipleChoiceQuestionWithImage
#         field = '__all__'

# class MultipleChoiceQuestionWithVideoSerializer(serializers.HyperlinkedModelSerializer):

#     class Meta:
#         model = MultipleChoiceQuestionWithVideo
#         field = '__all__'

# class LandmarkRegionSerializer(serializers.HyperlinkedModelSerializer):

#     class Meta:
#         model = LandmarkRegion
#         field = '__all__'
#         depth = 1


class OutlineQuestionSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = OutlineQuestion
        field = '__all__'


class OutlineRegionSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = OutlineRegion
        field = '__all__'


class OutlineSolutionQuestionSerializer(
        serializers.HyperlinkedModelSerializer):
    class Meta:
        model = OutlineSolutionQuestion
        field = '__all__'


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
