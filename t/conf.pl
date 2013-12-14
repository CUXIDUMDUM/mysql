#!/usr/bin/env perl
use strict;
use warnings;
use 5.016;
use FindBin;
use File::Spec;
use lib File::Spec->catfile($FindBin::Bin, '..', 'lib');
use lib File::Spec->catfile($FindBin::Bin, '..', 't', 'lib');
use Data::Dump qw/dump/;
use English qw( -no_match_vars );
use Carp;
use Readonly;
use Test::More;
use DBIx::Connector;
use Try::Tiny;

my $CLASS = q(Qar::DBI::Conf);

use_ok($CLASS);

my $conf = $CLASS->new();
my $db_key = "bar";

my @connect_args = ( $conf->get_property("dsn",$db_key),
    $conf->get_property("username",$db_key),
    $conf->get_property("password",$db_key),
    { RaiseError => 1, AutoCommit => 0 },
);

my $db_conn = DBIx::Connector->new(@connect_args);

isa_ok($db_conn, "DBIx::Connector");
isa_ok($db_conn->dbh, "DBI::db");

my $sql = q(INSERT INTO BAR VALUES (?));
my $sth = $db_conn->run(
    fixup => sub {
        my $dbh = $_;
        my $sth   = $dbh->prepare($sql);
        my $value = 'barvijay' . $$ . int(rand(7));
        $sth->bind_param( 1, $value );
        try {
            $sth->execute();
            $dbh->commit;
        }
        catch {
            warn "Error $_";
            $dbh->rollback;
        };
        $sth;
    },
);

$sth->finish();

$sql = q(SELECT * from BAR where name like ?);
$sth = $db_conn->run(fixup => sub {
        my $sth = $_->prepare($sql);
        my $value = 'barvijay%';
        $sth->bind_param(1, $value);
        $sth->execute();
        $sth;
    },
);

say dump($sth->fetchall_arrayref());
$sth->finish();

$sql = q(UPDATE BAR set name=? where name like ?);
$sth = $db_conn->run(
    fixup => sub {
        my $dbh = $_;
        my $sth   = $dbh->prepare($sql);
        my $value = $$ .'barvijay' . int(rand(100000));
        $sth->bind_param( 1, $value );
        $sth->bind_param( 2, "barvijay31" );
        try {
            $sth->execute();
            $dbh->commit;
        }
        catch {
            warn "Error $_";
            $dbh->rollback;
        };
        $sth;
    },
);

$sth->finish();

$sql = q(SELECT * from BAR where name like ?);
$sth = $db_conn->run(fixup => sub {
        my $sth = $_->prepare($sql);
        my $value = '%';
        $sth->bind_param(1, $value);
        $sth->execute();
        $sth;
    },
);

say dump($sth->fetchall_arrayref());
$sth->finish();

done_testing();
