from django import test
from django.core.urlresolvers import reverse
from django.urls import RegexURLResolver

from urls import urlpatterns


class UrlsTest(test.TestCase):
    def test_responses(self):
        print(urlpatterns)
        urlpatterns_with_namespace = get_urlpatterns_with_namespace(
            urlpatterns, '')

        print(urlpatterns_with_namespace)

        resolvable_urls = explore_url_tree(urlpatterns_with_namespace, ())

        print(resolvable_urls)

        for url in resolvable_urls:
            reverse_url = reverse(url)
            print('Testing: ', reverse_url)
            response = self.client.get(reverse_url)
            self.assertTrue(response.status_code in [200, 302])


def get_urlpatterns_with_namespace(patterns, namespace):
    return [(namespace, pattern) for pattern in patterns]


def explore_url_tree(urllist, urlnames):
    if not urllist:
        return list(filter(lambda url: url != 'None', urlnames))

    head, *tail = urllist
    namespace, url = head
    if isinstance(url, RegexURLResolver):
        if url.namespace:
            new_urllist = get_urlpatterns_with_namespace(
                url.url_patterns, '{}:'.format(url.namespace)) + tail
            return explore_url_tree(
                new_urllist,
                urlnames, )
        else:
            new_urllist = get_urlpatterns_with_namespace(url.url_patterns,
                                                         '') + tail
            return explore_url_tree(new_urllist, urlnames)
    else:
        if hasattr(url.regex, 'group'):
            return explore_url_tree(tail, urlnames)
        else:
            new_urlnames = urlnames + ('{}{}'.format(namespace, url.name), )
            return explore_url_tree(tail, new_urlnames)
