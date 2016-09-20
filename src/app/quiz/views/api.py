from ..models import (Test,
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

from ..serializers import (TestResultSerializer,
                           TestUnitSerializer,
                           TestUnitResultSerializer,
                           MultipleChoiceQuestionSerializer,
                           MultipleChoiceQuestionWithImageSerializer,
                           MultipleChoiceQuestionWithVideoSerializer,
                           LandmarkQuestionSerializer,
                           LandmarkRegionSerializer,
                           OutlineQuestionSerializer,
                           OutlineRegionSerializer,
                           OutlineSolutionQuestionSerializer)

from rest_framework import viewsets


class TestResultViewSet(viewsets.ModelViewSet):
    queryset = TestResult.objects.all()
    serializer_class = TestResultSerializer


class TestUnitViewSet(viewsets.ModelViewSet):
    queryset = TestUnit.objects.all()
    serializer_class = TestUnitSerializer


class TestUnitResultViewSet(viewsets.ModelViewSet):
    queryset = TestUnitResult.objects.all()
    serializer_class = TestUnitResultSerializer


class MultipleChoiceQuestionViewSet(viewsets.ModelViewSet):
    queryset = MultipleChoiceQuestion.objects.all()
    serializer_class = MultipleChoiceQuestionSerializer


class MultipleChoiceQuestionWithImageViewSet(viewsets.ModelViewSet):
    queryset = MultipleChoiceQuestionWithImage.objects.all()
    serializer_class = MultipleChoiceQuestionWithImageSerializer


class MultipleChoiceQuestionWithVideoViewSet(viewsets.ModelViewSet):
    queryset = MultipleChoiceQuestionWithVideo.objects.all()
    serializer_class = MultipleChoiceQuestionWithVideoSerializer


class LandmarkQuestionViewSet(viewsets.ModelViewSet):
    queryset = LandmarkQuestion.objects.all()
    serializer_class = LandmarkQuestionSerializer


class LandmarkRegionViewSet(viewsets.ModelViewSet):
    queryset = LandmarkRegion.objects.all()
    serializer_class = LandmarkRegionSerializer


class OutlineQuestionViewSet(viewsets.ModelViewSet):
    queryset = OutlineQuestion.objects.all()
    serializer_class = OutlineQuestionSerializer


class OutlineRegionViewSet(viewsets.ModelViewSet):
    queryset = OutlineRegion.objects.all()
    serializer_class = OutlineRegionSerializer


class OutlineSolutionQuestionViewSet(viewsets.ModelViewSet):
    queryset = OutlineSolutionQuestion.objects.all()
    serializer_class = OutlineSolutionQuestionSerializer
