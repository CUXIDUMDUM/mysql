package Qar::DBI::Conf;

use 5.019;
use Data::Dump qw(dump);
use Carp;
use Config::Any;

use MooseX::Singleton;
use MooseX::FileAttribute;
use namespace::autoclean;

has_file 'config_fn' => (
    must_exist => 1,
    required   => 1,
    default    => 'etc/dbi.yml',
);

has 'configs' => (
    is         => 'ro',
    isa        => 'HashRef',
    lazy_build => 1,
);

sub _build_configs {
    my ($self) = @_;

    my $file = $self->config_fn->stringify;
    my $cfg  = Config::Any->load_files( { files => [$file], use_ext => 1, } );

    return $cfg->[0]->{$file};
}

sub get_property {
    my ($self, $property_name, $key, $args) = @_;

    croak "Invalid Key $key" 
        unless exists $self->configs->{$key};
    croak "Invalid property $property_name" 
        unless exists $self->configs->{$key}->{$property_name};

    return $self->configs->{$key}->{$property_name};
}

1;
