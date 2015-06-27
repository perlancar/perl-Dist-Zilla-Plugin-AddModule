package Dist::Zilla::Plugin::AddModule::FromFS;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Moose;
with (
        'Dist::Zilla::Role::FileGatherer',
);

has name => (is => 'rw', required => 1);
has dest => (is => 'rw', required => 1);

use namespace::autoclean;

sub gather_files {
    require Dist::Zilla::File::InMemory;
    require Module::Path::More;

    my ($self, $arg) = @_;

    $self->log_fatal("Please specify name") unless $self->name;
    $self->log_fatal("Please specify dest") unless $self->dest;

    my $modpath = Module::Path::More::module_path(module => $self->name)
        or $self->log_fatal(["Module %s not found on filesystem", $self->name]);

    my $file = Dist::Zilla::File::InMemory->new(
        name => $self->dest,
        content => do {
            local $/;
            open my($fh), "<", $modpath or
                $self->log_fatal(["Can't open module %s at %s",
                                  $self->name, $modpath]);
            ~~<$fh>;
        });

    $self->log(["Adding module %s (from %s) to %s",
                $self->name, $modpath, $self->dest]);
    $self->add_file($file);
}

__PACKAGE__->meta->make_immutable;
1;
# ABSTRACT: Add module from filesystem

=for Pod::Coverage .+

=head1 SYNOPSIS

In F<dist.ini>:

 [AddModule::FromFS]
 name=Module::List
 dest=t/lib/Module/List.pm

To add more files:

 [AddModule::FromFS / 2]
 name=Module::Path::More
 dest=t/lib/Module/Path/More.pm


=head1 DESCRIPTION

This plugin simply adds a module source file from local filesystem to your
build.


=head1 SEE ALSO

L<Dist::Zilla::Plugin::AddFile::FromFS>
