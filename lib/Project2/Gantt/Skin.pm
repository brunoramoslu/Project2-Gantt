##########################################################################
#
#	File:	Project/Gantt/Skin.pm
#
#	Author:	Alexander Westholm
#
#	Purpose: This object contains visualization preferences that can
#		alter the look and feel of a chart. The default values
#		create a fairly conservative blue/grey scheme.
#
#	Client:	CPAN
#
#	CVS: $Id: Skin.pm,v 1.4 2004/08/02 06:14:41 awestholm Exp $
#
##########################################################################
package Project2::Gantt::Skin;

use Mojo::Base -base;
use Imager::Font;

has primaryText     => 'black';
has secondaryText	=> '#969696';
has primaryFill	    => '#c4dbed';
has secondaryFill   => '#e5e5e5';
has infoStroke      => 'black';
has doTitle         => 1;
has containerStroke	=> 'black';
has containerFill	=> 'grey';
has itemFill        => 'blue';
has background      => 'white';
has font            => sub { Imager::Font->new(file => "Vera.ttf") }; #TODO: Fix me
has doSwimLanes     => 1;

1;
