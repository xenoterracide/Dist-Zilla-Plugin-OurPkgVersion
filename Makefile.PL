
use strict;
use warnings;

use 5.008;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "no line insertion and does Package version with our",
  "AUTHOR" => "Caleb Cushing <xenoterracide\@gmail.com>",
  "BUILD_REQUIRES" => {
    "English" => 0,
    "File::Find" => 0,
    "File::Temp" => 0,
    "Scalar::Util" => 0,
    "Test::DZil" => 0,
    "Test::More" => "0.94",
    "Test::Requires" => 0,
    "Test::Version" => "0.04"
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Dist-Zilla-Plugin-OurPkgVersion",
  "EXE_FILES" => [],
  "LICENSE" => "artistic_2",
  "NAME" => "Dist::Zilla::Plugin::OurPkgVersion",
  "PREREQ_PM" => {
    "Carp" => 0,
    "Dist::Zilla::Role::FileFinderUser" => 0,
    "Dist::Zilla::Role::FileMunger" => 0,
    "Moose" => 0,
    "MooseX::Types::Perl" => 0,
    "PPI" => 0,
    "namespace::autoclean" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.003001",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



