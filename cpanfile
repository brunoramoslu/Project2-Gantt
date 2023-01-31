requires 'Mojo::Base';
requires 'Mojo::Log';
requires 'Imager';
requires 'Alien::Font::Vera';

on 'develop' => sub {
    recommends 'Devel::Camelcadedb';
};
