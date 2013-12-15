package Qar::DBI::Query;

use Moose;
use namespace::autoclean;
use 5.019;
use Data::Dump qw(dump);
use Carp;
use DBIx::Connector;
use Try::Tiny;

has 'db_conn' => (
    is => 'ro',
    isa => 'DBIx::Connector',
    required => 1,
);

has 'sql' => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has '_sth' => (
    is => 'rw',
    lazy_build => 1,
);

sub _build__sth {
    my ($self) = @_;

    my $sth = $self->db_conn->run(
        fixup => sub {
            my $dbh = $_;
            my $sth   = $dbh->prepare($self->sql);
            $sth->execute();
            $sth;
        },
    );
    return $sth;
}

sub fetchrow {
    my ($self) = @_;
    
    return $self->_sth->fetchrow_array();
}

1;
