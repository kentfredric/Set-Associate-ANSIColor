use v5.16;
use warnings;

package Set::Associate::ANSIColor::Style {

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

  has 'name' => ( is => ro =>, required => 1, isa => sub { _croak('must be Str') if not defined $_[0] or ref $_[0] } );
  has 'ansi_name' => ( is => lazy => isa => sub { _croak('must be Str') if not defined $_[0] or ref $_[0] } );
  has 'aliases' => ( is => lazy =>, isa => sub { _croak('must be ArrayRef') unless ref $_[0] and ref $_[0] eq 'ARRAY' } );

  sub _build_aliases   { [] }
  sub _build_ansi_name { $_[0]->name }

  our %styles = ();
  our %sets   = ();

  sub _add_style {
    my ( $name, @rest ) = @_;
    my $v = $styles{$name} = __PACKAGE__->new(
      name => $name,
      @rest
    );
    for my $alias ( @{ $v->aliases } ) {
      $styles{$alias} = $v;
    }
  }

  sub _add_set {
    my ( $name, @rest ) = @_;
    $sets{$name} = [ map { $styles{$_} } @rest ];
  }

  sub validate {
    my ( $class, $vee ) = @_;
    if ( not ref $vee ) {
      return 1 if exists $styles{$vee};
      _croak( _dump($vee) . ' is not a valid style' );
    }
    if ( _blessed($vee) ) {
      _croak( _dump($vee) . ' is not an ANSIColor::Style' ) unless $vee->isa($class);
      _croak( _dump($vee) . ' is not a valid style' ) unless exists $styles{ $vee->name };
      return 1;
    }
    _croak( _dump($vee) . ' is not a valid style' );
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
      if ( exists $styles{$name} ) {
        push @out, $styles{$name};
        next;
      }
      _croak(qq{Style $name does not exist});
    }
    return @out;
  }
  no Moo;

  _add_style normal => aliases => [qw( clear reset )], ansi_name => clear =>;
  _add_style bold =>;
  _add_style dark => aliases => [qw( faint )];
  _add_style italic            =>;
  _add_style underline         => aliases => [qw( underscore )];
  _add_style blink             =>;
  _add_style reverse           =>;
  _add_style concealed         =>;
  _add_set all                 => qw[ normal bold dark italic underline blink reverse concealed ];
  _add_set term_xterm          => qw[ normal bold underline blink reverse concealed ];
  _add_set term_linux          => qw[ normal dark bold blink reverse ];
  _add_set term_rxvt           => qw[ normal bold underline reverse ];
  _add_set term_rxvt_unicode   => qw[ normal bold italic underline reverse ];
  _add_set term_dtterm         => qw[ normal bold dark underline reverse concealed ];
  _add_set term_teraterm       => qw[ normal underline reverse ];
  _add_set term_aixterm        => qw[ normal dark underline reverse conceal ];
  _add_set term_putty          => qw[ normal underline reverse ];
  _add_set term_wintelnet      => qw[ normal reverse ];
  _add_set term_cygwinssh      => qw[ normal bold conceal ];
  _add_set term_macterminalapp => qw[ normal bold underline blink reverse conceal ]

}

1;
