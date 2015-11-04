package TicTacToe::API;

use 5.010;
use Dancer2 appname => 'TicTacToe';
use Dancer2::Plugin::DBIC qw< schema >;
use Dancer2::Plugin::Auth::Tiny;
use Dancer2::Plugin::SendAs;

use constant { EMPTY_BOARD => '.' x 9 };

sub TTTError {
    my $msg = shift;
    return { Error => $msg }
}

get '/game/new' => needs login => sub {
    my $user_id = session 'player_id';
    my $game = schema->resultset('Game')->create({
        x_player => $user_id,
        board => EMPTY_BOARD,
        status => "X's move",
    });
    return send_as json => $game == 0 ? TTTError("unable to create new game") : $game->to_hashref;
};

get '/game/list' => needs login => sub {
    my @games = schema->resultset('Game')->search->all;
    return send_as json => { games => [ map { $_->to_hashref } @games ] }
};

get '/game/show/:gid' => needs login => sub {
    my $game = schema->resultset('Game')->find(param('gid'));
    return send_as json => $game->to_hashref;
};

get '/game/join/:gid' => needs login => sub {
    my $user_id = session 'player_id';
    my $game = schema->resultset('Game')->find(param('gid'));
    $game->update({ o_player => $user_id });
    return send_as json => $game->to_hashref;
};

get '/game/move/:gid/:pos' => needs login => sub {
    my $user_id = session 'player_id';
    my $pos = param('pos');
    return TTTError("Invalid Position: $pos") if $pos < 1 || $pos > 9;
    my $game = schema->resultset('Game')->find(param('gid'));
    return TTTError("Unknown Game: " . param('gid')) if $game == 0;
    return TTTError("Not your turn") if $game->whose_turn != $user_id;
    my $mark = $user_id == $game->x_player ? 'X' : 'O';
    if ($game->make_move($mark, $pos)) {
        return send_as json => $game->to_hashref;
    } else {
        return TTTError("Invalid move");
    }
};

get '/player/list' => needs login => sub {
    my @players = schema->resultset('Player')->search->all;
    return send_as json => { players => [ map { $_->to_hashref } @players ] };
};

true
