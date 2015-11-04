use 5.010;
use strict;
use warnings;

use Test::More tests => 35;
use_ok 'TicTacToe';
use_ok 'TicTacToe::Schema';

my $schema = TicTacToe::Schema->connect("dbi:SQLite:dbname=:memory:");
$schema->deploy;

my $game = $schema->resultset('Game')->create({
    game_id => 1,
    x_player => 10,
    o_player => 42,
    board => '.........',
});

$game->update_status;
is $game->whose_turn, 10,  "X's turn";

my $move_made;
$move_made = $game->make_move('X', 5);
ok $move_made, "X can make a move";
is $game->board, '....X....', "Move made in correct location";
is $game->status, "O's turn",  "status correctly updated";
is $game->whose_turn, 42, "O's turn";

$move_made = $game->make_move('X', 5);
ok !$move_made, "X can't take O's turn";

$move_made = $game->make_move('O', 5);
ok !$move_made, "O can't take an already taken square";

$move_made = $game->make_move('O', 1);
ok $move_made, "O moved";
is $game->board, 'O...X....', "Move made in correct location";
is $game->status, "X's turn",  "status correctly updated";

$game->board('OXOOXXXOX'); $game->update_status;
is $game->status, "Game Over: Tie",  "tie game";

$game->board('OXOOXXXXO'); $game->update_status;
ok $game->is_winner('X'), "X wins";

$game->board('OXOOXXO.X'); $game->update_status;
ok $game->is_winner('O'), "O wins";

$game->board('.XO.XO...'); $game->update_status;
$move_made = $game->make_move('X', 8);
ok $move_made, "X moved";
like $game->status, qr/x wins/i, "X wins from move";

$game->board('XXO.XO...'); $game->update_status;
$move_made = $game->make_move('O', 9);
ok $move_made, "O moved";
like $game->status, qr/o wins/i, "O wins from move";

my @winning_boards = qw<
    XXX......   ...XXX...   ......XXX
    X..X..X..   .X..X..X.   ..X..X..X
    X...X...X   ..X.X.X..
>;

for my $b (@winning_boards) {
    $game->board($b);
    ok $game->is_winner('X'), "$b is a winning board";
    $b =~ s/X/O/g;
    $game->board($b);
    ok $game->is_winner('O'), "$b is a winning board";
}

