package MooseX::StrictConstructor::Trait::Class;
BEGIN {
  $MooseX::StrictConstructor::Trait::Class::VERSION = '0.14';
}

use Moose::Role;

use namespace::autoclean;

use B ();

around '_inline_BUILDALL' => sub {
    my $orig = shift;
    my $self = shift;

    my @source = $self->$orig();

    my @attrs = (
        '__INSTANCE__ => 1,',
        map { B::perlstring($_) . ' => 1,' }
        grep {defined}
        map  { $_->init_arg() } $self->get_all_attributes()
    );

    return (
        @source,
        'my %attrs = (' . ( join ' ', @attrs ) . ');',
        'my @bad = sort grep { !$attrs{$_} } keys %{ $params };',
        'if (@bad) {',
            'Moose->throw_error("Found unknown attribute(s) passed to the constructor: @bad");',
        '}',
    );
};

# If the base class role is applied first, and then a superclass is added, we
# lose the role.
after superclasses => sub {
    my $self = shift;
    return if not @_;
    Moose::Util::MetaRole::apply_base_class_roles(
        for   => $self->name,
        roles => ['MooseX::StrictConstructor::Role::Object'],
    );
};

1;

# ABSTRACT: A role to make immutable constructors strict



=pod

=head1 NAME

MooseX::StrictConstructor::Trait::Class - A role to make immutable constructors strict

=head1 VERSION

version 0.14

=head1 DESCRIPTION

This role simply wraps C<_inline_BUILDALL()> (from
C<Moose::Meta::Class>) so that immutable classes have a
strict constructor.

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2011 by Dave Rolsky.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut


__END__

