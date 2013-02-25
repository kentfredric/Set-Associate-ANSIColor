
use v5.16;
use warnings;

use Test::More;

use Set::Associate::ANSIColor;
use Data::Dump qw(pp);

my $s = Set::Associate::ANSIColor->new(
  styles            => [ Set::Associate::ANSIColor::Style->get_named( 'normal', 'bold', 'italic', 'underline' ) ],
  foreground_colors => [ Set::Associate::ANSIColor::Color->get_named(':ansi_full') ],
  background_colors => [ Set::Associate::ANSIColor::Color->get_named(':xt_grey') ],
  on_new_key        => Set::Associate::NewKey::linear_wrap,
);

open my $fh, '-|', 'ls', '-la', '/tmp';
while ( my $line = <$fh> ) {
  my @words = split /(\s+)(\S+)/, $line;
  for my $word (@words) {
    if ( $word =~ /^\s*$/ ) {
      print $word;
      next;
    }
    print $s->get_associated($word)->highlight($word);
  }
}
__END__
for my $name (qw( hello world this is a test world jackdaws love my giant sphinx of quartz )) {
  my $v = $s->get_associated($name);
  print $v->highlight($name) . ' ';
  #say pp $v;
}
done_testing;

