use Test::More tests => 8;

use Data::Dumper;
 $Data::Dumper::Indent=1;

BEGIN {
    use_ok('Win32::IntAuth')
        or BAIL_OUT('module load failed')
};

my $c_auth = Win32::IntAuth->new(debug => 1);

isa_ok($c_auth, 'Win32::IntAuth')
    or BAIL_OUT("constructor failed");

my @methods = qw/
continue_needed
create_token
get_token_upn
get_username
impersonate
last_err
last_err_txt
new
revert
/;

can_ok($c_auth, @methods)
    or BAIL_OUT('method check failed');

like(my $upn = $c_auth->get_username(), qr/\@/, 'get UPN');

ok(my $token = $c_auth->create_token($upn), 'create token');

my $s_auth = Win32::IntAuth->new(debug => 1);

ok(my $ret = $s_auth->impersonate($token), 'impersonate');

if ( $s_auth->continue_needed() ) {
    my $token2 = $c_auth->create_token($upn, $ret);

    $s_auth->impersonate($token2), 'impersonate'
        or BAIL_OUT('impersonation failed');
}

is(my $new_upn = $s_auth->get_username(), $upn, 'get impersonated UPN');

ok($s_auth->revert(), 'revert context');
