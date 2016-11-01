from django.shortcuts import get_object_or_404
from rest_framework import viewsets
from rest_framework.response import Response

from ..models import (LandmarkQuestion, LandmarkRegion, MultipleChoiceQuestion,
                      MultipleChoiceQuestionWithImage,
                      MultipleChoiceQuestionWithVideo, OutlineQuestion,
                      OutlineRegion, OutlineSolutionQuestion, Test, TestResult,
                      TestUnit, TestUnitResult)
from ..serializers import (
    LandmarkQuestionSerializer, LandmarkRegionSerializer,
    MultipleChoiceQuestionSerializer,
    MultipleChoiceQuestionWithImageSerializer,
    MultipleChoiceQuestionWithVideoSerializer, OutlineQuestionSerializer,
    OutlineRegionSerializer, OutlineSolutionQuestionSerializer,
    TestResultSerializer, TestSerializer, TestUnitResultSerializer,
    TestUnitSerializer)


class TestViewSet(viewsets.ModelViewSet):
    queryset = Test.objects.all()
    serializer_class = TestSerializer


class TestResultViewSet(viewsets.ModelViewSet):
    queryset = TestResult.objects.all()
    serializer_class = TestResultSerializer


class TestUnitViewSet(viewsets.ModelViewSet):
    queryset = TestUnit.objects.all()
    serializer_class = TestUnitSerializer


class TestUnitResultViewSet(viewsets.ModelViewSet):
    queryset = TestUnitResult.objects.all()
    serializer_class = TestUnitResultSerializer


# class MultipleChoiceQuestionViewSet(viewsets.ModelViewSet):
#     queryset = MultipleChoiceQuestion.objects.all()
#     serializer_class = MultipleChoiceQuestionSerializer

# class MultipleChoiceQuestionWithImageViewSet(viewsets.ModelViewSet):
#     queryset = MultipleChoiceQuestionWithImage.objects.all()
#     serializer_class = MultipleChoiceQuestionWithImageSerializer

# class MultipleChoiceQuestionWithVideoViewSet(viewsets.ModelViewSet):
#     queryset = MultipleChoiceQuestionWithVideo.objects.all()
#     serializer_class = MultipleChoiceQuestionWithVideoSerializer


class OutlineQuestionViewSet(viewsets.ModelViewSet):
    queryset = OutlineQuestion.objects.all()
    serializer_class = OutlineQuestionSerializer


class OutlineRegionViewSet(viewsets.ModelViewSet):
    queryset = OutlineRegion.objects.all()
    serializer_class = OutlineRegionSerializer


class OutlineSolutionQuestionViewSet(viewsets.ModelViewSet):
    queryset = OutlineSolutionQuestion.objects.all()
    serializer_class = OutlineSolutionQuestionSerializer


class MultipleChoiceQuestionViewSet(viewsets.ViewSet):
    def list(self, request):
        queryset = map(
            lambda mcq: {
                'pk': mcq.pk,
                'correct_answer': mcq.correct_answer,
                'wrong_answers': [
                    mcq.wrong_answer_1,
                    mcq.wrong_answer_2
                    ]},
                    MultipleChoiceQuestion.objects.all()
                    )
        serializer = MultipleChoiceQuestionSerializer(queryset, many=True)
        return Response(serializer.data)

    def retrieve(self, request, pk=None):
        mcq = get_object_or_404(MultipleChoiceQuestion, pk=pk)
        mcq_transformed = {
            'pk': mcq.pk,
            'correct_answer': mcq.correct_answer,
            'wrong_answers': [mcq.wrong_answer_1, mcq.wrong_answer_2]
        }
        serializer = MultipleChoiceQuestionSerializer(mcq_transformed)
        return Response(serializer.data)


class MultipleChoiceQuestionWithImageViewSet(viewsets.ViewSet):
    def list(self, request):
        queryset = map(
            lambda mcq: {
                'pk': mcq.pk,
                'correct_answer': mcq.correct_answer,
                'wrong_answers': [
                    mcq.wrong_answer_1,
                    mcq.wrong_answer_2
                ],
                'image': mcq.image.url
            },
            MultipleChoiceQuestionWithImage.objects.all()
        )
        serializer = MultipleChoiceQuestionWithImageSerializer(
            queryset, many=True)
        return Response(serializer.data)

    def retrieve(self, request, pk=None):
        mcq = get_object_or_404(MultipleChoiceQuestionWithImage, pk=pk)
        mcq_transformed = {
            'pk': mcq.pk,
            'correct_answer': mcq.correct_answer,
            'wrong_answers': [mcq.wrong_answer_1, mcq.wrong_answer_2],
            'image': mcq.image.url
        }
        serializer = MultipleChoiceQuestionWithImageSerializer(mcq_transformed)
        return Response(serializer.data)


class MultipleChoiceQuestionWithVideoViewSet(viewsets.ViewSet):
    def list(self, request):
        queryset = map(
            lambda mcq: {
                'pk': mcq.pk,
                'correct_answer': mcq.correct_answer,
                'wrong_answers': [
                    mcq.wrong_answer_1,
                    mcq.wrong_answer_2
                ],
                'video': mcq.video.url
            },
            MultipleChoiceQuestionWithVideo.objects.all()
        )
        serializer = MultipleChoiceQuestionWithVideoSerializer(
            queryset, many=True)
        return Response(serializer.data)

    def retrieve(self, request, pk=None):
        mcq = get_object_or_404(MultipleChoiceQuestionWithVideo, pk=pk)
        mcq_transformed = {
            'pk': mcq.pk,
            'correct_answer': mcq.correct_answer,
            'wrong_answers': [mcq.wrong_answer_1, mcq.wrong_answer_2],
            'video': mcq.video.url
        }
        serializer = MultipleChoiceQuestionWithVideoSerializer(mcq_transformed)
        return Response(serializer.data)


class LandmarkQuestionViewSet(viewsets.ViewSet):
    def list(self, request):
        queryset = map(
            lambda lq: {
                'question': lq.question,
                'original_image': lq.original_image.url,
                'landmark_drawing': lq.landmark_drawing.url,
                'landmark_regions': LandmarkRegionSerializer(lq.regions, many=True)
            }, LandmarkQuestion.objects.all()
        )

        serializer = LandmarkQuestionSerializer(queryset, many=True)

        return Response(serializer.data)

    def retrieve(self, request, pk=None):
        lq = get_object_or_404(LandmarkQuestion, pk=pk)
        lq_transformed = {
            'question': lq.question,
            'original_image': lq.original_image.url,
            'landmark_drawing': lq.landmark_drawing.url,
            'landmark_regions': LandmarkRegionSerializer(
                lq.regions, many=True)
        }
        serializer = LandmarkQuestionSerializer(lq_transformed)

        return Response(serializer.data)
