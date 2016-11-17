from django.shortcuts import get_object_or_404
from rest_framework import viewsets
from rest_framework.response import Response
from random import random

from ..models import (LandmarkQuestion, MultipleChoiceQuestion,
                      MultipleChoiceQuestionWithImage,
                      MultipleChoiceQuestionWithVideo, OutlineQuestion)
from ..serializers import (LandmarkQuestionSerializer,
                           LandmarkRegionSerializer,
                           MultipleChoiceQuestionSerializer,
                           MultipleChoiceQuestionWithImageSerializer,
                           MultipleChoiceQuestionWithVideoSerializer,
                           OutlineQuestionSerializer, OutlineRegionSerializer)


def transform_data(mcq):
    data = {
        'pk': mcq.pk,
        'question': mcq.question,
        'answers': sorted(
            [mcq.correct_answer, mcq.wrong_answer_1, mcq.wrong_answer_2],
            key=lambda k: random())
    }
    data['correct'] = data['answers'].index(mcq.correct_answer)

    if hasattr(mcq, 'image'):
        data['image'] = mcq.image.url

    if hasattr(mcq, 'video'):
        data['video'] = mcq.video.url

    return data


class MultipleChoiceQuestionViewSet(viewsets.ViewSet):
    def list(self, request):
        queryset = map(lambda mcq: transform_data(mcq),
                       MultipleChoiceQuestion.objects.all())
        serializer = MultipleChoiceQuestionSerializer(queryset, many=True)
        return Response(serializer.data)

    def retrieve(self, request, pk=None):
        mcq = get_object_or_404(MultipleChoiceQuestion, pk=pk)
        mcq_transformed = transform_data(mcq)
        serializer = MultipleChoiceQuestionSerializer(mcq_transformed)
        return Response(serializer.data)


class MultipleChoiceQuestionWithImageViewSet(viewsets.ViewSet):
    def list(self, request):
        queryset = map(lambda mcq: transform_data(mcq),
                       MultipleChoiceQuestionWithImage.objects.all())
        serializer = MultipleChoiceQuestionWithImageSerializer(
            queryset, many=True)
        return Response(serializer.data)

    def retrieve(self, request, pk=None):
        mcq = get_object_or_404(MultipleChoiceQuestionWithImage, pk=pk)
        mcq_transformed = transform_data(mcq)
        serializer = MultipleChoiceQuestionWithImageSerializer(mcq_transformed)
        return Response(serializer.data)


class MultipleChoiceQuestionWithVideoViewSet(viewsets.ViewSet):
    def list(self, request):
        queryset = map(lambda mcq: transform_data(mcq),
                       MultipleChoiceQuestionWithVideo.objects.all())
        serializer = MultipleChoiceQuestionWithVideoSerializer(
            queryset, many=True)
        return Response(serializer.data)

    def retrieve(self, request, pk=None):
        mcq = get_object_or_404(MultipleChoiceQuestionWithVideo, pk=pk)
        mcq_transformed = transform_data(mcq)
        serializer = MultipleChoiceQuestionWithVideoSerializer(mcq_transformed)
        return Response(serializer.data)


class LandmarkQuestionViewSet(viewsets.ViewSet):
    def list(self, request):
        queryset = map(
            lambda lq: {
                'question': lq.question,
                'original_image': lq.original_image.url,
                'landmark_drawing': lq.landmark_drawing.url if lq.landmark_drawing else '',
                'landmark_regions': LandmarkRegionSerializer(lq.regions(), many=True).data
            }, LandmarkQuestion.objects.all()
        )

        serializer = LandmarkQuestionSerializer(queryset, many=True)

        return Response(serializer.data)

    def retrieve(self, request, pk=None):
        lq = get_object_or_404(LandmarkQuestion, pk=pk)
        lq_transformed = {
            'question': lq.question,
            'original_image': lq.original_image.url,
            'landmark_drawing': lq.landmark_drawing.url
            if lq.landmark_drawing else '',
            'landmark_regions': LandmarkRegionSerializer(
                lq.regions(), many=True).data
        }
        serializer = LandmarkQuestionSerializer(lq_transformed)

        return Response(serializer.data)


class OutlineQuestionViewSet(viewsets.ViewSet):
    def list(self, request):
        queryset = map(
            lambda oq: {
                'question': oq.question,
                'original_image': oq.original_image.url,
                'outline_drawing': oq.outline_drawing.url if oq.outline_drawing else '',
                'outline_regions': OutlineRegionSerializer(oq.regions(), many=True).data
            }, OutlineQuestion.objects.all()
        )

        serializer = OutlineQuestionSerializer(queryset, many=True)

        return Response(serializer.data)

    def retrieve(self, request, pk=None):
        oq = get_object_or_404(OutlineQuestion, pk=pk)
        oq_transformed = {
            'question': oq.question,
            'original_image': oq.original_image.url,
            'outline_drawing': oq.outline_drawing.url
            if oq.outline_drawing else '',
            'outline_regions': OutlineRegionSerializer(
                oq.regions(), many=True).data
        }
        serializer = LandmarkQuestionSerializer(oq_transformed)

        return Response(serializer.data)
