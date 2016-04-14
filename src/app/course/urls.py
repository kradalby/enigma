from django.conf.urls import include, url, patterns

urlpatterns = patterns('app.course.views',
    # Admin
    url(r'^admin/new/$', "admin.new_course", name='admin_new_course'),
    url(r'^admin/list/$', "admin.list_courses", name='admin_list_courses'),
    url(r'^admin/delete/(?P<course_id>\d+)/$', "admin.delete_course", name='admin_delete_course'),
    url(r'^admin/(?P<course_id>\d+)/$', "admin.view_course", name='admin_view_course'),
    url(r'^admin/(?P<course_id>\d+)/edit/$', "admin.edit_course", name='admin_edit_course'),
)
