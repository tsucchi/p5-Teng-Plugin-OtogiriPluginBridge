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

my @sql_statements = split /\n\n/, <<EOSQL;
PRAGMA foreign_keys = ON;

CREATE TABLE person (
  id   INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT    NOT NULL,
  age  INTEGER NOT NULL DEFAULT 20
);

CREATE TABLE detective (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  person_id INTEGER NOT NULL,
  toys      TEXT  NOT NULL,
  FOREIGN KEY(person_id) REFERENCES person(id)
);
EOSQL

$db->do($_) for @sql_statements;

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

subtest 'tableinfo', sub {
    $db->load_otogiri_plugin('TableInfo');
    is_deeply( [sort $db->show_tables()], ['detective', 'person', 'sqlite_sequence'] );

    my $expected = 'CREATE TABLE person (
  id   INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT    NOT NULL,
  age  INTEGER NOT NULL DEFAULT 20
)';

    is( $db->desc('person'), $expected );
};

subtest 'delete_cascade', sub {

    $db->load_otogiri_plugin('DeleteCascade');
    $db->insert('person', {
        name => 'Sherlock Shellingford',
        age  => 15,
    });
    my $person_id = $db->last_insert_id();
    $db->insert('detective', {
        person_id => $person_id,
        toys      => 'Psychokinesis',
    });

    $db->delete_cascade('person', { id => $person_id });

    my $person_row    = $db->single('person',    { id        => $person_id });
    my $detective_row = $db->single('detective', { person_id => $person_id });
    ok( !defined $person_row );
    ok( !defined $detective_row );
};



done_testing;

