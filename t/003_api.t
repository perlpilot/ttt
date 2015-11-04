use 5.010;
use strict;
use warnings;

BEGIN { $ENV{'DANCER_ENVIRONMENT'} = 'testing' }

use TicTacToe;
use TicTacToe::API;

use Test::More;

use Plack::Test;
use HTTP::Request::Common;
use Crypt::SaltedHash;
use HTTP::Cookies;
use JSON;

my $csh = Crypt::SaltedHash->new;
# Create a known set of Players
my $schema = TicTacToe->deploy;
$schema->resultset('Player')->populate([
    [ qw< player_id name password > ],
    [ 1, 'fred',    $csh->add("wilma")->generate ],
    [ 2, 'barney',  $csh->add("betty")->generate ],
    [ 3, 'bugs',    $csh->add("carrot")->generate ],
    [ 4, 'sam',     $csh->add("red")->generate ],
]);

my $app = TicTacToe->to_app;

test_psgi $app, sub {
    my $cb = shift;
    my $jar = HTTP::Cookies->new;
    my $site = "http://localhost/";

    my $r = $cb->( POST '/login', [ player => 'fred', password => 'wilma' ]);
    $jar->extract_cookies($r);

    my $req = HTTP::Request->new(GET => $site . '/player/list');
    $jar->add_cookie_header($req);
    $r = $cb->($req); 

    my $hash = from_json($r->decoded_content);

    ok exists($hash->{players});
    ok @{$hash->{players}} == 4, "We've got the 4 users we created";

    $req = HTTP::Request->new(GET => $site . '/game/new');
    $jar->add_cookie_header($req);
    $r = $cb->($req); 

    my $newgame = from_json($r->decoded_content);
    ok $newgame->{'X Player'}->{name} eq 'fred', "fred's game is underway";
    my $gid = $newgame->{'X Player'}->{id};

};


done_testing;
