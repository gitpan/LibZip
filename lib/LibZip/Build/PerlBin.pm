#############################################################################
## Name:        PerlBin.pm
## Purpose:     LibZip::Build::PerlBin
## Author:      Graciliano M. P.
## Modified by:
## Created:     2004-06-06
## RCS-ID:      
## Copyright:   (c) 2004 Graciliano M. P.
## Licence:     This program is free software; you can redistribute it and/or
##              modify it under the same terms as Perl itself
#############################################################################

package LibZip::Build::PerlBin ;
use 5.006 ;

use strict ;
use vars qw($VERSION) ;

$VERSION = '0.02' ;

use Config ;

use LibZip::CORE ;
use LibZip::Build::UPX ;
  
########
# VARS #
########

  my %opts = (
  type => 'def' ,
  ) ;
  
  my $size_mark     = '##[LBZZ]##' ;
  my $size_mark2    = '##[LBZS]##' ;
  my $allow_v_mark    = '##[LBZV]##' ;
  
  my $LibZipBin_file = 'LibZipBin' . $Config{_exe} ;
  
#################
# FIND PERL BIN #
#################

my ($perlbin_dir , $LibZipBin) ;
{  
  my $perl_x = $^X ;
  $perl_x =~ s/\\/\//g ;
  ($perlbin_dir) = ( $perl_x =~ /^(.*?)\/*[^\/]+\/*$/g );
  
  if ( !-d $perlbin_dir) {
    my $inc_dir ;
    foreach my $INC_i ( @INC ) {
      if ($INC_i =~ /perl\/lib\/*$/i) { $inc_dir = $INC_i ; last ;}
    }
    ($perlbin_dir) = ( $inc_dir =~ /^(.*?\/*[^\/]+)\/+[^\/]+\/*$/g );
    $perlbin_dir .= '/bin'
  }

  my @dirs = ( "blib/arch" , $Config{installarchlib}, $Config{installsitearch} );

  foreach my $d ( @dirs ) {
    my $f = "$d/auto/LibZip/$LibZipBin_file" ;
    if( -s $f ) { $LibZipBin = $f ; last ;}
  }
  
}

############
# PERL2BIN #
############

sub perl2bin {
  my ( $script_file , $exe_name , %opts ) = @_ ;

  die "** Can't find script: $script_file\n" if !-e $script_file ;
  
  my ($script_dir , $filename) = ( $script_file =~ /^(.*?)[\\\/]*([^\\\/]+)$/s ) ;
  $script_dir ||= '.' ;
  
  if ( !$exe_name ) {
    $filename =~ s/\.\w+(?:\.pack)?$// ;
    $exe_name = $script_dir ? "$script_dir/$filename" : $filename ;
    $exe_name .= $Config{_exe} ;    
  }
  
  if (!$opts{overwrite} && -e $exe_name) {
    die "** New binary '$exe_name' already exists!\n" ;
  }
  
  my $binlog = cat($LibZipBin) ;
  die "** The Perl binary was not from LibZip: $LibZipBin\n" if $binlog !~ /\Q$size_mark\E/s ;
  
  my $scriptlog = cat($script_file) ;  
  
  my $bin_lng = length($binlog) ;
  my $script_lng = length($scriptlog) ;
  
  my $size_var = $bin_lng ;
  while(length($size_var) < length($size_mark)) { $size_var = "0$size_var" ;}
  
  my $size_var2 = $script_lng ;
  while(length($size_var2) < length($size_mark2)) { $size_var2 = "0$size_var2" ;}

  $binlog =~ s/\Q$size_mark\E/$size_var/s ;
  $binlog =~ s/\Q$size_mark2\E/$size_var2/s ;
  
  if ( $opts{'allowv'} ) {
    my $val = 1 ;
    while(length($val) < length($allow_v_mark)) { $val = "0$val" ;}
    $binlog =~ s/\Q$allow_v_mark\E/$val/s ;
  }
  
  save($exe_name , $binlog . $scriptlog) ;

  check_perllib_copy($script_dir , $opts{upx}) ;
  
  my ($exe_dir) = ( $exe_name =~ /^(.*?)[\\\/]*[^\\\/]+$/s ) ;
  $exe_dir ||= '.' ;
  
  return( $exe_name , $exe_dir ) if wantarray ;
  return $exe_name ;
}

######################
# CHECK_PERLLIB_COPY #
######################

sub check_perllib_copy {
  my ( $script_dir , $to_upx ) = @_ ;
  
  my $perllib_cp ;
  
  opendir (DIRLOG, $script_dir);
  while (my $filename = readdir DIRLOG) {
    if ($filename =~ /^perl\d+\.(?:dll|so)$/i) { $perllib_cp = 1 ;}
  }
  closedir (DIRLOG);
  
  if (! $perllib_cp) {
    opendir (DIRLOG, $perlbin_dir);
    while (my $filename = readdir DIRLOG) {
      if ($filename =~ /^perl\d+\.(?:dll|so)$/i) {
        my $new_file = "$script_dir/$filename" ;
        warn "PERLLIB saved at $new_file\n" ;
        copy_file("$perlbin_dir/$filename",$new_file) ;
        LibZip::Build::UPX::upx($new_file) if $to_upx ;
      }
    }
    closedir (DIRLOG);
  }
  
}

#############
# COPY_FILE #
#############

sub copy_file {
  my ( $file1 , $file2 ) = @_ ;
  my $buffer ;
  
  open (FILELOG1,$file1) ; binmode(FILELOG1) ;
    open (FILELOG2,">$file2") ; binmode(FILELOG2) ;
    while( sysread(FILELOG1, $buffer , 1024*100) ) { print FILELOG2 $buffer ;}
    close (FILELOG2) ;
  close (FILELOG1) ;
}

#######
# END #
#######

1;
  

