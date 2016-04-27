from django.conf.urls import include, url, patterns

from .views import users, groups

urlpatterns = patterns('app.userprofile.views',
    # User admin
    url(r'^admin/user/new/$', users.new_user, name='admin_new_user'),
    url(r'^admin/user/list/$', users.list_users, name='admin_list_users'),
    url(r'^admin/user/(?P<user_id>\d+)/$', users.view_user, name='admin_view_user'),
    url(r'^admin/user/(?P<user_id>\d+)/delete/$', users.delete_user, name='admin_delete_user'),
    url(r'^admin/user/(?P<user_id>\d+)/add_group$', users.add_group_to_user, name='admin_add_group_to_user'),
    url(r'^admin/user/delete/(?P<userprofile_id>\d+)/(?P<course_id>\d+)/$', users.delete_userprofile, name='admin_delete_userprofile'),
    
    # Group admin
    url(r'^admin/group/new/$', groups.new_group, name='admin_new_group'),
    url(r'^admin/group/list/$', groups.list_groups, name='admin_list_groups'),
    url(r'^admin/group/(?P<group_id>\d+)/$', groups.view_group, name='admin_view_group'),
    url(r'^admin/group/(?P<group_id>\d+)/delete/$', groups.delete_group, name='admin_delete_group'),
    url(r'^admin/group/(?P<group_id>\d+)/add_group$', groups.list_users_not_in_group, name='admin_list_users_not_in_group'),
    
    url(r'^admin/register/(?P<group_id>\d+)/(?P<user_id>\d+)$', groups.register_user_in_group, name='admin_register_user_in_group'),
)