#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use Project2::Gantt;

my $gantt = Project2::Gantt->new(
    description => 'Normal day',
    mode        => 'hours',
    file        => 'gantt-hours.png',
);

isa_ok($gantt, 'Project2::Gantt', 'Project2::Gantt->new');

my $resource  = $gantt->addResource(name => 'John Doe');

$gantt->addTask(
    description => 'Sleep',
    resource    => $resource,
    mode        => 'hours',
    start       => '2023-01-17 22:00:00',
    end         => '2023-01-18 06:30:00',
);

$gantt->addTask(
    description => 'Shower',
    resource    => $resource,
    mode        => 'hours',
    start       => '2023-01-18 06:30:00',
    end         => '2023-01-18 07:00:00',
);

$gantt->addTask(
    description => 'Breakfast',
    resource    => $resource,
    mode        => 'hours',
    start       => '2023-01-18 07:00:00',
    end         => '2023-01-18 07:30:00',
);

$gantt->addTask(
    description => 'Drive to work',
    resource    => $resource,
    mode        => 'hours',
    start       => '2023-01-18 07:30:00',
    end         => '2023-01-18 08:30:00',
);

$gantt->addTask(
    description => 'Work',
    resource    => $resource,
    mode        => 'hours',
    start       => '2023-01-18 08:30:00',
    end         => '2023-01-18 12:30:00',
);

$gantt->addTask(
    description => 'Lunch',
    resource    => $resource,
    mode        => 'hours',
    start       => '2023-01-18 12:30:00',
    end         => '2023-01-18 13:30:00',
);

$gantt->addTask(
    description => 'Work',
    resource    => $resource,
    mode        => 'hours',
    start       => '2023-01-18 13:30:00',
    end         => '2023-01-18 17:30:00',
);

$gantt->addTask(
    description => 'Drive home',
    resource    => $resource,
    mode        => 'hours',
    start       => '2023-01-18 17:30:00',
    end         => '2023-01-18 18:30:00',
);

$gantt->write;

done_testing;
