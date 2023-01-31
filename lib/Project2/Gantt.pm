package Project2::Gantt;

# ABSTRACT: Generate Gantt images

use Mojo::Base -base,-signatures;

use Project2::Gantt::Resource;
use Project2::Gantt::Task;
use Project2::Gantt::ImageWriter;
use Project2::Gantt::DateUtils qw[:compare];
use Project2::Gantt::Skin;

use Mojo::Log;

# DATE
our $VERSION = '0.001';

has root        => undef;
has skin        => sub { Project2::Gantt::Skin->new };
has mode        => 'days';
has file        => undef;
has description => undef;

has tasks       => sub { [] };
has subprojs    => sub { [] };
has resources   => sub { {} };
has parent      => undef;
has subNodes    => 0;
has start       => undef;
has end         => undef;

has log         => sub { Mojo::Log->new };

sub addResource($self,%opts) {
	my $resource = Project2::Gantt::Resource->new(%opts);
	$self->resources->{$opts{name}} = $resource;
	return $resource;
}

sub addTask($self,%opts) {
	die "Must provide resource for task!"   if not $opts{resource};
	die "Must provide start date for task!" if not $opts{start};
	die "Must provide end date for task!"   if not $opts{end};
	if ( not defined $self->parent ) {
		die "Mis-assignment of task resources!!" if not $self->resources->{$opts{resource}->name};
	} else {
		die "Mis-assignment of task resources!" if not defined $self->parent->{resources}->{$opts{resource}->name};
	}
	$opts{start} .= " 09:00:00" if $opts{start} !~ /\:/;
	$opts{end}   .= " 17:00:00" if $opts{end}   !~ /\:/;
	# handle addition to sub-project
	my $tsk = Project2::Gantt::Task->new(%opts);
	$tsk->parent($self);
	$tsk->addResource($opts{resource});
	$tsk->_handleDates();
	push @{$self->tasks}, $tsk;
	$self->incrNodeCount();
}

# allow resource to be assigned for every sub-task
sub addSubProject($self, %opts) {
	$opts{parent} = $self;
	my $prj	= Project2::Gantt->new(%opts);
	push @{$self->subprojs}, $prj;
	$self->incrNodeCount();
	return $prj;
}

sub display($self, $start =  undef, $end =  undef) {
	my $log = $self->log;
	if($self->parent){
		die "Must not call display on sub-project!";
	}
	my $writer = Project2::Gantt::ImageWriter->new(
		root  => $self,
		skin  => $self->skin,
		mode  => $self->mode,
		start => $start,
		end   => $end,
		log   => $log,
	);
	$writer->display($self->file, $start, $end);
}

sub _display($self) {
	my $start	= $self->start;
	my $end		= $self->end;
	if($self->parent){
		# print container bar
		print "SUBPROJECT: $self->description";
	}else{
		# print header
		print "MASTER PROJECT: $self->description";
	}
	print "RUNS FROM: $start to $end";

	for my $tsk (@{$self->tasks}){
		print "TASK: ".$tsk->description;
		print "TASK START: ".$tsk->start;
		print "TASK END: ".$tsk->end;
	}

	for my $sub (@{$self->subprojs}){
		$sub->display();
	}
}

sub _handleDates($self) {
	return if not defined $self->parent;
	my $parent= $self->parent;
	if ( not defined $parent->start or $parent->start > $self->start ) {
		$parent->start($self->start);
	}
    if ( not defined $parent->end or $parent->end < $self->end ) {
		$parent->end($self->end);
	}
    $parent->_handleDates();
}

sub getNodeCount($self, $start = undef, $end = undef) {
	my $log = $self->log;
	$log->debug("getNodeCount start=$start") if defined $start;
	$log->debug("getNodeCount end=$end")     if defined $end;
	my $keep_tasks;
	my $count = 0;

	$keep_tasks = 0;
	for my $task ( $self->tasks->@* ) {
		$log->debug("getNodeCount task " . $task->start . " " . $task->end);
		if ( defined $start and $task->end < $start ) {
			$log->debug("getNodeCount skip task s");
			next;
		}
		if( defined $end and $task->start > $end ) {
			$log->debug("getNodeCount skip task e");
			next;
		}
		$log->debug("getNodeCount count++");
		$keep_tasks = 1;
		$count++;
	}
	$count++ if $keep_tasks;

	for my $subproj ( $self->subprojs->@* ) {
		$log->debug("getNodeCount subproj " . $subproj->start . " " . $subproj->end);
		if ( defined $start and $subproj->end < $start ) {
			$log->debug("getNodeCount skip subproj s");
			next;
		}
		if ( defined $end and $subproj->start > $end ) {
			$log->debug("getNodeCount skip subproj e");
			next;
		}
		$keep_tasks = 0;
		for my $task ( $subproj->tasks->@*) {
			$log->debug("getNodeCount subproj task " . $task->start . " " . $task->end);
			if ( defined $start and $task->end < $start ) {
				$log->debug("getNodeCount skip subproj task s");
				next;
			}
			if ( defined $end and $task->start > $end ) {
				$log->debug("getNodeCount skip subproj task e");
				next;
			}
			$log->debug("getNodeCount count++");
			$keep_tasks = 1;
			$count++;
		}
		$count++ if $keep_tasks;
	}

	$log->debug("subNodes=" . $self->subNodes);
	$log->debug("count=$count");

	return $count;
}

sub incrNodeCount($self) {
	if( not $self->parent ) {
		$self->subNodes($self->subNodes+1);
	} else {
		$self->parent->incrNodeCount();
	}
}

sub timeSpan($self, $start = undef, $end =  undef) {
	my $log     = $self->log;
	my $span    = $self->mode;
	my $copyStr	= $start // Time::Piece->new($self->start);
	my $copyEnd	= $end   // Time::Piece->new($self->end);
	$log->debug("timeSpan $copyStr $copyEnd");
	if ( $span eq 'days') {
		return daysBetween($copyStr, $copyEnd, $log);
	} elsif ( $span eq 'months' ) {
		return monthsBetween($copyStr, $copyEnd, $log);
	} elsif ( $span eq 'hours' ) {
		return hoursBetween($copyStr, $copyEnd, $log);
	} else {
		die 'Bad argument to timeSpan!';
	}
}

1;
