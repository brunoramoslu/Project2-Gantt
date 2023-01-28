#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

use Mojo::JSON qw(encode_json);

{
    my $value = 1;
    my $value_str = sprintf("%02d",$value);

    cmp_ok($value_str, 'eq', '01');

    my $bytes = encode_json { fields => { customfield_12651 => { value => $value_str } } };

    is($bytes, '{"fields":{"customfield_12651":{"value":"01"}}}');
}

{
    my $value;

    my $bytes = encode_json { fields => { customfield_12651 => $value } };

    is($bytes, '{"fields":{"customfield_12651":null}}');
}

done_testing();

