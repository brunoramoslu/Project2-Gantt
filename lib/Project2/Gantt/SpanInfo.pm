##########################################################################
#
#	File:	Project/Gantt/SpanInfo.pm
#
#	Author:	Alexander Westholm
#
#	Purpose: This class visually presents data about a given span.
#		It lists the span's description and resource, in a box
#		whose color varies based on whether the task is a
#		container or task.
#
#	Client: CPAN
#
#	CVS: $Id: SpanInfo.pm,v 1.4 2004/08/03 17:56:52 awestholm Exp $
#
##########################################################################
package Project2::Gantt::SpanInfo;

use Mojo::Base -base,-signatures;

use Project2::Gantt::TextUtils;

has canvas => undef;
has task => undef;
has skin => undef;

use constant DESCRIPTION_SIZE => 145;

##########################################################################
#
#	Method: display(height)
#
#	Purpose: Functions as a placeholder to call _writeInfo. Exists
#		incase a preprocessing need arises later.
#
##########################################################################
sub display($self,$height) {
	$self->_writeInfo($height);
}

##########################################################################
#
#	Method:	_writeInfo(height)
#
#	Purpose: Writes information for the task associated with this
#		object onto the canvas. Creates a box for description
#		and another for resource. Background color of these
#		boxes depends on whether the task is a Project::Gantt
#		instance or a Project::Gantt::Task instance.
#
##########################################################################
sub _writeInfo($self, $height) {
	my $task	 = $self->task;
	my $bgcolor	 = $self->skin->primaryFill;
	my $fontFill = $self->skin->primaryText;
	my $canvas	 = $self->canvas;

	$bgcolor     = $self->skin->secondaryFill if $task->isa("Project2::Gantt");
	$fontFill    = $self->skin->secondaryText if $task->isa("Project2::Gantt");

	$canvas->box(
		color  => $bgcolor,
		xmin   => 0,
		ymin   => $height,
		xmax   => DESCRIPTION_SIZE,
		ymax   => $height + 17,
		filled => 1,
	);

	$canvas->box(
		color  => $bgcolor,
		xmin   => DESCRIPTION_SIZE,
		ymin   => $height,
		xmax   => 200,
		ymax   => $height + 17,
		filled => 1,
	);

	print STDERR truncate($task->description,DESCRIPTION_SIZE),"\n";

	#my $color = $task->color // 'black';
	my $color = $fontFill;
	$canvas->string(
		x      => 2,
		y      => $height + 12,
		string => truncate($task->description, DESCRIPTION_SIZE),
		font   => $self->skin->font,
		size   => 10,
		aa     => 1,
		color  => $color,
	);

	# if this is a task, write name... sub-projects aren't associated with
	# a specific resource
	if($task->isa("Project2::Gantt::Task")){
		my $name = truncate($task->resources->[0]->name,55);
		print STDERR "_writeInfo name=$name\n";
		$canvas->string(
			x      => 147,
			y      => $height + 12,
			string => $name,
			font   => $self->skin->font,
			size   => 10,
			aa     => 1,
			color  => 'black',
		);
	}
}

1;
