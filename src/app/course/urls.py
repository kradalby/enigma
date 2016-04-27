from django.conf.urls import include, url, patterns

from .views import admin

app_name = "course"

urlpatterns = [
    # Admin
    url(r'^admin/new/$', admin.new_course, name='admin_new_course'),
    url(r'^admin/list/$', admin.list_courses, name='admin_list_courses'),
    url(r'^admin/delete/(?P<course_id>\d+)/$', admin.delete_course, name='admin_delete_course'),
    url(r'^admin/(?P<course_id>\d+)/$', admin.view_course, name='admin_view_course'),
    url(r'^admin/(?P<course_id>\d+)/edit/$', admin.edit_course, name='admin_edit_course'),
    url(r'^admin/(?P<course_id>\d+)/addrandomuser/$', admin.add_random_user_to_course, name='admin_add_random_user_to_course'),
    url(r'^admin/(?P<course_id>\d+)/addgroup/$', admin.add_group_to_course, name='admin_add_group_to_course'),
    url(r'^admin/(?P<course_id>\d+)/registergroup/(?P<group_id>\d+)/$', admin.register_group_to_course, name='admin_register_group_to_course'),
    url(r'^admin/(?P<course_id>\d+)/unregistergroup/(?P<group_id>\d+)/$', admin.unregister_group_from_course, name='admin_unregister_group_from_course'),
    
    url(r'^admin/(?P<user_id>\d+)/adduser/$', admin.add_user_to_course, name='admin_add_user_to_course'),
    url(r'^admin/(?P<user_id>\d+)/register/(?P<course_id>\d+)/$', admin.register_user_to_course, name='admin_register_user_to_course'),
]

