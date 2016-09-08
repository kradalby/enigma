from django.conf.urls import url

from .views import users, groups

urlpatterns = [
    # User admin
    url(r'^admin/user/new/$', users.new_user, name='admin_new_user'),
    url(r'^admin/user/list/$', users.list_users, name='admin_list_users'),
    url(r'^admin/user/(?P<user_id>\d+)/$',
        users.view_user, name='admin_view_user'),
    url(r'^admin/user/(?P<user_id>\d+)/edit/$',
        users.edit_user, name='admin_edit_user'),
    url(r'^admin/user/(?P<user_id>\d+)/delete/$',
        users.delete_user, name='admin_delete_user'),
    url(r'^admin/user/(?P<user_id>\d+)/addgroup$', users.list_groups_user_is_not_member_of,
        name='admin_list_groups_user_is_not_member_of'),
    url(r'^admin/user/(?P<user_id>\d+)/resetpassword$',
        users.reset_password_for_user, name='admin_reset_password'),
    url(r'^admin/user/(?P<user_id>\d+)/resetpassword/(?P<view_user_after>\d+)$',
        users.reset_password_for_user, name='admin_reset_password_for_user'),

    # Group admin
    url(r'^admin/group/new/$', groups.new_group, name='admin_new_group'),
    url(r'^admin/group/list/$', groups.list_groups, name='admin_list_groups'),
    url(r'^admin/group/(?P<group_id>\d+)/$',
        groups.view_group, name='admin_view_group'),
    url(r'^admin/group/(?P<group_id>\d+)/delete/$',
        groups.delete_group, name='admin_delete_group'),
    url(r'^admin/group/(?P<group_id>\d+)/addgroup$',
        groups.list_users_not_in_group, name='admin_list_users_not_in_group'),
    url(r'^admin/group/(?P<group_id>\d+)/register/(?P<user_id>\d+)$',
        groups.register_user_in_group, name='admin_register_user_in_group'),
    url(r'^admin/group/(?P<group_id>\d+)/unregister/(?P<user_id>\d+)$',
        groups.unregister_user_from_group, name='admin_unregister_user_from_group'),
    url(r'^admin/group/(?P<group_id>\d+)/generateuser$',
        groups.generate_user_for_group, name='admin_generate_user_for_group'),
    url(r'^admin/group/print/(?P<group_id>\d+)/$',
        groups.group_print_preview, name='admin_group_print_preview'),
    url(r'^admin/group/(?P<group_id>\d+)/remove_user/(?P<user_id>\d+)/$',
        groups.remove_user_from_group, name='admin_remove_user_from_group'),
]
