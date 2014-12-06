requires 'DBI';
requires 'Teng';
requires 'perl', '5.008005';

on configure => sub {
    requires 'Module::Build::Tiny', '0.035';
};

on test => sub {
    requires 'DBIx::Otogiri';
    requires 'List::MoreUtils';
    requires 'Teng::Schema::Declare';
    requires 'Test::More', '0.98';
    requires 'parent';
    requires 'Otogiri::Plugin::TableInfo';
    requires 'Otogiri::Plugin::DeleteCascade';
};
