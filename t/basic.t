use strict;
use warnings;

use Test::More tests => 15;


{
    package Standard;

    use Moose;

    has 'thing' => ( is => 'rw' );
}

{
    package Stricter;

    use Moose;
    use MooseX::StrictConstructor;

    has 'thing' => ( is => 'rw' );
}

{
    package Subclass;

    use Moose;
    use MooseX::StrictConstructor;

    extends 'Stricter';

    has 'size' => ( is => 'rw' );
}

{
    package Tricky;

    use Moose;
    use MooseX::StrictConstructor;

    has 'thing' => ( is => 'rw' );

    sub BUILD
    {
        my $self   = shift;
        my $params = shift;

        delete $params->{spy};
    }
}

{
    package InitArg;

    use Moose;
    use MooseX::StrictConstructor;

    has 'thing' => ( is => 'rw', 'init_arg' => 'other' );
    has 'size'  => ( is => 'rw', 'init_arg' => undef );
}

{
    package ImmutableInitArg;

    use Moose;
    use MooseX::StrictConstructor;

    has 'thing' => ( is => 'rw', 'init_arg' => 'other' );
    has 'size'  => ( is => 'rw', 'init_arg' => undef );

    no Moose;
    __PACKAGE__->meta()->make_immutable();
}

{
    package Immutable;

    use Moose;
    use MooseX::StrictConstructor;

    has 'thing' => ( is => 'rw' );

    no Moose;
    __PACKAGE__->meta()->make_immutable();
}

{
    package ImmutableTricky;

    use Moose;
    use MooseX::StrictConstructor;

    has 'thing' => ( is => 'rw' );

    sub BUILD
    {
        my $self   = shift;
        my $params = shift;

        delete $params->{spy};
    }

    no Moose;
    __PACKAGE__->meta()->make_immutable();
}


eval { Standard->new( thing => 1, bad => 99 ) };
is( $@, '', 'standard Moose class ignores unknown params' );

eval { Stricter->new( thing => 1, bad => 99 ) };
like( $@, qr/unknown attribute.+: bad/, 'strict constructor blows up on unknown params' );

eval { Subclass->new( thing => 1, size => 'large' ) };
is( $@, '', 'subclass constructor handles known attributes correctly' );

eval { Tricky->new( thing => 1, spy => 99 ) };
is( $@, '', 'can work around strict constructor by deleting params in BUILD()' );

eval { Tricky->new( thing => 1, agent => 99 ) };
like( $@, qr/unknown attribute.+: agent/, 'Tricky still blows up on unknown params other than spy' );

eval { Subclass->new( thing => 1, bad => 99 ) };
like( $@, qr/unknown attribute.+: bad/, 'subclass constructor blows up on unknown params' );

eval { InitArg->new( thing => 1 ) };
like( $@, qr/unknown attribute.+: thing/,
      'InitArg blows up with attribute name' );

eval { InitArg->new( size => 1 ) };
like( $@, qr/unknown attribute.+: size/,
      'InitArg blows up when given attribute with undef init_arg' );

eval { InitArg->new( other => 1 ) };
is( $@, '',
    'InitArg works when given proper init_arg' );

eval { ImmutableInitArg->new( thing => 1 ) };
like( $@, qr/unknown attribute.+: thing/,
      'ImmutableInitArg blows up with attribute name' );

eval { ImmutableInitArg->new( size => 1 ) };
like( $@, qr/unknown attribute.+: size/,
      'ImmutableInitArg blows up when given attribute with undef init_arg' );

eval { ImmutableInitArg->new( other => 1 ) };
is( $@, '',
    'ImmutableInitArg works when given proper init_arg' );

eval { Immutable->new( thing => 1, bad => 99 ) };
like( $@, qr/unknown attribute.+: bad/,
      'strict constructor in immutable class blows up on unknown params' );

eval { ImmutableTricky->new( thing => 1, spy => 99 ) };
is( $@, '',
    'immutable class can work around strict constructor by deleting params in BUILD()' );

eval { ImmutableTricky->new( thing => 1, agent => 99 ) };
like( $@, qr/unknown attribute.+: agent/,
      'ImmutableTricky still blows up on unknown params other than spy' );
