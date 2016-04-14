from django.conf.urls import include, url, patterns

urlpatterns = patterns('app.base.views',
    # Site
    url(r'^$', "site.index", name='index'),
    # Admin
    url(r'^admin/$', "admin.index", name='admin_index'),
)
