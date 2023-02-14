package Project2::Gantt::Skin::Large;

use Mojo::Base 'Project2::Gantt::Skin';

# DATE
our $VERSION = '0.007';

has spanInfoWidth   => 205 + 200;
has titleSize       => 200 + 200;
has descriptionSize => 145 + 200;
has resourceStartX  => 145 + 2 + 120;
has resourceSize    => 55 + 100;

1;
