#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use Dist::Zilla::Tester;

my $tzil = Dist::Zilla::Tester->from_config({ dist_root => 'corpus/DZT' });

$tzil->build;

my $lib_0 = $tzil->slurp_file('build/lib/DZT0.pm');
my $lib_1 = $tzil->slurp_file('build/lib/DZT1.pm');
my $lib_2 = $tzil->slurp_file('build/lib/DZT2.pm');
my $tst_0 = $tzil->slurp_file('build/t/basic.t'  );

# e short for expected files
# -------------------------------------------------------------------
my $elib_0 = <<'END LIB0';
use strict;
use warnings;
package DZT0;
our $VERSION = 0.1.0;# VERSION
# ABSTRACT: my abstract
1;
END LIB0

my $elib_1 = <<'END LIB1';
use strict;
use warnings;
package DZT1;
BEGIN {
	our $VERSION = 0.1.0;# VERSION
}
# ABSTRACT: my abstract
1;
END LIB1

my $elib_2 = <<'END LIB2';
use strict;
use warnings;
package DZT2;
1;
END LIB2

my $etst_0 = <<'END TST0';
#!/usr/bin/perl
# VERSION
END TST0
# -------------------------------------------------------------------

is ( $lib_0, $elib_0, 'check DZT0.pm' );
is ( $lib_1, $elib_1, 'check DZT1.pm' );
is ( $lib_2, $elib_2, 'check DZT2.pm' );
is ( $tst_0, $etst_0, 'check basic.t' );

done_testing;
