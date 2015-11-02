use utf8;
package TicTacToe::Schema::Result::Player;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TicTacToe::Schema::Result::Player

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<players>

=cut

__PACKAGE__->table("players");

=head1 ACCESSORS

=head2 player_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 password

  data_type: 'varchar'
  is_nullable: 0
  size: 40

=cut

__PACKAGE__->add_columns(
  "player_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "password",
  { data_type => "varchar", is_nullable => 0, size => 40 },
);

=head1 PRIMARY KEY

=over 4

=item * L</player_id>

=back

=cut

__PACKAGE__->set_primary_key("player_id");

=head1 RELATIONS

=head2 games_o_players

Type: has_many

Related object: L<TicTacToe::Schema::Result::Game>

=cut

__PACKAGE__->has_many(
  "games_o_players",
  "TicTacToe::Schema::Result::Game",
  { "foreign.o_player" => "self.player_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 games_x_players

Type: has_many

Related object: L<TicTacToe::Schema::Result::Game>

=cut

__PACKAGE__->has_many(
  "games_x_players",
  "TicTacToe::Schema::Result::Game",
  { "foreign.x_player" => "self.player_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-11-02 21:07:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:E9uDVg/ItWUazwx/gd4cWg

sub to_hashref {
    my $self = shift;
    return { id => $self->id, name => $self->name };
}


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
