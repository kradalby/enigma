from django.conf.urls import include, url, patterns

urlpatterns = patterns('app.quiz.views',
    # Site
    url(r'^$', "site.index", name='index'),
    url(r'^view/(?P<test_id>\d+)$', "site.single_test", name='single_test'),
    url(r'^submit/(?P<test_id>\d+)$', "site.submit_test", name='submit_test'),
    # Admin
    url(r'^admin/$', "admin.index", name='admin_index'),
    url(r'^admin/test/new/$', "admin.new_test", name='admin_new_test'),
    url(r'^admin/test/(?P<test_id>\d+)/$', "admin.add_questions_to_test", name='admin_add_questions_to_test'),
    url(r'^admin/test/(?P<test_id>\d+)/mpc$', "admin.add_mpc_to_test", name='admin_add_mpc_to_test'),
    url(r'^admin/test/(?P<test_id>\d+)/mpci$', "admin.add_mpci_to_test", name='admin_add_mpci_to_test'),
    url(r'^admin/test/(?P<test_id>\d+)/landmark$', "admin.add_landmark_to_test", name='admin_add_landmark_to_test'),
    url(r'^admin/test/(?P<test_id>\d+)/draw/(?P<question_id>\d+)$', "admin.draw_landmark", name='admin_draw_landmark'),
    url(r'^admin/test/list$', "admin.list_tests", name='admin_list_tests'),
    url(r'^admin/testresult/delete$', "admin.delete_test_results", name='admin_delete_test_results'),
)
