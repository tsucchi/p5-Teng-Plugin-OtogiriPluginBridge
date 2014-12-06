package Teng::Plugin::OtogiriPluginBridge;
use 5.008005;
use strict;
use warnings;

use Teng;
use DBI;
use Carp qw();

our $VERSION = "0.01";

our @EXPORT = qw(load_otogiri_plugin select fetch maker last_insert_id strict _deflate_param _inflate_rows);

sub load_otogiri_plugin {
    my ($self_or_class, $pkg, $opt) = @_;
    $pkg = $pkg =~ s/^\+// ? $pkg : "+Otogiri::Plugin::$pkg";
    $self_or_class->load_plugin($pkg, $opt);
}

sub select {
    my $self = shift;
    return $self->search(@_);
}

sub fetch {
    my $self = shift;
    return $self->single(@_);
}

sub maker {
    my $self = shift;
    return $self->{sql_builder};
}

sub last_insert_id {
    my $self = shift;
    return $self->_last_insert_id(@_);
}

sub strict {
    my $self = shift;
    return $self->{sql_builder}->strict;
}

sub _deflate_param {
    my ($self, $table_name, $param) = @_;

    my $table = $self->schema->get_table($table_name);
    if ( !$table ) {
        local $Carp::CarpLevel = $Carp::CarpLevel + 1;
        Carp::croak( "Table definition for $table_name does not exist (Did you declare it in our schema?)" );
    }

    for my $col (keys %{ $param }) {
        $param->{$col} = $table->call_deflate($col, $param->{$col});
    }
    return $param;
}

sub _inflate_rows {
    my ($self, $table_name, @rows) = @_;
    if ( $self->suppress_row_objects ) {
        return wantarray ? @rows : $rows[0];
    }
    my $table = $self->schema->get_table($table_name);
    for my $row ( @rows ) {
        for my $column ( keys %{ $row->get_columns } ) {
            my $data = $table->call_inflate($column, $self->get_column($column));
            $row->set($column, $data);
        }
    }
    return wantarray ? @rows : $rows[0];
}

1;
__END__

=encoding utf-8

=head1 NAME

Teng::Plugin::OtogiriPluginBridge - Load Otogiri plugin into Teng

=head1 SYNOPSIS

    use Teng

    my $db = Teng->new( .. );
    $db->load_plugin('OtogiriPluginBridge');
    $db->load_otogiri_plugin('SomePlugin'); # Loads Otogiri::Plugin::SomePlugin

=head1 DESCRIPTION

THIS SOFTWARE IS ALPHA QUALITY.

Teng::Plugin::OtogiriPluginBridge is ...

=head1 LICENSE

Copyright (C) Takuya Tsuchida.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Takuya Tsuchida E<lt>tsucchi@cpan.orgE<gt>

=cut

