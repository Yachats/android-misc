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
sqlite> select * from cookies limit 10;
1|Starload|star-fep4|.java.com|/||0
2|JSESSIONID|fc1add3f4804024be9df90f6b72|.java.com|/||0
3|s_cc|true|.java.com|/||0
4|s_sq|%5B%5BB%5D%5D|.java.com|/||0
5|s_vi|[CS]v1|49364C8F0000195D-A02082C00000003[CE]|.sun.com|/|1385975311000|0
6|PREF|ID=20982950ae964298:TM=1228450802:LM=1228450802:S=2zjY5ryfBHlKzNst|.google.com|/|1291522802000|0
8|HID|mail|ss:DQAAAIEAAADvo_GpbIvf9ncvhVDmDPRylmCRa_IjEBQqQxzkzvWlTgMk0LIhQW71QoTEQEo56hkmmmdABEVWK6a2l8elau_kObMOrWe79sOEGhBye064knqCPybTaLNV1lIPeQHPRRoTiFCrthZRoabz9VboIsYW5--RKcx5N8q1CSkH26upZkHb7KWbofW2a-iJO8sA9yw|www.google.com|/a/fitzpat.com/|1229660442000|1
10|HUSR|mail:brad@fitzpat.com|.google.com|/a/fitzpat.com/|1229660442000|1
11|remembermeh|true|www.google.com|/a/fitzpat.com/|1543810842000|0
12|GXAS_SEC|fitzpat.com=DQAAAIAAAADvo_GpbIvf9ncvhVDmDPRylmCRa_IjEBQqQxzkzvWlTgMk0LIhQW71QoTEQEo56hmvZ_rzwJZM_9O03n_wuXht4Mzabm5UV2ldvabecbJXo5jpx4HZ5N4n0vBcZjx8ty6BysCdXPLCiWGqkf-pZ4eppVpZDaQj-MsgA3wKIv3vbg|mail.google.com|/a/||0


