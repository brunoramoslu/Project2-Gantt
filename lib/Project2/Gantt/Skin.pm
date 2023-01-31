package Project2::Gantt::Skin;

use Mojo::Base -base;
use Imager::Font;
use Alien::Font::Vera;

# DATE
our $VERSION = '0.002';

has primaryText     => 'black';
has secondaryText	=> '#363636';
has primaryFill	    => '#c4dbed';
has secondaryFill   => '#e5e5e5';
has infoStroke      => 'black';
has doTitle         => 1;
has containerStroke	=> 'black';
has containerFill	=> 'grey';
has itemFill        => 'blue';
has background      => 'white';
has font            => sub { Imager::Font->new(file => Alien::Font::Vera::path) };
has doSwimLanes     => 1;

1;
