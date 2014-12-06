package t::MyDB;
use parent qw(Teng);
use strict;
use warnings;

package t::MyDB::Schema;
use strict;
use warnings;
use Teng::Schema::Declare;

table {
    name 'person';
    pk   'id';
    columns qw/id name age/;
};

table {
    name 'detective';
    pk   'id';
    columns qw/id person_id toys/;
};

1;
