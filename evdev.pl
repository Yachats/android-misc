#!/usr/bin/perl

use strict;
open(my $fh, "/dev/input/event2") or die;
while (1) {
    my $buf;
    my $rv = sysread($fh, $buf, 32);
    print "Read: $rv\n";
    my ($tsec, $tusec, $type, $code, $value) =
	unpack("LLSSl", $buf);
    print "[@ $tsec / $tusec] type=$type, code=$code, value=$value\n";
}
