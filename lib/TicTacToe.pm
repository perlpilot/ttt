package TicTacToe;
use Dancer2;
use Dancer2::Plugin::DBIC qw< schema >;
use Dancer2::Plugin::Auth::Tiny;
use Dancer2::Plugin::Deferred;
use Crypt::SaltedHash;

our $VERSION = '0.1';

sub deploy { schema->deploy; return schema }

get '/' => needs login => sub {
    my $games = schema->resultset('Game')->search->all;
    template 'listgames.tt' => {
        games => $games
    };
};

get '/newplayer' => sub {
    template 'newplayer.tt';
};

post '/newplayer' => sub {
    my $csh = Crypt::SaltedHash->new;
    $csh->add(param('password'));
    my $player = schema->resultset('Player')->find({ name => param('player') });
    if ($player != 0) {
        deferred message => 'A player by that name already exists!';
        redirect uri_for('/newplayer');
    }
    $player = schema->resultset('Player')->create({ 
        name => param('player'),
        password => $csh->generate,
    });
    session 'player' => $player;
    session 'player_id' => $player->id;
    redirect uri_for('/');
};

get '/login' => sub {
    template 'login.tt';
};

post '/login' => sub {
    my $player = schema->resultset('Player')->find({ name => param('player') });

    if ($player == 0) {
        deferred message => 'unknown player';
        redirect uri_for('/login');
    }
    my $valid = Crypt::SaltedHash->validate($player->password, param('password'));
    if (!$valid) {
        deferred message => 'wrong password';
        redirect uri_for('/login');
    }
    session 'player' => $player;
    session 'player_id' => $player->id;
    redirect uri_for('/');
};

get '/logout' => sub {
    app->destroy_session;
    deferred message => 'Successfully logged out';
    redirect uri_for('/');
};

true;
