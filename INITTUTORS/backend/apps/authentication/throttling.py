"""Login rate limiting (api.md §4.6): 5 requests / 15 min per IP + email."""

import re

from rest_framework.throttling import SimpleRateThrottle

_PERIOD_SECONDS = {"s": 1, "m": 60, "h": 3600, "d": 86400}


class LoginRateThrottle(SimpleRateThrottle):
    scope = "auth"

    def parse_rate(self, rate):
        # Extends DRF's parser to support a period multiplier, e.g. "5/15m".
        if rate is None:
            return (None, None)
        num, period = rate.split("/")
        match = re.match(r"(\d*)([smhd])$", period)
        count = int(match.group(1) or 1)
        return (int(num), count * _PERIOD_SECONDS[match.group(2)])

    def get_cache_key(self, request, view):
        # Key by client IP + submitted email so one attacker can't lock out a
        # whole IP's users, and one email can't be brute-forced across IPs.
        email = (request.data.get("email") or "").lower()
        return f"throttle_auth_{self.get_ident(request)}_{email}"
