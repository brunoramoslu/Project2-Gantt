##########################################################################
#
#	File:	Project/Gantt/ImageWriter.pm
#
#	Author:	Alexander Westholm
#
#	Purpose: The ImageWriter object coordinates the visualization
#		of scheduling data. It creates the canvas, and all
#		supporting objects that write different aspects of the
#		chart to the screen.
#
#	Client:	CPAN
#
#	CVS: $Id: ImageWriter.pm,v 1.14 2004/08/03 17:56:52 awestholm Exp $
#
##########################################################################
package Project2::Gantt::ImageWriter;

use Mojo::Base -base,-signatures;

use Imager;
use Project2::Gantt::DateUtils qw[:round];
use Project2::Gantt::Globals;
use Project2::Gantt::GanttHeader;
use Project2::Gantt::TimeSpan;
use Project2::Gantt::SpanInfo;

has root => undef;
has mode => 'days';
has skin => undef;
has canvas => undef;

use constant SPAN_INFO_WIDTH => 205;
use constant HEADER_HEIGHT   => 40;
use constant ROW_HEIGHT      => 20;

sub new {
	my $self = shift->SUPER::new(@_);
	$self->_get_canvas();
	return $self;
}

##########################################################################
#
#	Method:	_getCanvas()
#
#	Purpose: This method examines the root node, and sets the width
#		of the canvas based on the timespan covered by the chart,
#		and sets the height based on how many schedule items
#		constitute the chart.
#
##########################################################################
sub _get_canvas($self) {
	my $width  = SPAN_INFO_WIDTH;
	my $height = HEADER_HEIGHT;

	print STDERR "_get_canvas getNodeCount=" . $self->root->getNodeCount(),"\n";

	# add height for each row
	$height += ROW_HEIGHT for (1..$self->root->getNodeCount());

	my $incr = $DAYSIZE;
	$incr = $MONTHSIZE if $self->mode eq 'months';

	# add width for each time unit
	$width += $incr for (1..$self->root->timeSpan());

	my $canvas = Imager->new(xsize => $width, ysize => $height);
	print STDERR "Size: " . $canvas->getwidth() . "x" . $canvas->getheight(),"\n";

	$canvas->box(filled => 1, color => $self->skin->background);

	$self->canvas($canvas);
}

##########################################################################
#
#	Method:	display(filename)
#
#	Purpose: Creates the Calendar header and draws it, then calls
#		writeBars to draw in all tasks/subprojects. Finally,
#		writes the image to a file.
#
##########################################################################
sub display($self, $image) {
	my $header	= Project2::Gantt::GanttHeader->new(
		canvas	=>	$self->canvas,
		skin	=>	$self->skin,
		root	=>	$self->root
	);

	$header->display($self->mode);

    # PW added parameters, required by new writeBars with recursive support
    $self->writeBars($self->root, 40);
	$self->canvas->write(file => $image) or die $self->canvas->errstr;
}

##########################################################################
#
#	Method:	writeBars()
#
#	Purpose: Iterates over all tasks/subprojects contained by the root
#		object, and creates SpanInfo and TimeSpan objects for each
#		item, then draws them.
#       
#       Peter Weatherdon: Jan 19, 2005
#           Modified this method to allow recursion for support of nested
#           projects (more than 1 level deep)
#
##########################################################################
sub writeBars($self, $project, $height) {
	my $stDate  = $self->root->getStartDate();
    my @tasks   = $project->getTasks();
    my @projs   = $project->getSubProjs();

	# write tasks before sub-projects.. adjust height as we go
	for my $task (@tasks,@projs){
		my $info= Project2::Gantt::SpanInfo->new(
			canvas	=>	$self->canvas,
			skin	=>	$self->skin,
			task	=>	$task
		);
		$info->display($height);
		my $bar	= Project2::Gantt::TimeSpan->new(
			canvas	=>	$self->canvas,
			skin	=>	$self->skin,
			task	=>	$task,
			rootStr	=>	$stDate
		);
		$bar->display($self->mode,$height);
		$height	+= 20;

        # if the task is a sub-project then draw recursively
		if($task->isa("Project2::Gantt")){
            $self->writeBars ($task, $height);
		}
	}
}


1;
