use v5.16;
use warnings;

package Set::Associate::ANSIColor::Color {

  # ABSTRACT:

  use Moo;

  sub _croak {
    require Carp;
    goto \&Carp::croak;
  }

  sub _dump {
    require Data::Dump;
    goto \&Data::Dump::pp;
  }

  sub _blessed {
    require Scalar::Util;
    goto \&Scalar::Util::blessed;
  }

  sub _000_555 {
    my @out = 0 .. 5;
    for ( 0 .. 1 ) {
      @out = map {
        my $j = $_;
        map { $j . $_ } 0 .. 5
      } @out;
    }
    return @out;
  }

  has 'name' => ( is => ro =>, required => 1, isa => sub { _croak('must be Str') if not defined $_[0] or ref $_[0] } );
  has 'aliases' => ( is => lazy =>, isa => sub { _croak('must be ArrayRef') unless ref $_[0] and ref $_[0] eq 'ARRAY' } );

  has ansi_foreground_name => ( is => lazy =>, isa => sub { _croak('must be Str') if not defined $_[0] or ref $_[0] } );
  has ansi_background_name => ( is => lazy =>, isa => sub { _croak('must be Str') if not defined $_[0] or ref $_[0] } );

  sub _build_aliases              { [] }
  sub _build_ansi_foreground_name { $_[0]->name }
  sub _build_ansi_background_name { 'on_' . $_[0]->ansi_foreground_name }

  our %colors = ();
  our %sets   = ();

  sub _add_color {
    my ( $name, @rest ) = @_;
    my $v = $colors{$name} = __PACKAGE__->new(
      name => $name,
      @rest
    );
    for my $alias ( @{ $v->aliases } ) {
      $colors{$alias} = $v;
    }
  }

  sub _get_color {
    my ($name) = @_;
    _croak("no such color $name") unless exists $colors{$name};
    return $colors{$name};
  }

  sub _add_set {
    my ( $name, @rest ) = @_;
    $sets{$name} = [ map { ref $_ ? $_ : _get_color($_) } @rest ];
  }

  sub validate {
    my ( $class, $vee ) = @_;
    if ( not defined $vee ) {
      _croak('undef is not a valid color');
    }
    if ( not ref $vee ) {
      return 1 if exists $colors{$vee};
      _croak( _dump($vee) . ' is not a valid color' );
    }
    if ( _blessed($vee) ) {
      _croak( _dump($vee) . ' is not an ' . $class )  unless $vee->isa($class);
      _croak( _dump($vee) . ' is not a valid color' ) unless exists $colors{ $vee->name };
      return 1;
    }
    _croak( _dump($vee) . ' is not a valid color' );
  }

  sub get_named {
    my ( $class, @items ) = @_;
    my @out;
    for my $name (@items) {
      if ( $name =~ /^:(.*$)/ ) {
        my $set = "$1";
        if ( exists $sets{$set} ) {
          push @out, @{ $sets{$set} };
          next;
        }
        _croak(qq{Set $set does not exist});
      }
      if ( exists $colors{$name} ) {
        push @out, $colors{$name};
        next;
      }
      _croak(qq{Color $name does not exist});
    }
    return @out;
  }
  no Moo;

  for my $color (qw( black red green yellow blue magenta cyan white )) {
    _add_color $color;
    _add_color "bright_$color";
  }
  for my $ansi_no ( 0 .. 15 ) {
    _add_color "ansi$ansi_no";
  }
  for my $grey_no ( 0 .. 23 ) {
    _add_color "grey$grey_no";
  }
  for my $rgb (_000_555) {
    _add_color "rgb${rgb}";
  }
  _add_set ansi_normal => qw[ black red green yellow blue magenta cyan white ];
  _add_set ansi_bright => map { "bright_" . $_->name } @{ $sets{ansi_normal} };
  _add_set ansi_full   => @{ $sets{ansi_normal} }, @{ $sets{ansi_bright} };
  _add_set xt_grey     => map { "grey$_" } 0 .. 23;
  _add_set xt_ansi     => map { "ansi$_" } 0 .. 15;
  _add_set xt_rgb      => map { "rgb$_" } _000_555;
}

1;
