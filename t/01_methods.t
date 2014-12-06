#!/usr/bin/perl
use strict;
use warnings;

use Test::More;
use DBIx::Otogiri;
use List::MoreUtils qw(any);

use t::MyDB;

my $dbfile  = ':memory:';
my $db = t::MyDB->new({
    connect_info         => ["dbi:SQLite:dbname=$dbfile", '', '', { RaiseError => 1, PrintError => 0 }],
    fields_case          => 'NAME',
    suppress_row_objects => 1,
});
$db->load_plugin('OtogiriPluginBridge');

subtest 'methods', sub {
    my @methods = keys %{ *DBIx::Otogiri:: };
    my @unsupported_in_this_plugin = (
        'BEGIN',
        'import',
    );
    for my $method ( @methods ) {
        next if ( $method =~ /::/ ); #namespace
        next if ( any { $method eq $_ } @unsupported_in_this_plugin );

        ok( $db->can($method) ) or diag "$method is not supported";
    }
};

done_testing;

