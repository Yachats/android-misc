#!/usr/bin/perl
# Author: Brad Fitzpatrick <brad@danga.com>, 2008-12-14
# License: whatever.

use strict;
use File::Temp;
use Time::HiRes qw(time);

my $boot_time = boot_time();

my $keyboard = "/dev/input/event2";
unless (-c $keyboard) {
    require File::Temp;
    my ($fh, $filename) = File::Temp::tempfile();
    unlink($filename);  # race!
    system("mknod", $filename, "c", 13, 66) and die "mknod failed.";
    $keyboard = $filename;
}

system("stty", '-icanon', 'eol', "\001")
    and die "stty failed";

open(my $fh, ">$keyboard")
    or die "Opening keyboard for write failed.";

my %code_map = (
    chr(127) => 14,  # backspace
    "\x1b[A" => 103, # up arrow
    "\x1b[B" => 108, # down arrow
    "\x1b[C" => 105, # left arrow
    "\x1b[D" => 106, # right arrow
    "\x1b[3~" => 111,  # delete
    ' ' => 57,
    from(16, "qwertyuiop{}\n"),
    from(30, "asdfghjkl;'"),
    "\\" => 43,
    from(44, "zxcvbnm,./"),
    from(2, "1234567890"),
    );

sub from {
    my ($num, $letters) = @_;
    my @ret;
    foreach my $letter (split //, $letters) {
        push @ret, ($letter => $num++);
    }
    return @ret;
}

while (1) {
    my $key = getc(STDIN);

    if ($key eq "\033") {
        $key .= getc(STDIN);
        $key .= getc(STDIN);
        if ($key eq "\x1b[3") {
            $key .= getc(STDIN);
        }
    }

    my $shift_down = 0;
    if ($key =~ /^[A-Z]$/) {
        $shift_down = 1;
        syswrite($fh, event(42, 1));  # left shift
        $key = lc($key);
    }

    my $code = $code_map{$key};

    unless (defined $code) {
        if (length($key) == 1) {
            print "UNKNOWN KEY!  key=$key, ord=", ord($key), "\n";
        } else {
            $key =~ s/[^[:print:]]/sprintf("\\x%02x", ord($&))/eg;
            print "UNKNOWN SEQUENCE: $key\n";
        }
        next;
    }


    syswrite($fh, event($code, 1));
    syswrite($fh, event($code, 0));

    if ($shift_down) {
        # let it go
        syswrite($fh, event(42, 0));
    }

}

sub event {
    my ($code, $down) = @_;
    my $event_time = time() - $boot_time;
    my $evtime_sec = int($event_time);
    my $evtime_usec = int(($event_time - $evtime_sec) * 1e9);
    return pack("LLSSl",
                $evtime_sec, $evtime_usec,
                1,   # keyboard event
                $code,
                $down);
}

sub boot_time {
    open(my $fh, "/proc/uptime") or die;
    my $line = <$fh>;
    $line =~ s/\s.*//;
    return time() - $line;
}
