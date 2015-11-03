use 5.010;
use strict;
use warnings;

use Data::Printer;

use TicTacToe;
use TicTacToe::API;
use TicTacToe::Schema;
use Test::More tests => 2;
use Plack::Test;
use HTTP::Request::Common;

my $app = TicTacToe->to_app;
my $test = Plack::Test->create($app);

# Create a known set of Players
my $schema = TicTacToe::Schema->connect("dbi:SQLite:dbname=:memory:");
$schema->deploy;
$schema->resultset('Player')->populate([
    [ qw< player_id name password > ],
    [ 1, 'Fred', "wilma" ],
    [ 2, 'Barney', "betty" ],
    [ 3, 'Bugs', "carrot" ],
    [ 4, 'Sam', "red" ],
]);

# Create a known set of Games
my $res  = $test->request( GET '/login' );

p $test;
#p $res;
