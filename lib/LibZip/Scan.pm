#############################################################################
## Name:        Scan.pm
## Purpose:     LibZip::Scan
## Author:      Graciliano M. P.
## Modified by:
## Created:     2004-06-06
## RCS-ID:      
## Copyright:   (c) 2004 Graciliano M. P.
## Licence:     This program is free software; you can redistribute it and/or
##              modify it under the same terms as Perl itself
#############################################################################

package LibZip::Scan ;
use 5.006 ;

sub BEGIN {
  my %inc ;
  require FindBin ;
  
  eval q{
    use strict qw(vars) ;
    use vars qw($VERSION @ISA) ;
  };
  
  %INC = %inc ;
}

$VERSION = '0.01' ;

#######
# END #
#######

sub END {

  my $scanfile = $FindBin::RealBin . '/libzip.modules' ;

  print "** LibZip::Scan saved at $scanfile\n" ;

  open (LOG,">$scanfile") ;

  foreach my $Key (sort keys %INC ) {
    next if $Key !~ /\.pm$/ ;
    my $pack = $Key ;
    $pack =~ s/\.pm$// ;
    $pack =~ s/[\\\/]+/::/g ;
    print LOG "$pack\n" ;
  }
  
  close (LOG) ;

}

#######
# END #
#######

1;


