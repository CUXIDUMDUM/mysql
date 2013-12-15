package Qar::DBI;

use Moose;
use namespace::autoclean;
use 5.019;
use Data::Dump qw(dump);
use Carp;
use DBIx::Connector;
use Qar::DBI::Conf;
use Qar::DBI::Query;

has 'dbi_conf' => (
    is => 'ro',
    isa => 'Qar::DBI::Conf',
    lazy_build => 1,
);

sub _build_dbi_conf {
    my ($self) = @_;
    return Qar::DBI::Conf->instance();
}

sub get_db_conn {
    my ($self,$key) = @_;

    my @connect_args = (
        $self->dbi_conf->get_property("dsn", $key),
        $self->dbi_conf->get_property("username", $key),
        $self->dbi_conf->get_property("password", $key),
        { RaiseError => 1, AutoCommit => 0 },
    );

    return DBIx::Connector->new(@connect_args);
}

sub query {
    my ($self, $db_key, $sql) = @_;

    return Qar::DBI::Query->new( db_conn => $self->get_db_conn($db_key), sql => $sql);
}

1;
