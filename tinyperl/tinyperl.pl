{package LibZip::TMP ;
  my $script = shift( @ARGV ) ;
  if (! -e $script || $script eq '') { print STDERR "Can't find file: $script" ; exit ;}

  my $fh ;
  open ($fh, $script) ; binmode($fh);
  my $code ;
  1 while( read($fh, $code , 1024*4 , length($code) ) ) ;
  close ($fh) ;
  $LibZip::TMP::CODE = $code ;
  $LibZip::TMP::SCRIPT = $script ;
}
{package main ;
  eval("\n#line 1 $LibZip::TMP::SCRIPT\n" . $LibZip::TMP::CODE) ;
  die $@ if $@ ;
}

