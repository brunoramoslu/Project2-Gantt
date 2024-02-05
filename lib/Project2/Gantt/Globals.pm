package Project2::Gantt::Globals;
use strict;
use warnings;

use Exporter ();
use vars qw[$DAYSIZE $MONTHSIZE @ISA @EXPORT];

# DATE
our $VERSION = '0.012';

@ISA		= qw[Exporter];

$DAYSIZE	= 15;
$MONTHSIZE	= 60;

@EXPORT		= qw[$DAYSIZE $MONTHSIZE];

1;
