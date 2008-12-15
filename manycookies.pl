#!/usr/bin/perl

use strict;
use DBD::SQLite;

my $dbh = DBI->connect("dbi:SQLite:dbname=/android/data/data/com.android.browser/databases/webview.db")
    or die;

$dbh->begin_work or die;
for my $n (1600..50000) {
    print "$n\n" if $n % 10 == 0;
    if ($n % 1000 == 0) {
	$dbh->commit or die;
	$dbh->begin_work or die;
    }
    $dbh->do("INSERT INTO cookies VALUES (NULL, ?, ?, ?, ?, ?, 0)",
	     undef,
	     "cookie$n",
	     "value_of_cookie_is_$n",
	     ($n % 2 ? ".$n.example.com" : "$n.example.com"),
	     "/",
	     time() + int(rand(500000)))
	or die "DBH insert failed: " . $dbh->errstr;
}
$dbh->commit or die;

__END__

sqlite> .schema cookies
    CREATE TABLE cookies (_id INTEGER PRIMARY KEY, name TEXT, value TEXT, domain TEXT, path TEXT, expires INTEGER, secure INTEGER);
CREATE INDEX cookiesIndex ON cookies (path);
