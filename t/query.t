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

my $CLASS = q(Qar::DBI);

use_ok($CLASS);

my $dbi = $CLASS->new();
my $db_key = "bar";

my $sql = "SELECT * FROM BAR";
my $execute = $dbi->query($db_key, $sql);

while ( my $row = $execute->fetchrow ) {
    say dump($row);
}

done_testing();
