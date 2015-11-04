use 5.010;
use strict;
use warnings;

BEGIN { $ENV{DANCER_ENVIRONMENT} = "testing"; }

use TicTacToe;
use Test::More tests => 4;
use Plack::Test;
use HTTP::Request::Common;

my $app = TicTacToe->to_app;
is( ref $app, 'CODE', 'Got app' );

my $test = Plack::Test->create($app);
my $res;

$res  = $test->request( GET '/login' );
ok( $res->is_success, '[GET /login] successful' );

$res  = $test->request( GET '/logout' );
# success causes a redirect
ok( $res->is_redirect, '[GET /logout] successful' );

$res  = $test->request( GET '/newplayer' );
ok( $res->is_success, '[GET /newplayer] successful' );
