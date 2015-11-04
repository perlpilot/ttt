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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-11-03 22:29:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gV7gohcUjGugL8e64DAjnw

use 5.010;

# returns a true value if the move can be made and a false value if
# it can not
sub make_move {
    my ($self, $mark, $pos) = @_;
    return 0 if $mark ne 'X' and $mark ne 'O';
    return 0 if $self->status !~ /^$mark/;
    return 0 if $pos < 1 or $pos > 9;
    return 0 if substr($self->board, $pos-1, 1) ne '.';
    my $board = $self->board;
    substr($board, $pos-1, 1) = $mark;
    $self->board($board);
    # Update the game status on each move
    $self->update_status;
    # write our updates to the database
    $self->update;
    return 1;
}

sub update_status {
    my ($self) = @_;

    if ($self->is_winner('X')) {
        $self->status("Game Over: X Wins");
    }
    elsif ($self->is_winner('O')) {
        $self->status("Game Over: O Wins");
    }
    else {
        my $taken = $self->board =~ tr/XO//;
        if ($taken == 9) {
            $self->status("Game Over: Tie");
        }
        else {
            $self->status($taken % 2 == 0 ? "X's turn" : "O's turn");
        }
    }

}

sub whose_turn {
    my ($self) = @_;
    return -1 if $self->status =~ /game over/i;
    $self->status =~ /^X/ ? $self->x_player->player_id : $self->o_player->player_id;
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

# $mark should be "X" or "O"
sub is_winner {
    my ($self, $mark) = @_;
    
    my @board = split //, $self->board;
    for my $winner (@winning_positions) {
        return 1 if join("", @board[@{$winner}]) eq $mark x 3
    }
    return 0;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
