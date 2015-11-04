use utf8;
package TicTacToe::Schema::Result::Game;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TicTacToe::Schema::Result::Game

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<games>

=cut

__PACKAGE__->table("games");

=head1 ACCESSORS

=head2 game_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 x_player

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 o_player

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 board

  data_type: 'char'
  default_value: '.........'
  is_nullable: 0
  size: 9

=head2 status

  data_type: 'string'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "game_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "x_player",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "o_player",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "board",
  {
    data_type => "char",
    default_value => ".........",
    is_nullable => 0,
    size => 9,
  },
  "status",
  { data_type => "string", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</game_id>

=back

=cut

__PACKAGE__->set_primary_key("game_id");

=head1 RELATIONS

=head2 o_player

Type: belongs_to

Related object: L<TicTacToe::Schema::Result::Player>

=cut

__PACKAGE__->belongs_to(
  "o_player",
  "TicTacToe::Schema::Result::Player",
  { player_id => "o_player" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 x_player

Type: belongs_to

Related object: L<TicTacToe::Schema::Result::Player>

=cut

__PACKAGE__->belongs_to(
  "x_player",
  "TicTacToe::Schema::Result::Player",
  { player_id => "x_player" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-11-02 00:59:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JHnp1eXlFZHbwuNYhEZpGQ

use 5.010;

sub whose_turn {
    my ($self) = @_;
    return -1 if $self->game_over;
    my $board = $self->board;
    my $count = $board =~ tr/XO//;
    return -1 if $count == 9;               # no more moves
    return -1 if $self->is_winner('X') or $self->is_winner('O');
    return $count % 2 == 0 ? $self->x_player->id : $self->o_player->id;
}

sub to_hashref {
    my ($self) = @_;
    return  {
        id => $self->id,
        "X Player" => (defined($self->x_player) ? $self->x_player->to_hashref : '-'),
        "O Player" => (defined($self->o_player) ? $self->o_player->to_hashref : '-'),
        status => $self->status,
        board => $self->board,
        };
}

my @winning_positions = (
    [0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]
);

# $side should be "X" or "O"
sub is_winner {
    my ($self, $side) = @_;
    
    my @board = split //, $self->board;
    for my $winner (@winning_positions) {
        return 1 if join("", @board[@{$winner}]) eq $side x 3
    }
    return 0;
}

# Returns one of the following strings:
#   Game Over: Tie
#   Game Over: X wins
#   Game Over: O wins
#   X's turn
#   O's turn
sub status {
    my ($self) = @_;
    my $whose_turn = $self->whose_turn;
    if ($whose_turn == -1) {
        my $status = "Game Over: ";
        if ($self->is_winner('X'))  { $status .= "X wins" }
        if ($self->is_winner('O'))  { $status .= "O wins" }
        else                        { $status .= "Tie" }
        return $status;
    } elsif ($whose_turn == $self->x_player->id) {
        return "X's turn";
    } elsif ($whose_turn == $self->o_player->id) {
        return "O's turn";
    } else {
        return "Unknown Error";
    }
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
