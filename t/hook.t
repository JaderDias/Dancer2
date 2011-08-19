use strict;
use warnings;
use Test::More tests => 8;

use Dancer::Core::Hook;

my $h = Dancer::Core::Hook->new(name => 'before_template', code => sub { 'BT' });
is $h->name, 'before_template_render';
is $h->code->(), 'BT';

{
    package Foo;
    use Moo;
    with 'Dancer::Core::Role::Hookable';
}

my $f = Foo->new;

eval { $f->execute_hooks() };
like $@, qr{execute_hook needs a hook name};

eval { $f->execute_hooks('foobar') };
like $@, qr{Hook 'foobar' does not exist};

my $count = 0;
my $some_hook = Dancer::Core::Hook->new(
    name => 'foobar',
    code => sub {
        $count++;
    }
);

eval { $f->add_hook($some_hook)};
like $@, qr{Hook 'foobar' must be installed first};

$f->install_hook('foobar');

eval { $f->install_hook('foobar') };
like $@, qr{Hook 'foobar' is already registered, please use another name};

eval { $f->add_hook($some_hook)};
is $@, '';

$f->execute_hooks('foobar');
is $count, 1;

