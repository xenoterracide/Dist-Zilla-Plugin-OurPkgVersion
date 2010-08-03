use strict;
use warnings;
use 5.010;
package Dist::Zilla::Plugin::OurPkgVersion;
BEGIN {
	our $VERSION = 0.1.0;# VERSION
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

sub munge_file {
	my ( $self, $file ) = @_;
	my $_;

	given ( $file->name ) {
		when ( /\.t$/i ) {
			return;
		}
		when ( /\.(?:pm|pl)$/i ) {
			return $self->_munge_perl($file);
		}
		when ( $file->content =~ /^#!(?:.*)perl(?:$|\s)/ ) {
			return $self->_munge_perl($file);
		}
		default {
			return;
		}
	}
}

sub _munge_perl {
	my ( $self, $file ) = @_;
	my $_;

	my $version = $self->zilla->version;

	croak("invalid characters in version") if $version !~ /\A[.0-9_]+\z/;

	my $content = $file->content;

	my $doc = PPI::Document->new(\$content)
		or croak( PPI::Document->errstr );

	my $comments = $doc->find('PPI::Token::Comment');

	foreach ( @{$comments} ) {
		if ( /^(\s*)(#\s+VERSION\b)$/ ) {
			my $code = "$1" . 'our $VERSION = ' . "$version;$2\n";
			$_->set_content("$code");
		}
	}
	$file->content( $doc->serialize );
}
__PACKAGE__->meta->make_immutable;
1;
# ABSTRACT: no line insertion and does Package version with our


__END__
=pod

=head1 NAME

Dist::Zilla::Plugin::OurPkgVersion - no line insertion and does Package version with our

=head1 VERSION

version 0.1.0

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

=head1 AUTHOR

Caleb Cushing <xenoterracide@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2010 by Caleb Cushing.

This is free software, licensed under:

  The Artistic License 2.0

=cut

