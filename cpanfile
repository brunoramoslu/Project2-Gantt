requires 'Alien::Font::Vera';
requires 'Imager';
requires 'Mojo::Base';
requires 'Mojo::JSON';
requires 'Mojo::Log';

on 'develop' => sub {
    recommends 'Devel::Camelcadedb';
};
