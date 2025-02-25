This is a reproduction repo for a bug in the way that sessions work with wildcard routes.

If you visit `/restricted/`, what should happen is the `redirect` session field is set, then you are sent to `/login`, which then logs you in and redirects to the `redirect` field, i.e., back to `/restricted/`, now logged in.

The problem is that with the current code, when inside a scope with a wildcard, the cookie for the session is scoped to the prefix (`/restricted` in this case), so the `/login` handler cannot see it, and thus you are instead redirected to `/`.
