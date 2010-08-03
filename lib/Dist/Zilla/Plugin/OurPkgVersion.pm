use strict;
use warnings;
use 5.010;
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
	my ( $self ) = shift;
	my $_;

	$self->munge_file($_) for @{ $self->found_files };
}

sub munge_file {
	my ( $self, $file ) = @_;
#	my $_;

	given ( $file->name ) {
		when ( /\.t$/i ) {
			return;
		}
		when ( /\.(?:pm|pl)$/i ) {
			return $self->munge_perl($file);
		}
		when ( $file->content =~ /^#!(?:.*)perl(?:$|\s)/ ) {
			return $self->munge_perl($file);
		}
		default {
			return;
		}
	}
}

sub munge_perl {
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
