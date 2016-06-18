from django.conf.urls import include, url, patterns

from .views import admin, site

urlpatterns = [
    # Site
    url(r'^view/(?P<test_id>\d+)/$', site.single_test, name='single_test'),
    url(r'^submit/(?P<test_id>\d+)/$', site.submit_test, name='submit_test'),

    url(r'^result/(?P<test_result_id>\d+)/$', site.view_test_result, name='view_test_result'),
    url(r'^result/delete/(?P<test_result_id>\d+)/$', site.delete_test_result, name='delete_test_result'),
    
    # Admin
    url(r'^admin/new/$', admin.new_test, name='admin_new_test'),
    url(r'^admin/edit/(?P<test_id>\d+)/$', admin.edit_test, name='admin_edit_test'),
    url(r'^admin/(?P<test_id>\d+)/$', admin.add_questions_to_test, name='admin_add_questions_to_test'),
    url(r'^admin/(?P<test_id>\d+)/$', admin.add_questions_to_test, name='admin_view_test'),
    url(r'^admin/(?P<test_id>\d+)/delete/$', admin.delete_test, name='admin_delete_test'),
    url(r'^admin/list/$', admin.list_tests, name='admin_list_tests'),
    url(r'^admin/questions/$', admin.list_questions, name='admin_list_questions'),
    url(r'^admin/(?P<test_id>\d+)/userlist/$', admin.view_list_of_users_taking_test, name='admin_view_list_of_users_taking_test'),
    url(r'^admin/(?P<test_id>\d+)/user/(?P<user_id>\d+)/$', admin.view_test_result_for_user, name='admin_view_test_result_for_user'),
    
    # Test results
    url(r'^admin/result/delete/$', admin.delete_test_results, name='admin_delete_test_results'),
    url(r'^admin/result/delete/(?P<test_result_id>\d+)/$', admin.delete_test_result_in_test, name='admin_delete_test_result_in_test'),
    url(r'^admin/result/delete/test/(?P<test_id>\d+)/$', admin.delete_test_results_in_test, name='admin_delete_test_results_in_test'),
    url(r'^admin/result/view/(?P<test_id>\d+)/$', admin.view_test_results_for_single_test, name='admin_view_test_results_for_single_test'),
    url(r'^admin/result/(?P<test_result_id>\d+)/delete/$', admin.delete_test_result, name='admin_delete_test_result'),
    
    # Generic
    url(r'^admin/question/add/(?P<test_id>\d+)/(?P<question_id>\d+)/(?P<question_type_id>\d+)/$', admin.add_question_to_test, name='admin_add_question_to_test'),
    
    # MPC
    url(r'^admin/mpc/new/$', admin.new_multiple_choice_question, name='admin_new_multiple_choice_question'),
    url(r'^admin/mpc/new/(?P<test_id>\d+)/$', admin.new_multiple_choice_question_to_test, name='admin_new_multiple_choice_question_to_test'),
    url(r'^admin/mpc/edit/(?P<question_id>\d+)/$', admin.edit_multiple_choice_question, name='admin_edit_multiple_choice_question'),
    url(r'^admin/(?P<test_id>\d+)/mpc/edit/(?P<question_id>\d+)/$', admin.edit_multiple_choice_question_for_test, name='admin_edit_multiple_choice_question_for_test'),
    url(r'^admin/mpc/add/(?P<test_id>\d+)/$', admin.list_multiple_choice_questions_not_in_test, name='admin_list_multiple_choice_questions_not_in_test'),
    url(r'^admin/mpc/removefromtest/(?P<test_id>\d+)/(?P<question_id>\d+)/$', admin.delete_multiple_choice_question_from_test, name='admin_delete_multiple_choice_question_from_test'),
    url(r'^admin/mpc/delete/(?P<question_id>\d+)/$', admin.delete_multiple_choice_question, name='admin_delete_multiple_choice_question'),
    
    # MPCI
    url(r'^admin/mpci/new/$', admin.new_multiple_choice_question_with_image, name='admin_new_multiple_choice_question_with_image'),
    url(r'^admin/mpci/addtotest/(?P<test_id>\d+)/$', admin.new_multiple_choice_question_with_image_to_test, name='admin_new_multiple_choice_question_with_image_to_test'),
    url(r'^admin/mpci/edit/(?P<question_id>\d+)/$', admin.edit_multiple_choice_question_with_image, name='admin_edit_multiple_choice_question_with_image'),
    url(r'^admin/(?P<test_id>\d+)/mpci/edit/(?P<question_id>\d+)/$', admin.edit_multiple_choice_question_with_image_for_test, name='admin_edit_multiple_choice_question_with_image_for_test'),
    url(r'^admin/mpci/add/(?P<test_id>\d+)/$', admin.list_multiple_choice_questions_with_image_not_in_test, name='admin_list_multiple_choice_questions_with_image_not_in_test'),
    url(r'^admin/mpci/removefromtest/(?P<test_id>\d+)/(?P<question_id>\d+)/$', admin.delete_multiple_choice_question_with_image_from_test, name='admin_delete_multiple_choice_question_with_image_from_test'),
    url(r'^admin/mpci/delete/(?P<question_id>\d+)/$', admin.delete_multiple_choice_question_with_image, name='admin_delete_multiple_choice_question_with_image'),
    
    # MPCV
    url(r'^admin/mpcv/new/$', admin.new_multiple_choice_question_with_video, name='admin_new_multiple_choice_question_with_video'),
    url(r'^admin/mpcv/addtotest/(?P<test_id>\d+)/$', admin.new_multiple_choice_question_with_video_to_test, name='admin_new_multiple_choice_question_with_video_to_test'),
    url(r'^admin/mpcv/edit/(?P<question_id>\d+)/$', admin.edit_multiple_choice_question_with_video, name='admin_edit_multiple_choice_question_with_video'),
    url(r'^admin/(?P<test_id>\d+)/mpcv/edit/(?P<question_id>\d+)/$', admin.edit_multiple_choice_question_with_video_for_test, name='admin_edit_multiple_choice_question_with_video_for_test'),
    url(r'^admin/mpcv/add/(?P<test_id>\d+)/$', admin.list_multiple_choice_questions_with_video_not_in_test, name='admin_list_multiple_choice_questions_with_video_not_in_test'),
    url(r'^admin/mpcv/removefromtest/(?P<test_id>\d+)/(?P<question_id>\d+)/$', admin.delete_multiple_choice_question_with_video_from_test, name='admin_delete_multiple_choice_question_with_video_from_test'),
    url(r'^admin/mpcv/delete/(?P<question_id>\d+)/$', admin.delete_multiple_choice_question_with_video, name='admin_delete_multiple_choice_question_with_video'),
    
    # LANDMARK
    url(r'^admin/landmark/new/$', admin.new_landmark_question, name='admin_new_landmark_question'),
    url(r'^admin/landmark/draw/(?P<question_id>\d+)/$', admin.draw_landmark, name='admin_edit_landmark'),
    url(r'^admin/(?P<test_id>\d+)/landmark/draw/(?P<question_id>\d+)/$', admin.draw_landmark, name='admin_draw_landmark'),
    url(r'^admin/(?P<test_id>\d+)/landmark/(?P<question_id>\d+)/delete/$', admin.delete_landmark_question_from_test, name='admin_delete_landmark_question_from_test'),
    url(r'^admin/(?P<test_id>\d+)/landmark/$', admin.add_landmark_question_to_test, name='admin_add_landmark_question_to_test'),
    url(r'^admin/landmark/add/(?P<test_id>\d+)/$', admin.list_landmark_questions_not_in_test, name='admin_list_landmark_questions_not_in_test'),
    url(r'^admin/landmark/delete/(?P<question_id>\d+)/$', admin.delete_landmark_question, name='admin_delete_landmark_question'),
    
    # OUTLINE
    url(r'^admin/outline/new/$', admin.new_outline_question, name='admin_new_outline_question'),
    url(r'^admin/outline/draw/(?P<question_id>\d+)/$', admin.draw_outline, name='admin_edit_outline'),
    url(r'^admin/(?P<question_id>\d+)/outline/draw/(?P<test_id>\d+)/$', admin.draw_outline, name='admin_draw_outline'),
    url(r'^admin/(?P<test_id>\d+)/outline/(?P<question_id>\d+)/delete/$', admin.delete_outline_question_from_test, name='admin_delete_outline_question_from_test'),
    url(r'^admin/(?P<test_id>\d+)/outline/$', admin.add_outline_question_to_test, name='admin_add_outline_question_to_test'),
    url(r'^admin/outline/add/(?P<test_id>\d+)/$', admin.list_outline_questions_not_in_test, name='admin_list_outline_questions_not_in_test'),
    url(r'^admin/outline/delete/(?P<question_id>\d+)/$', admin.delete_outline_question, name='admin_delete_outline_question'),

    # OUTLINE SOLUTION
    url(r'^admin/outlinesolution/new/$', admin.new_outline_solution_question, name='admin_new_outline_solution_question'),
    url(r'^admin/outlinesolution/delete/(?P<question_id>\d+)/$', admin.delete_outline_solution_question, name='admin_delete_outline_solution_question'),
    url(r'^admin/(?P<test_id>\d+)/outline_solution/(?P<question_id>\d+)/delete/$', admin.delete_outline_solution_question_from_test, name='admin_delete_outline_solution_question_from_test'),
    url(r'^admin/outlinesolution/edit/(?P<question_id>\d+)/$', admin.edit_outlinesolution, name='admin_edit_outlinesolution'),
    url(r'^admin/(?P<test_id>\d+)/outline_solution/$', admin.add_outline_solution_question_to_test, name='admin_add_outline_solution_question_to_test'),
    url(r'^admin/outline_solution/add/(?P<test_id>\d+)/$', admin.list_outline_solution_questions_not_in_test, name='admin_list_outline_solution_questions_not_in_test'),
    url(r'^admin/(?P<test_id>\d+)/outline_solution/edit/(?P<question_id>\d+)/$', admin.edit_outline_solution_question_for_test, name='admin_edit_outline_solution_question_for_test'),

]
