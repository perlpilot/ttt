create table players (
    player_id integer primary key autoincrement,
    name varchar(32) not null,
    password varchar(40) not null
);
create table games (
    game_id integer primary key autoincrement,
    x_player integer,
    o_player integer,
    board char(9) not null default '.........',
    game_over boolean default 0,
    foreign key(x_player) references players(player_id),
    foreign key(o_player) references players(player_id)
);
