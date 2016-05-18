from django.conf.urls import include, url, patterns

from .views import admin, site

urlpatterns = [
    # Site
    url(r'^view/(?P<test_id>\d+)/$', site.single_test, name='single_test'),
    url(r'^submit/(?P<test_id>\d+)/$', site.submit_test, name='submit_test'),
    # Admin
    url(r'^admin/new/$', admin.new_test, name='admin_new_test'),
    url(r'^admin/(?P<test_id>\d+)/$', admin.add_questions_to_test, name='admin_add_questions_to_test'),
    url(r'^admin/(?P<test_id>\d+)/delete/$', admin.delete_test, name='admin_delete_test'),
    url(r'^admin/list/$', admin.list_tests, name='admin_list_tests'),
    url(r'^adminresult/delete/$', admin.delete_test_results, name='admin_delete_test_results'),
    url(r'^admin/questions/$', admin.list_questions, name='admin_list_questions'),
    
    # Generic
    url(r'^admin/question/add/(?P<test_id>\d+)/(?P<question_id>\d+)/(?P<question_type_id>\d+)/$', admin.add_question_to_test, name='admin_add_question_to_test'),
    
    # MPC
    url(r'^admin/mpc/new/$', admin.new_multiple_choice_question, name='admin_new_multiple_choice_question'),
    url(r'^admin/mpc/new/(?P<test_id>\d+)/$', admin.new_multiple_choice_question_to_test, name='admin_new_multiple_choice_question_to_test'),
    url(r'^admin/mpc/edit/(?P<question_id>\d+)/$', admin.edit_multiple_choice_question, name='admin_edit_multiple_choice_question'),
    url(r'^admin/mpc/add/(?P<test_id>\d+)/$', admin.list_multiple_choice_questions_not_in_test, name='admin_list_multiple_choice_questions_not_in_test'),
    url(r'^admin/mpc/removefromtest/(?P<test_id>\d+)/(?P<question_id>\d+)/$', admin.delete_multiple_choice_question_from_test, name='admin_delete_multiple_choice_question_from_test'),
    url(r'^admin/mpc/delete/(?P<question_id>\d+)/$', admin.delete_multiple_choice_question, name='admin_delete_multiple_choice_question'),
    
    # MPCI
    url(r'^admin/mpci/new/$', admin.new_multiple_choice_question_with_image, name='admin_new_multiple_choice_question_with_image'),
    url(r'^admin/mpci/addtotest/(?P<test_id>\d+)/$', admin.new_multiple_choice_question_with_image_to_test, name='admin_new_multiple_choice_question_with_image_to_test'),
    url(r'^admin/mpci/edit/(?P<question_id>\d+)/$', admin.edit_multiple_choice_question_with_image, name='admin_edit_multiple_choice_question_with_image'),
    url(r'^admin/mpci/add/(?P<test_id>\d+)/$', admin.list_multiple_choice_questions_with_image_not_in_test, name='admin_list_multiple_choice_questions_with_image_not_in_test'),
    url(r'^admin/mpci/removefromtest/(?P<test_id>\d+)/(?P<question_id>\d+)/$', admin.delete_multiple_choice_question_with_image_from_test, name='admin_delete_multiple_choice_question_with_image_from_test'),
    url(r'^admin/mpci/delete/(?P<question_id>\d+)/$', admin.delete_multiple_choice_question_with_image, name='admin_delete_multiple_choice_question_with_image'),
    
    # MPCV
    url(r'^admin/mpcv/new/$', admin.new_multiple_choice_question_with_video, name='admin_new_multiple_choice_question_with_video'),
    url(r'^admin/mpcv/addtotest/(?P<test_id>\d+)/$', admin.new_multiple_choice_question_with_video_to_test, name='admin_new_multiple_choice_question_with_video_to_test'),
    url(r'^admin/mpcv/edit/(?P<question_id>\d+)/$', admin.edit_multiple_choice_question_with_video, name='admin_edit_multiple_choice_question_with_video'),
    url(r'^admin/mpcv/add/(?P<test_id>\d+)/$', admin.list_multiple_choice_questions_with_video_not_in_test, name='admin_list_multiple_choice_questions_with_video_not_in_test'),
    url(r'^admin/mpcv/removefromtest/(?P<test_id>\d+)/(?P<question_id>\d+)/$', admin.delete_multiple_choice_question_with_video_from_test, name='admin_delete_multiple_choice_question_with_video_from_test'),
    url(r'^admin/mpcv/delete/(?P<question_id>\d+)/$', admin.delete_multiple_choice_question_with_video, name='admin_delete_multiple_choice_question_with_video'),
    
    # LANDMARK
    url(r'^admin/(?P<test_id>\d+)/landmark/draw/(?P<question_id>\d+)/$', admin.draw_landmark, name='admin_draw_landmark'),
    url(r'^admin/(?P<test_id>\d+)/landmark/(?P<question_id>\d+)/delete/$', admin.delete_landmark_question_from_test, name='admin_delete_landmark_question_from_test'),
    url(r'^admin/(?P<test_id>\d+)/landmark/$', admin.add_landmark_question_to_test, name='admin_add_landmark_question_to_test'),
    url(r'^admin/landmark/add/(?P<test_id>\d+)/$', admin.list_landmark_questions_not_in_test, name='admin_list_landmark_questions_not_in_test'),
    
    # OUTLINE
    url(r'^admin/(?P<test_id>\d+)/outline/draw/(?P<question_id>\d+)/$', admin.draw_outline, name='admin_draw_outline'),
    url(r'^admin/(?P<test_id>\d+)/outline/(?P<question_id>\d+)/delete/$', admin.delete_outline_question_from_test, name='admin_delete_outline_question_from_test'),
    url(r'^admin/(?P<test_id>\d+)/outline/$', admin.add_outline_question_to_test, name='admin_add_outline_question_to_test'),
    url(r'^admin/outline/add/(?P<test_id>\d+)/$', admin.list_outline_questions_not_in_test, name='admin_list_outline_questions_not_in_test'),
]
