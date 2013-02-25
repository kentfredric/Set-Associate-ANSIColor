use v5.16;
use warnings;

package Set::Associate::ANSIColor::Highlight {

  use Moo;

  sub _croak {
    require Carp;
    goto \&Carp::croak;
  }

  sub _blessed {
    require Scalar::Util;
    goto \&Scalar::Util::blessed;
  }

  sub _dump {
    require Data::Dump;
    goto \&Data::Dump::pp;
  }

  sub _is_object {
    my ( $class, $object ) = @_;
    return unless ref $object;
    return unless _blessed($object);
    return unless $object->isa($class);
  }

  sub _object {
    _croak( 'Must be an object of class ' . $_[0] . ' got ' . _dump( $_[1] ) ) unless _is_object( $_[0], $_[1] );
  }

  has style            => ( required => 0, is => ro =>, isa => sub { _object( 'Set::Associate::ANSIColor::Style' => @_ ) } );
  has foreground_color => ( required => 0, is => ro =>, isa => sub { _object( 'Set::Associate::ANSIColor::Color' => @_ ) } );
  has background_color => ( required => 0, is => ro =>, isa => sub { _object( 'Set::Associate::ANSIColor::Color' => @_ ) } );

  sub highlight {
    my ( $self, $text ) = @_;
    my @command;
    if ( $self->style ) {
      push @command, $self->style->ansi_name;
    }
    if ( $self->foreground_color ) {
      push @command, $self->foreground_color->ansi_foreground_name;
    }
    if ( $self->background_color ) {
      push @command, $self->background_color->ansi_background_name;
    }
    require Term::ANSIColor;
    return Term::ANSIColor::colored( $text, @command );
  }

}

1;
