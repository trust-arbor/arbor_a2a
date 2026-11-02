"""Exercise Keycloak's real login form, returning only a validated authorization code."""
import html
from pathlib import Path
from html.parser import HTMLParser
import sys
from urllib.parse import parse_qs, urlparse
import urllib.request
import urllib.error
import http.cookiejar
class Response:
    def __init__(self, response):
        self.status_code = response.status
        self.headers = response.headers
        self.text = response.read().decode()
    def raise_for_status(self):
        if self.status_code >= 400: raise RuntimeError('Keycloak HTTP error')
class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl): return None
class LoopbackCookiePolicy(http.cookiejar.DefaultCookiePolicy):
    def return_ok_secure(self, cookie, request):
        if urlparse(request.full_url).hostname == '127.0.0.1': return True
        return super().return_ok_secure(cookie, request)
class Client:
    def __init__(self):
        self.opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar(policy=LoopbackCookiePolicy())), NoRedirect())
    def request(self, request):
        try: return Response(self.opener.open(request, timeout=20))
        except urllib.error.HTTPError as error: return Response(error)
    def get(self, url): return self.request(urllib.request.Request(url))
    def post(self, url, data):
        from urllib.parse import urlencode
        return self.request(urllib.request.Request(url, data=urlencode(data).encode()))

class Form(HTMLParser):
    action = None
    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == 'form' and attrs.get('id') == 'kc-form-login':
            self.action = attrs['action']

url = sys.argv[1]
client = Client()
if True:
    page = client.get(url)
    for _ in range(5):
        if page.status_code != 302: break
        target = page.headers['location']
        if urlparse(target).netloc != urlparse(url).netloc:
            query = parse_qs(urlparse(target).query)
            raise RuntimeError('Authorization redirect error: ' + str(query.get('error')) + ' ' + str(query.get('error_description')))
        page = client.get(target)
    Path('reports/keycloak-login-page.html').write_text(page.text)
    page.raise_for_status()
    form = Form()
    form.feed(page.text)
    if not form.action:
        Path('reports/keycloak-login-page.html').write_text(page.text)
        raise RuntimeError('Keycloak did not return a login form: HTTP ' + str(page.status_code))
    response = client.post(html.unescape(form.action), data={'username': 'alice', 'password': 'fixture-password', 'credentialId': ''})
    if response.status_code != 302:
        raise RuntimeError('Keycloak login failed')
    location = urlparse(response.headers['location'])
    if (location.scheme, location.netloc, location.path) != ('http', '127.0.0.1:4180', '/callback'):
        raise RuntimeError('Unexpected login redirect')
    query = parse_qs(location.query)
    if query.get('state') != [sys.argv[2]]:
        raise RuntimeError('OAuth state mismatch')
    print(query['code'][0])
