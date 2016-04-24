from django.conf.urls import include, url, patterns

urlpatterns = patterns('app.userprofile.views',
    # User admin
    url(r'^admin/user/new/$', "new_user", name='admin_new_user'),
    url(r'^admin/user/list/$', "list_users", name='admin_list_users'),
    url(r'^admin/user/(?P<user_id>\d+)/$', "view_user", name='admin_view_user'),
    url(r'^admin/user/(?P<user_id>\d+)/delete/$', "delete_user", name='admin_delete_user'),
    url(r'^admin/user/(?P<user_id>\d+)/add_group$', "add_group_to_user", name='admin_add_group_to_user'),
    url(r'^admin/user/delete/(?P<userprofile_id>\d+)/(?P<course_id>\d+)/$', "delete_userprofile", name='admin_delete_userprofile'),
    
    # Group admin
    url(r'^admin/group/new/$', "new_group", name='admin_new_group'),
    url(r'^admin/group/list/$', "list_groups", name='admin_list_groups'),
    url(r'^admin/group/(?P<group_id>\d+)/$', "view_group", name='admin_view_group'),
    url(r'^admin/group/(?P<group_id>\d+)/delete/$', "delete_group", name='admin_delete_group'),
    url(r'^admin/group/(?P<group_id>\d+)/add_group$', "add_user_to_group", name='admin_add_user_to_group'),
    
    url(r'^admin/register/(?P<group_id>\d+)/(?P<user_id>\d+)$', "register_user_in_group", name='admin_register_user_in_group'),
)