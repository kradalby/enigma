import base64
import os
import re

from django.conf import settings
from django.contrib import messages
from django.contrib.admin.views.decorators import staff_member_required
from django.core.exceptions import ObjectDoesNotExist
from django.core.files.base import ContentFile
from django.core.mail import send_mail
from django.db import transaction
from django.shortcuts import get_object_or_404, redirect, render
from django.urls import reverse
from django.http import HttpResponseRedirect

import math

from ..forms import *
from ..models import *
from ..templatetags.question_tags import question_type_from_id
from django.http import JsonResponse

from PIL import Image
from PIL import ImageDraw
from datetime import datetime
from collections import Counter
from itertools import product, starmap, chain
from io import BytesIO

from app.userprofile.models import UserProfile
from app.userprofile.views.users import view_user

from ..forms import (
    GenericImageForm, LandmarkQuestionForm, MultipleChoiceQuestionForm,
    MultipleChoiceQuestionWithImageForm, MultipleChoiceQuestionWithVideoForm,
    OutlineQuestionForm, OutlineSolutionQuestionForm, TestForm)
from ..models import (GenericImage, LandmarkQuestion, LandmarkRegion,
                      MultipleChoiceQuestion, MultipleChoiceQuestionWithImage,
                      MultipleChoiceQuestionWithVideo, OutlineQuestion,
                      OutlineRegion, OutlineSolutionQuestion, Test, TestResult,
                      TestUnit, TestUnitResult)
from ..templatetags.question_tags import question_type_from_id

SOLUTION_COLOR = (101, 155, 65, 255)

#
# Test related
#



@staff_member_required
def new_test(request):
    if request.method == 'POST':
        form = TestForm(request.POST)
        if form.is_valid():
            test = form.save()
            return redirect(add_questions_to_test, test.id)
    else:
        form = TestForm()

    return render(request, 'quiz/admin/new_test.html', {'form': form})


@staff_member_required
def edit_test(request, test_id):
    test = get_object_or_404(Test, id=test_id)
    form = TestForm(request.POST or None, instance=test)
    if request.method == 'POST':
        if form.is_valid():
            test = form.save()
            messages.success(request, 'Successfully updated test: %s.' % test)
            return redirect(add_questions_to_test, test.id)

    return render(request, 'quiz/admin/edit_test.html', {
        'form': form,
        'test': test,
    })


@staff_member_required
def add_questions_to_test(request, test_id):
    test = get_object_or_404(Test, id=test_id)
    return render(request, 'quiz/admin/add_questions_to_test.html',
                  {'test': test})


# Denne trenger url
# knapp
@staff_member_required
def send_email_to_participants_of_test(request, test_id):
    test = get_object_or_404(Test, id=test_id)
    users = test.course.get_users

    print(users)

    DATA = {
        'url':
        settings.BASE_URL + reverse(
            'single_test', kwargs={'test_id': test_id})
    }

    print(DATA)

    FROM = 'noreply@enigma.no'
    TO = [user.email for user in users]
    SUBJECT = 'New questionear is available'
    MESSAGE = '''Hi

There are new images available for expert review:

{url}

--
Best regards
Teamname
'''.format(**DATA)

    result = send_mail(SUBJECT, MESSAGE, FROM, TO)
    if result:
        messages.success(request, 'Successfully sent test to group members')
    else:
        messages.error(
            request,
            'Something went wrong sending the message, contact the system administrator.'
        )

    return redirect(add_questions_to_test, test.id)


@staff_member_required
def list_tests(request):
    tests = Test.objects.all()
    return render(request, 'quiz/admin/test_list.html', {'tests': tests})


@staff_member_required
def delete_test(request, test_id):
    try:
        test = Test.objects.get(id=test_id)
        test_name = test.name
        test.delete()
        messages.success(request, 'Successfully deleted test: %s.' % test_name)
    except ObjectDoesNotExist:
        messages.warning(
            request,
            'The test has already been deleted. You may have clicked twice.')
    return redirect(list_tests)


@staff_member_required
def view_list_of_users_taking_test(request, test_id):
    test = get_object_or_404(Test, id=test_id)
    group_id_to_include = [g.id for g in test.course.groups.all()]
    users_taking_test = UserProfile.objects.filter(
        groups__id__in=group_id_to_include)

    return render(request, 'quiz/admin/view_list_of_users_taking_test.html',
                  {'users': users_taking_test,
                   'test': test})


@staff_member_required
def view_test_result_for_user(request, test_id, user_id):
    test = get_object_or_404(Test, id=test_id)
    user = get_object_or_404(UserProfile, id=user_id)
    test_result = TestResult.objects.filter(test=test, user=user.user)
    test_unit_results = TestUnitResult.objects.filter(test_result=test_result)
    test_units = TestUnit.objects.filter(test=test)

    return render(request, 'quiz/admin/view_test_result_for_user.html', {
        'test_unit_results': test_unit_results,
        'user': user,
        'test': test,
        'test_result': test_result,
        'test_units': test_units
    })


#
# Test result related
#


@staff_member_required
def delete_test_results(request):
    TestResult.objects.all().delete()
    messages.success(request, 'Successfully deleted all test results.')
    return redirect('/admin')


#
# Questions related
#


@staff_member_required
def list_questions(request):
    multiple_choice_questions = MultipleChoiceQuestion.objects.all()
    multiple_choice_questions_with_image = MultipleChoiceQuestionWithImage.objects.all(
    )
    multiple_choice_questions_with_video = MultipleChoiceQuestionWithVideo.objects.all(
    )
    landmark_questions = LandmarkQuestion.objects.all()
    outline_question = OutlineQuestion.objects.all()
    outline_solution_question = OutlineSolutionQuestion.objects.all()
    return render(request, 'quiz/admin/list_questions.html', {
        'multiple_choice_questions':
        multiple_choice_questions,
        'multiple_choice_questions_with_image':
        multiple_choice_questions_with_image,
        'multiple_choice_questions_with_video':
        multiple_choice_questions_with_video,
        'landmark_questions':
        landmark_questions,
        'outline_questions':
        outline_question,
        'outline_solution_question':
        outline_solution_question
    })


#
# Generic functions
#


@staff_member_required
def _generic_new_multiple_choice_question_to_test(request, form_type, test_id):
    test = Test.objects.get(id=test_id)
    if request.method == 'POST':
        form = form_type(request.POST, request.FILES)
        if form.is_valid():
            question = form.save()
            question.test.add(test)
            return redirect(add_questions_to_test, test.id)
    else:
        form = form_type()

    return render(request, 'quiz/admin/add_question_to_test.html',
                  {'test': test,
                   'form': form})


@staff_member_required
def _generic_delete_question(request, question_type, question_id):
    try:
        question = question_type.objects.get(id=question_id)
        question_text = question.question
        question.delete()
        messages.success(request,
                         'Successfully deleted question: %s.' % question_text)
    except ObjectDoesNotExist:
        messages.warning(
            request,
            'The question has already been deleted. You may have clicked twice.'
        )


@staff_member_required
def _generic_remove_question_from_test(request, question_type, test_id,
                                       question_id):
    question = question_type.objects.get(id=question_id)
    test = Test.objects.get(id=test_id)
    question.test.remove(test)
    messages.success(request, 'Successfully removed question from test: %s.' %
                     question.question)


@staff_member_required
def _generic_new_question(request, form_type):
    if request.method == 'POST':
        form = form_type(request.POST, request.FILES)
        if form.is_valid():
            question = form.save()

            messages.success(
                request, 'Successfully created new question: %s.' % question)


@staff_member_required
def _generic_edit_question(request,
                           form_type,
                           object_type,
                           question_id,
                           test_id=None):
    instance = get_object_or_404(object_type, id=question_id)
    form = form_type(
        request.POST or None, request.FILES or None, instance=instance)
    if request.method == 'POST':
        if form.is_valid():
            question = form.save()
            messages.success(request,
                             'Successfully saved question: %s.' % question)
            if test_id:
                return redirect(add_questions_to_test, test_id)
            return redirect(list_questions)

    return render(request, 'quiz/admin/edit_question.html',
                  {'form': form,
                   'question': instance,
                   'test_id': test_id})


@staff_member_required
def _generic_list_question_not_in_test(request, question_type, test_id):
    test = get_object_or_404(Test, id=test_id)
    questions_not_in_test = question_type.objects.exclude(test=test)

    return render(request, 'quiz/admin/list_questions_not_in_test.html',
                  {'test': test,
                   'questions': questions_not_in_test})


@staff_member_required
def add_question_to_test(request, test_id, question_id, question_type_id):
    test = get_object_or_404(Test, id=test_id)
    question_type = question_type_from_id(question_type_id)
    question = get_object_or_404(question_type, id=question_id)
    question.test.add(test)
    messages.success(request, 'Successfully added question to test.')

    return redirect(add_questions_to_test, test_id)


#
# MPC related
#


@staff_member_required
def new_multiple_choice_question(request):
    return _generic_new_question(request, MultipleChoiceQuestionForm)


@staff_member_required
def new_multiple_choice_question_to_test(request, test_id):
    return _generic_new_multiple_choice_question_to_test(
        request, MultipleChoiceQuestionForm, test_id)


@staff_member_required
def edit_multiple_choice_question(request, question_id):
    return _generic_edit_question(request, MultipleChoiceQuestionForm,
                                  MultipleChoiceQuestion, question_id)


@staff_member_required
def edit_multiple_choice_question_for_test(request, test_id, question_id):
    return _generic_edit_question(request, MultipleChoiceQuestionForm,
                                  MultipleChoiceQuestion, question_id, test_id)


@staff_member_required
def list_multiple_choice_questions_not_in_test(request, test_id):
    return _generic_list_question_not_in_test(request, MultipleChoiceQuestion,
                                              test_id)


@staff_member_required
def delete_multiple_choice_question_from_test(request, test_id, question_id):
    _generic_remove_question_from_test(request, MultipleChoiceQuestion,
                                       test_id, question_id)


@staff_member_required
def delete_multiple_choice_question(request, question_id):
    _generic_delete_question(request, MultipleChoiceQuestion, question_id)
    return redirect(list_questions)


#
# MPCI related
#


@staff_member_required
def new_multiple_choice_question_with_image(request):
    return _generic_new_question(request, MultipleChoiceQuestionWithImageForm)


@staff_member_required
def new_multiple_choice_question_with_image_to_test(request, test_id):
    return _generic_new_multiple_choice_question_to_test(
        request, MultipleChoiceQuestionWithImageForm, test_id)


@staff_member_required
def edit_multiple_choice_question_with_image(request, question_id):
    return _generic_edit_question(request, MultipleChoiceQuestionWithImageForm,
                                  MultipleChoiceQuestionWithImage, question_id)


@staff_member_required
def edit_multiple_choice_question_with_image_for_test(request, test_id,
                                                      question_id):
    return _generic_edit_question(request, MultipleChoiceQuestionWithImageForm,
                                  MultipleChoiceQuestionWithImage, question_id,
                                  test_id)


@staff_member_required
def list_multiple_choice_questions_with_image_not_in_test(request, test_id):
    return _generic_list_question_not_in_test(
        request, MultipleChoiceQuestionWithImage, test_id)


@staff_member_required
def delete_multiple_choice_question_with_image_from_test(request, test_id,
                                                         question_id):
    _generic_remove_question_from_test(
        request, MultipleChoiceQuestionWithImage, test_id, question_id)


@staff_member_required
def delete_multiple_choice_question_with_image(request, question_id):
    _generic_delete_question(request, MultipleChoiceQuestionWithImage,
                             question_id)
    return redirect(list_questions)


#
# MPCV related
#


@staff_member_required
def new_multiple_choice_question_with_video(request):
    return _generic_new_question(request, MultipleChoiceQuestionWithVideoForm)


@staff_member_required
def new_multiple_choice_question_with_video_to_test(request, test_id):
    return _generic_new_multiple_choice_question_to_test(
        request, MultipleChoiceQuestionWithVideoForm, test_id)


@staff_member_required
def edit_multiple_choice_question_with_video(request, question_id):
    return _generic_edit_question(request, MultipleChoiceQuestionWithVideoForm,
                                  MultipleChoiceQuestionWithVideo, question_id)


@staff_member_required
def edit_multiple_choice_question_with_video_for_test(request, test_id,
                                                      question_id):
    return _generic_edit_question(request, MultipleChoiceQuestionWithVideoForm,
                                  MultipleChoiceQuestionWithVideo, question_id,
                                  test_id)


@staff_member_required
def list_multiple_choice_questions_with_video_not_in_test(request, test_id):
    return _generic_list_question_not_in_test(
        request, MultipleChoiceQuestionWithVideo, test_id)


@staff_member_required
def delete_multiple_choice_question_with_video_from_test(request, test_id,
                                                         question_id):
    _generic_remove_question_from_test(
        request, MultipleChoiceQuestionWithVideo, test_id, question_id)


@staff_member_required
def delete_multiple_choice_question_with_video(request, question_id):
    _generic_delete_question(request, MultipleChoiceQuestionWithVideo,
                             question_id)
    return redirect(list_questions)


#
# Landmark related
#


@staff_member_required
def add_landmark_question_to_test(request, test_id):
    test = Test.objects.get(id=test_id)
    if request.method == 'POST':
        form = LandmarkQuestionForm(request.POST, request.FILES)
        if form.is_valid():
            question = form.save()
            question.test.add(test)
            return redirect(draw_landmark, test.id, question.id)
    else:
        form = LandmarkQuestionForm()

    return render(request, 'quiz/admin/new_landmark_question.html',
                  {'test': test,
                   'form': form})


@staff_member_required
@transaction.atomic
def draw_landmark(request, question_id, test_id=None):
    test = Test.objects.get(id=test_id) if test_id else None
    question = LandmarkQuestion.objects.get(id=question_id)
    if request.method == 'POST':
        data_url_pattern = re.compile('data:image/(png|jpeg);base64,(.*)$')
        image_data = request.POST.get('hidden-image-data')
        try:
            image_data = data_url_pattern.match(image_data).group(2)
        except AttributeError:
            messages.error(request,
                           'You can\'t leave any regions blank or empty.')
            return render(request, 'quiz/admin/draw_landmark.html',
                          {'test': test,
                           'question': question})
        if (image_data is None or len(image_data) == 0):
            messages.error(request,
                           'You can\'t leave any regions blank or empty.')
            return render(request, 'quiz/admin/draw_landmark.html',
                          {'test': test,
                           'question': question})
        image_data = base64.b64decode(image_data)
        question.landmark_drawing = ContentFile(
            image_data,
            'solution-' + os.path.basename(question.original_image.name))
        question.save()
        question.regions().delete()
        for k, v in request.POST.items():
            if k.startswith('#') and len(k) == 7:
                region = LandmarkRegion()
                region.color = k
                if not v:
                    messages.error(request,
                                   'You have to give name to all regions.')
                    return render(request, 'quiz/admin/draw_landmark.html',
                                  {'test': test,
                                   'question': question})
                region.name = v
                region.landmark_question = question
                region.save()
        if test:
            return redirect(add_questions_to_test, test.id)
        else:
            return redirect(list_questions)
    return render(request, 'quiz/admin/draw_landmark.html',
                  {'test': test,
                   'question': question})


@staff_member_required
@transaction.atomic
def draw_landmark_from_image(request, image_id, question_id=None):
    img = GenericImage.objects.get(pk=image_id)
    if question_id:
        question = LandmarkQuestion.objects.get(id=question_id)
    else:
        question = LandmarkQuestion()
        question.original_image = img.image
        question.name = 'landmark_' + img.name

    if request.method == 'POST':
        data_url_pattern = re.compile('data:image/(png|jpeg);base64,(.*)$')
        image_data = request.POST.get('hidden-image-data')
        try:
            image_data = data_url_pattern.match(image_data).group(2)
        except AttributeError:
            messages.error(request,
                           'You can\'t leave any regions blank or empty.')
            return render(request, 'quiz/admin/draw_landmark.html',
                          {'question': question})

        if (image_data is None or len(image_data) == 0):
            messages.error(request,
                           'You can\'t leave any regions blank or empty.')
            return render(request, 'quiz/admin/draw_landmark.html',
                          {'question': question})
        image_data = base64.b64decode(image_data)
        question.landmark_drawing = ContentFile(
            image_data,
            'solution-' + os.path.basename(question.original_image.name))

        question.regions().delete()
        for k, v in request.POST.items():
            if k.startswith('#') and len(k) == 7:
                region = LandmarkRegion()
                region.color = k
                if not v:
                    messages.error(request,
                                   'You have to give name to all regions.')
                    return render(request, 'quiz/admin/draw_landmark.html',
                                  {'question': question})
                region.name = v
                question.save()
                region.landmark_question = question
                region.save()
        question.save()
        return redirect(list_questions)
    return render(request, 'quiz/admin/draw_landmark.html',
                  {'question': question})


@staff_member_required
def new_landmark_question(request):
    if request.method == 'POST':
        form = LandmarkQuestionForm(request.POST, request.FILES)
        if form.is_valid():
            question = form.save()
            return redirect(draw_landmark, question.id)
    else:
        form = LandmarkQuestionForm()

    return render(request, 'quiz/admin/new_landmark_question.html',
                  {'form': form})


# @staff_member_required
# def add_landmark_regions(request, test_id, question_id):
#     test = Test.objects.get(id=test_id)
#     question = LandmarkQuestion.objects.get(id=question_id)


@staff_member_required
def delete_landmark_question_from_test(request, test_id, question_id):
    _generic_remove_question_from_test(request, LandmarkQuestion, test_id,
                                       question_id)
    return redirect(add_questions_to_test, test_id)


@staff_member_required
def list_landmark_questions_not_in_test(request, test_id):
    return _generic_list_question_not_in_test(request, LandmarkQuestion,
                                              test_id)


@staff_member_required
def delete_landmark_question(request, question_id):
    _generic_delete_question(request, LandmarkQuestion, question_id)
    return redirect(list_questions)


#
# Outline
#


@transaction.atomic
@staff_member_required
def add_outline_question_to_test(request, test_id):
    test = Test.objects.get(id=test_id)
    if request.method == 'POST':
        form = OutlineQuestionForm(request.POST, request.FILES)
        if form.is_valid():
            question = form.save()
            question.test.add(test)
            return redirect(draw_outline, question.id, test.id)
    else:
        form = OutlineQuestionForm()

    return render(request, 'quiz/admin/new_outline_question.html',
                  {'test': test,
                   'form': form})


@staff_member_required
@transaction.atomic
def draw_outline(request, question_id, test_id=None):
    test = Test.objects.get(id=test_id) if test_id else None
    question = OutlineQuestion.objects.get(id=question_id)
    if request.method == 'POST':
        dataUrlPattern = re.compile('data:image/(png|jpeg);base64,(.*)$')
        image_data = request.POST.get('hidden-image-data')
        try:
            image_data = dataUrlPattern.match(image_data).group(2)
        except AttributeError:
            messages.error(request,
                           'You can\'t leave any regions blank or empty.')
            return render(request, 'quiz/admin/draw_outline.html',
                          {'test': test,
                           'question': question})
        if (image_data is None or len(image_data) == 0):
            messages.error(request,
                           'You can\'t leave any regions blank or empty.')
            return render(request, 'quiz/admin/draw_outline.html',
                          {'test': test,
                           'question': question})
        image_data = base64.b64decode(image_data)
        question.outline_drawing = ContentFile(
            image_data,
            'solution-' + os.path.basename(question.original_image.name))
        question.save()
        question.regions().delete()
        for k, v in request.POST.items():
            if k.startswith('#') and len(k) == 7:
                region = OutlineRegion()
                region.color = k
                if not v:
                    messages.error(request,
                                   'You have to give name to all regions.')
                    return render(request, 'quiz/admin/draw_outline.html',
                                  {'test': test,
                                   'question': question})
                region.name = v
                region.outline_question = question
                region.save()
        if test:
            return redirect(add_questions_to_test, test.id)
        else:
            return redirect(list_questions)
    return render(request, 'quiz/admin/draw_outline.html',
                  {'test': test,
                   'question': question})




@staff_member_required
@transaction.atomic
def draw_outline_from_image(request, image_id, question_id=None):
    img = GenericImage.objects.get(pk=image_id)
    if question_id:
        question = OutlineQuestion.objects.get(id=question_id)
    else:
        question = OutlineQuestion()
        question.original_image = img.image
        question.name = 'outline_' + img.name

    if request.method == 'POST':
        data_url_pattern = re.compile('data:image/(png|jpeg);base64,(.*)$')
        image_data = request.POST.get('hidden-image-data')
        try:
            image_data = data_url_pattern.match(image_data).group(2)
        except AttributeError:
            messages.error(request,
                           'You can\'t leave any regions blank or empty.')
            return render(request, 'quiz/admin/draw_outline.html',
                          {'question': question})

        if (image_data is None or len(image_data) == 0):
            messages.error(request,
                           'You can\'t leave any regions blank or empty.')
            return render(request, 'quiz/admin/draw_outline.html',
                          {'question': question})
        image_data = base64.b64decode(image_data)
        question.outline_drawing = ContentFile(
            image_data,
            'solution-' + os.path.basename(question.original_image.name))

        question.regions().delete()
        for k, v in request.POST.items():
            if k.startswith('#') and len(k) == 7:
                region = OutlineRegion()
                region.color = k
                if not v:
                    messages.error(request,
                                   'You have to give name to all regions.')
                    return render(request, 'quiz/admin/draw_outline.html',
                                  {'question': question})
                region.name = v
                question.save()
                region.outline_question = question
                region.save()
        question.save()
        return redirect(list_questions)
    return render(request, 'quiz/admin/draw_outline.html',
                  {'question': question})


@staff_member_required
def delete_outline_question_from_test(request, test_id, question_id):
    _generic_remove_question_from_test(request, OutlineQuestion, test_id,
                                       question_id)
    return redirect(add_questions_to_test, test_id)


@staff_member_required
def list_outline_questions_not_in_test(request, test_id):
    return _generic_list_question_not_in_test(request, OutlineQuestion,
                                              test_id)


@staff_member_required
def delete_outline_question(request, question_id):
    _generic_delete_question(request, OutlineQuestion, question_id)
    return redirect(list_questions)


@staff_member_required
def new_outline_question(request):
    if request.method == 'POST':
        form = OutlineQuestionForm(request.POST, request.FILES)
        if form.is_valid():
            question = form.save()
            return redirect(draw_outline, question.id)
    else:
        form = OutlineQuestionForm()

    return render(request, 'quiz/admin/new_outline_question.html',
                  {'form': form})


#
# OULINE SOLUTION QUESTION
#
@staff_member_required
def new_outline_solution_question(request):
    if request.method == 'POST':
        form = OutlineSolutionQuestionForm(request.POST, request.FILES)
        if form.is_valid():
            form.save()
            return redirect(list_questions)
    else:
        form = OutlineSolutionQuestionForm()

    return render(request, 'quiz/admin/new_question.html', {'form': form})


@transaction.atomic
@staff_member_required
def add_outline_solution_question_to_test(request, test_id):
    test = Test.objects.get(id=test_id)
    if request.method == 'POST':
        form = OutlineSolutionQuestionForm(request.POST, request.FILES)
        if form.is_valid():
            question = form.save()
            question.test.add(test)
            return redirect(add_questions_to_test, test.id)
    else:
        form = OutlineSolutionQuestionForm()

    return render(request, 'quiz/admin/new_outline_solution_question.html',
                  {'test': test,
                   'form': form})


@staff_member_required
def list_outline_solution_questions_not_in_test(request, test_id):
    return _generic_list_question_not_in_test(request, OutlineSolutionQuestion,
                                              test_id)


@staff_member_required
def delete_outline_solution_question(request, question_id):
    _generic_delete_question(request, OutlineSolutionQuestion, question_id)
    return redirect(list_questions)


@staff_member_required
def edit_outlinesolution(request, question_id):
    return _generic_edit_question(request, OutlineSolutionQuestionForm,
                                  OutlineSolutionQuestion, question_id)


@staff_member_required
def delete_outline_solution_question_from_test(request, test_id, question_id):
    _generic_remove_question_from_test(request, OutlineSolutionQuestion,
                                       test_id, question_id)
    return redirect(add_questions_to_test, test_id)


@staff_member_required
@transaction.atomic
def create_outline_from_outline_solution(request, question_id, test_result_id):
    question = get_object_or_404(GenericImage, id=question_id)
    test_result = get_object_or_404(TestUnitResult, id=test_result_id)

    outline_question = OutlineQuestion()
    outline_question.question = question.question
    new_file = ContentFile(question.image.read())
    new_file.name = question.image.name
    outline_question.original_image = new_file
    new_file2 = ContentFile(test_result.answer_image.read())
    new_file2.name = test_result.answer_image.name
    outline_question.outline_drawing = new_file2
    outline_question.save()

    outline_region = OutlineRegion()
    outline_region.outline_question = outline_question
    outline_region.name = ""
    outline_region.color = ""
    outline_region.save()

    return redirect(draw_outline, outline_question.id)


@staff_member_required
def edit_outline_solution_question_for_test(request, test_id, question_id):
    return _generic_edit_question(request, OutlineSolutionQuestionForm,
                                  OutlineSolutionQuestion, question_id,
                                  test_id)


@staff_member_required
def view_test_results_for_single_test(request, test_id):
    test = get_object_or_404(Test, id=test_id)
    test_results = TestResult.objects.filter(test=test)
    test_units = TestUnit.objects.filter(test=test)
    test_unit_results = [x.test_unit_results() for x in test_results]
    # flatten list
    test_unit_results = [
        item for sublist in test_unit_results for item in sublist
    ]

    return render(request, 'quiz/admin/view_test_results_for_single_test.html',
                  {
                      "test": test,
                      "test_units": test_units,
                      "test_unit_results": test_unit_results
                  })


def get_euclidean_distance(start, end):

    (x1, y1) = start
    (x2, y2) = end

    return (math.sqrt(math.pow((x2-x1), 2) + math.pow((y2 - y1), 2)))


def get_colored_coordinates_from_matrix(matrix):
    data = []

    for y in range(len(matrix)):
        for x in range(len(matrix[y])):
            # if matrix[y][x] == color or matrix[y][x] == SOLUTION_COLOR:
            if matrix[y][x] != (0,0,0,0):
                data.append((x, y))

    return data


def get_neighbour_pixels(coord, img_matrix, radius):
    x, y = coord
    radius_list = list(chain.from_iterable((x, -x) for x in range(radius + 1)))
    cells = starmap(lambda a,b: (x+a, y+b), product(radius_list, radius_list))

    height = len(img_matrix)
    width = len(img_matrix[0])

    for x2, y2 in cells:
        if y2 <= (height-1) and x2 <= (width-1) and img_matrix[y2][x2] != (0,0,0,0):
            yield (x2, y2)


def get_closest_cord_dic2(ref_color_list, img_matrix):
    dic_of_things = {}

    for ref_cord in ref_color_list:
        current_shortest_distance = 50000
        for img_cord in get_neighbour_pixels(ref_cord, img_matrix, 20):
            if ref_cord == img_cord:
                dic_of_things[ref_cord] = img_cord
                break

            euclidean_distance = get_euclidean_distance(ref_cord, img_cord)

            if current_shortest_distance > euclidean_distance:
                dic_of_things[ref_cord] = img_cord
                current_shortest_distance = euclidean_distance

    return dic_of_things


def midpointformula(start, end):
    (x1, y1) = start
    (x2, y2) = end

    x3 = ((x1 + x2) / 2)
    y3 = ((y1 + y2) / 2)

    average = (int(x3), int(y3))

    return average


def get_new_image_list(ref_dic):
    list_of_things = []

    for key, value in ref_dic.items():
        list_of_things.append(midpointformula(key, value))

    #print(ref_dic)

    return list_of_things


def calculate_average_of_two_selected_answers(ref, img):

    pixels = list(ref.getdata())
    # color = Counter(pixels).most_common(2)
    # print(color)
    # color = color[1][0]
    width, height = ref.size
    pixels = [pixels[i * width:(i + 1) * width] for i in range(height)]

    pixels2 = list(img.getdata())
    width2, height2 = img.size
    pixels2 = [pixels2[i * width2:(i + 1) * width2] for i in range(height2)]

    # colored_pixels = get_colored_coordinates_from_matrix(pixels, color)
    colored_pixels = get_colored_coordinates_from_matrix(pixels)

    # ref_dic = get_closest_cord_dic2(colored_pixels, pixels2, color)
    ref_dic = get_closest_cord_dic2(colored_pixels, pixels2)

    coords = get_new_image_list(ref_dic)

    newImageList = [[(0, 0, 0, 0)] * width for i in range(height)]


    for (x, y) in coords:
        newImageList[y][x] = SOLUTION_COLOR

    newImage = Image.new("RGBA", (width, height))
    newImage.putdata([item for sublist in newImageList for item in sublist], 1, 1)

    return newImage


def change_color(image):
    data = []
    for pixel in image.getdata():
        if pixel != (0,0,0,0):
            data.append(SOLUTION_COLOR)
        else:
            data.append((0,0,0,0))

    newImg = Image.new("RGBA", image.size)
    newImg.putdata(data, 1, 1)
    return newImg

#
#Calculate average result
#
@staff_member_required
def calculate_average_result_from_selected_answers(request):

    test_id = request.POST.get('test_id')
    question_id = request.POST.get('question_id')
    test_unit_result_ids = request.POST.getlist('test_unit_result_ids[]')

    #print(test_unit_result_ids)


    test_unit_results = [Image.open(x.answer_image) for x in TestUnitResult.objects.filter(pk__in=[int(i) for i in test_unit_result_ids])]

    ref, *rest = test_unit_results

    for image in rest:
        ref = calculate_average_of_two_selected_answers(ref, image)

    if not rest:
        ref = change_color(ref)

    output = BytesIO()

    ref.save(output, "PNG")
    contents = output.getvalue()
    output.close()
    img_str = base64.b64encode(contents).decode("utf-8")


    data = {
        'test_id': test_id,
        'question_id': question_id,
        'encodend_img': img_str
    }

    return JsonResponse(data)




@staff_member_required
def delete_test_result(request, test_result_id):
    test_result = TestResult.objects.get(id=test_result_id)
    user = UserProfile.objects.get(user=test_result.user)
    test_result.delete()
    messages.success(request, 'Successfully deleted test result')

    return redirect(view_user, user.id)


@staff_member_required
def delete_test_result_in_test(request, test_result_id):
    test_result = get_object_or_404(TestResult, id=test_result_id)
    test_id = test_result.test.id
    test_result.delete()
    messages.success(request, 'Successfully deleted test result')

    return redirect(view_list_of_users_taking_test, test_id)


@staff_member_required
def delete_test_results_in_test(request, test_id):
    test = get_object_or_404(Test, id=test_id)
    TestResult.objects.filter(test=test).delete()
    messages.success(request,
                     'Successfully deleted test results for {0}'.format(test))

    return redirect(list_tests)


#
# GENERIC IMAGE
#


@staff_member_required
def image_overview(request):
    images = GenericImage.objects.all()
    return render(request, 'quiz/admin/image_overview.html',
                  {'images': images})


@staff_member_required
def new_generic_image(request):
    if request.method == 'POST':
        form = GenericImageForm(request.POST, request.FILES)
        if form.is_valid():
            image = form.save()
            return redirect(image_overview)
    else:
        form = GenericImageForm()

    return render(request, 'quiz/admin/new_generic_image.html', {'form': form})


@transaction.atomic
@staff_member_required
def add_image_suggestion_to_test(request, test_id):
    test = Test.objects.get(id=test_id)
    if request.method == 'POST':
        form = GenericImageForm(request.POST, request.FILES)
        if form.is_valid():
            question = form.save()
            question.test.add(test)
            return redirect(add_questions_to_test, test.id)
    else:
        form = GenericImageForm()

    return render(request, 'quiz/admin/new_generic_image.html',
                  {'test': test,
                   'form': form})


@staff_member_required
def list_image_suggestion_not_in_test(request, test_id):
    return _generic_list_question_not_in_test(request, GenericImage, test_id)


@staff_member_required
def delete_image_suggestion(request, question_id):
    _generic_delete_question(request, GenericImage, question_id)
    return redirect(list_questions)


@staff_member_required
def delete_image_suggestion_from_test(request, test_id, question_id):
    _generic_remove_question_from_test(request, GenericImage, test_id,
                                       question_id)
    return redirect(add_questions_to_test, test_id)


@staff_member_required
def image_expert_overview(request, image_id):
    image = GenericImage.objects.get(pk=image_id)
    users = UserProfile.objects.all()

    return render(request, 'quiz/admin/image_expert_overview.html',
                  {'image': image,
                   'users': users})


@staff_member_required
@transaction.atomic
def create_outline_from_image_suggestion(request, image_id):
    image = get_object_or_404(GenericImage, id=image_id)

    if request.method == 'POST':
        dataUrlPattern = re.compile('data:image/(png|jpeg);base64,(.*)$')
        image_data = request.POST.get('hidden-image-data')
        try:
            image_data = dataUrlPattern.match(image_data).group(2)
        except AttributeError:
            messages.error(request,
                           'You can\'t leave any regions blank or empty.')
            return HttpResponseRedirect(request.META.get('HTTP_REFERER'))
        if (image_data is None or len(image_data) == 0):
            messages.error(request,
                           'You can\'t leave any regions blank or empty.')
            return HttpResponseRedirect(request.META.get('HTTP_REFERER'))
        image_data = base64.b64decode(image_data)
        question = OutlineQuestion()
        question.original_image = image.image
        question.outline_drawing = ContentFile(
            image_data,
            'solution-' + os.path.basename(question.original_image.name))
        question.save()
        question.regions().delete()
            
        return redirect(draw_outline, question.pk)
    return HttpResponseRedirect(request.META.get('HTTP_REFERER'))


@staff_member_required
@transaction.atomic
def create_landmark_from_image_suggestion(request, image_id):
    image = get_object_or_404(GenericImage, id=image_id)

    if request.method == 'POST':
        dataUrlPattern = re.compile('data:image/(png|jpeg);base64,(.*)$')
        image_data = request.POST.get('hidden-image-data')
        try:
            image_data = dataUrlPattern.match(image_data).group(2)
        except AttributeError:
            messages.error(request,
                           'You can\'t leave any regions blank or empty.')
            return HttpResponseRedirect(request.META.get('HTTP_REFERER'))
        if (image_data is None or len(image_data) == 0):
            messages.error(request,
                           'You can\'t leave any regions blank or empty.')
            return HttpResponseRedirect(request.META.get('HTTP_REFERER'))
        image_data = base64.b64decode(image_data)
        question = LandmarkQuestion()
        question.original_image = image.image
        question.outline_drawing = ContentFile(
            image_data,
            'solution-' + os.path.basename(question.original_image.name))
        question.save()
        question.regions().delete()

        return redirect(draw_landmark, question.pk)
    return HttpResponseRedirect(request.META.get('HTTP_REFERER'))
