#!/usr/bin/env perl

use strict;
use warnings;

use utf8::all;

use Test::More;
use Text::Diff;
use File::Copy;

use Getopt::Std;
my %opt;
getopts( 'kho', \%opt);
if( $opt{h}) { $opt{k}=1; }

my $t= 't';
my $dmif= "$t/mif";
my $dmml= "$t/mml";
my $dgen= "$t/gen";

my @mifs= @ARGV ? @ARGV : glob( "$dmif/*.mif");

my $html;
local $/="\n\n";
$html= <DATA>;

foreach my $mif (@mifs)
  { my $ok= test_gen( $mif);
    ok( $ok, "$mif"); 
    if( ! $ok && $opt{h})
      { $html .= qq{<tr><td>$mif</td><td>} . slurp( mml( $mif)) . q{</td><td>} . slurp( gen( $mif)) . qq{</td></tr>\n}; }
  }

done_testing();

if( $opt{h})
  { $html .= <DATA>;

    spit( "$t/eq_nat.html", $html);
    $html=~ s{(<!--|-->)}{}g;
    spit( "$t/eq_mj.html", $html);
    warn "output: file:///home/mrodrigu/perl/mif2mml/$t/eq_nat.html and file:///home/mrodrigu/perl/mif2mml/$t/eq_mj.html\n"; 
  }

exit;

sub test_gen
  { my( $mif)= @_;
    my $mml= mml( $mif);
    my $tmp= tmp( $mif);
    my $gen= gen( $mif);

    unlink $tmp; 

    system "./mif2mml $mif";

    if( ! -f $tmp) { warn "  $tmp not generated from $mif\n"; return 0; }
    if( -z $tmp)   { warn "  $tmp generated as empty from $mif\n"; return 0; }

    if( $opt{o}) { copy $tmp, $mml; }

    my $diff= `diff $mml $tmp`;

    if( $opt{k}) { unlink $gen; rename $tmp, $gen; }
    else         { unlink $tmp;       }

    if( $diff) { warn "  diff $mml $tmp\n $diff\n"; return 0; }

    return 1;
  }

sub mml { my( $mif)= @_; return $mif=~ s{$dmif/(.*)\.mif$}{$dmml/$1.mml}r; }
sub tmp { my( $mif)= @_; return $mif=~ s{\.mif$}{.mml}r; }
sub gen { my( $mif)= @_; return $mif=~ s{$dmif/(.*)\.mif$}{$dgen/$1.mml}r; }
    
sub slurp
  { my $file= shift;
    open( my $in, '<', $file) or die "cannot open input file '$file': $!\n";
    local undef $/;
    my $content= <$in>;
    return $content;
  }

sub spit
  { my $file= shift;
    open( my $out, '>:utf8', $file) or die "cannot create file '$file': $!\n";
    print {$out} @_;
  }

__DATA__
<head>
 <title>Equations</title>
 <!--<script type='text/javascript' async src='https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-MML-AM_CHTML'></script>-->
<meta charset="utf-8"/>
</head>
<body>
<table border='2' cellpadding='10' cellspacing='1' style='border-collapse:collapse;'>
<tr><td><b>MIF</b></td><td><b>reference</b></td><td><b>generated</b></td></tr>

</table>    
</body>
</html>

    
