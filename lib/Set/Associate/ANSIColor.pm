use v5.16;
use warnings;

package Set::Associate::ANSIColor {

  # ABSTRACT: Associate things with colors via ANSI

=head1 DESCRIPTION

This does no highlighting in itself, that is left to the consuming class.

All this is is a wrapper that pregenerates a pool of ANSI Colors/Styles
with some generational benefits.

=head1 SYNOPSIS

    use Set::Associate::ANSIColor;

    my $sa = Set::Associate::ANSIColor->new(
        styles => [ Set::Associate::ANSIColor::Style->get_named(':all') ],
        foreground_colors => [ Set::Associate::ANSIColor::Color->get_named(':xt_rgb') ],
        background_colors => [ Set::Associate::ANSIColor::Color->get_named(':xt_rgb') ],
        on_new_key => Set::Associate::NewKey::random_pick,
    );

    sub highlight { 
        my ($token) = @_ ;
        my $highlighter = $sa->get_associated( $token );
        return $highlighter->highlight( $token );
    }



=cut

  use Moo;
  use Set::Associate::ANSIColor::Style;
  use Set::Associate::ANSIColor::Color;
  use Set::Associate::ANSIColor::Highlight;

  extends 'Set::Associate';

  sub _croak {
    require Carp;
    goto \&Carp::croak;
  }
  sub _is_arrayref { $_[0] and ref $_[0] and ref $_[0] eq 'ARRAY' }
  sub _is_style    { Set::Associate::ANSIColor::Style->validate( $_[0] ) }
  sub _is_color    { Set::Associate::ANSIColor::Color->validate( $_[0] ) }
  sub _tc_arrayref { _croak('Should be an ArrayRef[ ANSI Style ]') unless _is_arrayref( $_[0] ) }

  sub _tc_arraystyle {
    for my $i ( @{ $_[0] } ) {
      next if _is_style($i);
      _croak( 'Item <' . $i . '> is not a style' );
    }
  }

  sub _tc_arraycolor {
    for my $i ( @{ $_[0] } ) {
      next if _is_color($i);
      _croak( 'Item <' . $i . '> is not a color' );
    }
  }

  has '+items' => (
    init_arg => undef,
    is       => lazy =>,
  );

  has styles => (
    isa => sub {
      _tc_arrayref( $_[0] );
      _tc_arraystyle( $_[0] );
    },
    is => lazy =>,
  );
  has foreground_colors => (
    isa => sub {
      _tc_arrayref( $_[0] );
      _tc_arraycolor( $_[0] );
    },
    is => lazy =>,
  );
  has background_colors => (
    isa => sub {
      _tc_arrayref( $_[0] );
      _tc_arraycolor( $_[0] );
    },
    is => lazy =>,
  );

  sub _build_items {
    my ($self) = @_;
    my @out;
    for my $style ( @{ $self->styles } ) {
      for my $background ( @{ $self->background_colors } ) {
        for my $foreground ( @{ $self->foreground_colors } ) {
          push @out,
            Set::Associate::ANSIColor::Highlight->new(
            style            => $style,
            background_color => $background,
            foreground_color => $foreground,
            ) unless $background->name eq $foreground->name;
        }
      }
    }
    return \@out;
  }

  sub _build_styles {
    return [ Set::Associate::ANSIColor::Style->get_named(':all') ];
  }

  sub _build_foreground_colors {
    return [ Set::Associate::ANSIColor::Color->get_named(':ansi_full') ];
  }

  sub _build_background_colors {
    return [ Set::Associate::ANSIColor::Color->get_named('black') ];
  }

  no Moo;
}

1;

