#!/usr/bin/env perl

use strict;
use warnings;

use utf8::all;

use Test::More;
use Text::Diff;
use File::Copy;
use List::MoreUtils qw(natatime);

use Getopt::Std;
my %opt;
getopts( 'd:hko', \%opt);
if( $opt{h}) { $opt{k}=1; }


my $t= $opt{d} || 't';
my $dmif= "$t/mif";
my $dmml= "$t/mml";
my $dgen= "$t/gen";

my @mifs= @ARGV ? @ARGV : glob( "$dmif/*.mif");

# remove previous generated mmls, in case there are some left over
system "rm -f $dmif/*.mml";

# conversion, 100 at a time 
# processing in batch speeds up processing, 
# keeping it at 100 at a time ensures the command line is not too long
# (maybe not needed since we use the list form of system, needs testing)

my $it = natatime 100, @mifs;
while (my @mif_slice = $it->())
      { system './mif2mml', @mif_slice; }

my $html= template_start();

# now we test the results
foreach my $mif (@mifs)
  { my $ok= test_gen( $mif);
    ok( $ok, "$mif"); 
    if( ! $ok && $opt{h})
      { $html .= qq{<tr><td>$mif</td><td>} . slurp( mml( $mif)) . q{</td><td>} . slurp( gen( $mif)) . qq{</td></tr>\n}; }
  }

done_testing();

if( $opt{h})
  { $html .= template_end();

    spit( "$t/eq_nat.html", $html);
    $html=~ s{(<!--|-->)}{}g;
    spit( "$t/eq_mj.html", $html);
    warn "output: $t/eq_nat.html and $t/eq_mj.html\n"; 
  }

exit;

sub test_gen
  { my( $mif)= @_;
    my $mml= mml( $mif);
    my $tmp= tmp( $mif);
    my $gen= gen( $mif);

    if( ! -f $tmp) { warn "  $tmp not generated from $mif\n"; return 0; }
    if( -z $tmp)   { warn "  $tmp generated as empty from $mif\n"; return 0; }

    if( $opt{o}) { copy $tmp, $mml; }

    my $diff= `diff $mml $tmp`;

    if( $opt{k}) { unlink $gen; rename $tmp, $gen; }
    else         { unlink $tmp;                    }

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

sub template_start
  { return <<TS;
<head>
 <title>Equations</title>
 <!--<script type='text/javascript' async src='https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-MML-AM_CHTML'></script>-->
<meta charset="utf-8"/>
</head>
<body>
<table border='2' cellpadding='10' cellspacing='1' style='border-collapse:collapse;'>
<tr><td><b>MIF</b></td><td><b>reference</b></td><td><b>generated</b></td></tr>
TS
  }

sub template_end
  { return <<TE;
</table>    
</body>
</html>
TE
  }

__END__
=head1 NAME

  mif2mml.t

Test a set of MIF fales for regressions

=head1 SYNOPSYS

  ./mif2mml.t -d xt -h # run the tests
  # check the xt/eq_nat.html and xt/eq_mj.html files
  ./mif2mml.t -d xt -o # make the results of the tests the reference

directory structure

  test (or any other name)
    |__ mif  <mif files to test>
    |__ mml  <mml files from a previous run>
    |__ gen  <generated mml files>

  mif2mml -d test 

generates the mml for all mif files in the test/mif/ directory
compares those files with the previously generated files in test/mml
outputs the differences

  mif2mml -d test -h

also outputs 2 files, test/eq_nat.html and test/eq_mj.html which display
each changed equation (both the initial and the new version) the eq_mg.html
file includes a call to MathJax to display the mathML (test/eq_nat.html can 
be displayed in browsers that support MathML natively, like FireFox)

  mif2mml -d test -o

copies the generated mathML files in test/gen to test/mml, so they become the new 
reference

=head1 OPTIONS

   -d <dir>  use <dir> as the base for tests (defaults to t/)
   -k        keep the generated mml (in the mif directory)
   -h        generates html pages (one with MathJax, one without) with the equations that are different
   -o        update the reference (n t/mml) with the new mml generated (use when the tests look OK) 
    
