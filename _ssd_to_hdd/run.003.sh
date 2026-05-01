# Final Verification After Logout/Login
# Log out and back in, then run:
find /osa -type l -ls 2>/dev/null | head -20
ls -la / | grep -E "home|srv|opt"
ls -la /var/lib/ | grep docker
