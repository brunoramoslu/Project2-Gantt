package Project2::Gantt::Skin::Medium;

use Mojo::Base 'Project2::Gantt::Skin';

# DATE
our $VERSION = '0.012';

has spanInfoWidth   => 205 + 100;
has titleSize       => 200 + 100;
has descriptionSize => 145 + 100;
has resourceStartX  => 145 + 2 + 60;
has resourceSize    => 55 + 50;

1;
