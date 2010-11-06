use strict;
use warnings;
package Dist::Zilla::Plugin::OurPkgVersion;
BEGIN {
	# VERSION
}
use Moose;
with (
	'Dist::Zilla::Role::FileMunger',
	'Dist::Zilla::Role::FileFinderUser' => {
		default_finders => [ ':InstallModules', ':ExecFiles' ],
	},
);

use PPI;
use Carp qw(croak);
use namespace::autoclean;

sub munge_files {
	my $self = shift;

	$self->munge_file($_) for @{ $self->found_files };
}

sub munge_file {
	my ( $self, $file ) = @_;

	my $version = $self->zilla->version;

	croak("invalid characters in version") if $version !~ /\A[.0-9_]+\z/;

	my $content = $file->content;

	my $doc = PPI::Document->new(\$content)
		or croak( PPI::Document->errstr );

	my $comments = $doc->find('PPI::Token::Comment');

	if ( ref($comments) eq 'ARRAY' ) {
		foreach ( @{ $comments } ) {
			if ( /^(\s*)(#\s+VERSION\b)$/ ) {
				my $code = "$1" . 'our $VERSION = ' . "$version;$2\n";
				$_->set_content("$code");
			}
		}
		$file->content( $doc->serialize );
	}
	else {
		my $fn = $file->name;
		$self->log( "File: $fn"
			+ ' has no comments, consider adding a "# VERSION" commment'
			);
	}
}
__PACKAGE__->meta->make_immutable;
1;
# ABSTRACT: no line insertion and does Package version with our

=head1 SYNOPSIS

in dist.ini

	[OurPkgVersion]

in your modules

	# VERSION

=head1 DESCRIPTION

This module was created as an alternative to
L<Dist::Zilla::Plugin::PkgVersion> and uses some code from that module. This
module is designed to use a the more readable format C<our $VERSION =
$version;> as well as not change then number of lines of code in your files,
which will keep your repository more in sync with your CPAN release. It also
allows you slightly more freedom in how you specify your version.

=head2 EXAMPLES

in dist.ini

	...
	version = 0.01;
	[OurPkgVersion]

in lib/My/Module.pm

	package My::Module;
	# VERSION
	...

output lib/My/Module.pm

	package My::Module;
	our $VERSION = 0.01;# VERSION
	...

please note that whitespace before the comment is significant so

	package My::Module;
	BEGIN {
		# VERSION
	}
	...

becomes

	package My::Module;
	BEGIN {
		our $VERSION = 0.01;# VERSION
	}
	...

while

	package My::Module;
	BEGIN {
	# VERSION
	}
	...

becomes

	package My::Module;
	BEGIN {
	our $VERSION = 0.01;# VERSION
	}
	...

Also note, the package line is not in any way significant, it will insert the
C<our $VERSION> line anywhere in the file before C<# VERSION> as many times as
you've written C<# VERSION> regardless of whether or not inserting it there is
a good idea. OurPkgVersion will not insert a version unless you have C<#
VERSION> so it is a bit more work.

=head1 METHODS

=over

=item munge_files

Override the default provided by L<Dist::Zilla::Role::FileMunger> to limit
the number of files to search to only be modules and executables.

=item munge_file

tells which files to munge, see L<Dist::Zilla::Role::FileMunger>

=back

=cut
