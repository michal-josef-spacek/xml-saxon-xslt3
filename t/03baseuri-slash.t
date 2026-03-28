use Test::More tests => 2;
use File::Temp qw(tempdir);
use File::Spec::Functions qw(catfile);
use XML::Saxon::XSLT3;

my $dir = tempdir(CLEANUP => 1);

# imported file
my $functions = catfile($dir, 'functions.xsl');
open my $fh_f, '>', $functions or die $!;
print $fh_f <<'XSL';
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
<xsl:template name="hello">
    <out>OK</out>
</xsl:template>
</xsl:stylesheet>
XSL
close $fh_f;

# main stylesheet
my $main = catfile($dir, 'main.xsl');
open my $fh_m, '>', $main or die $!;
print $fh_m <<'XSL';
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
<xsl:import href="functions.xsl"/>

<xsl:template match="/">
    <xsl:call-template name="hello"/>
</xsl:template>
</xsl:stylesheet>
XSL
close $fh_m;

# load stylesheet as string
open my $fh, '<', $main or die $!;
local $/;
my $xslt = <$fh>;
close $fh;

my $xml = '<root/>';

my $transformation = XML::Saxon::XSLT3->new($xslt, $dir); # without '/'
my $output = $transformation->transform($xml);
is($output, '<?xml version="1.0" encoding="UTF-8"?><out>OK</out>',
	'Without trailing slash in base URI');

$transformation = XML::Saxon::XSLT3->new($xslt, $dir.'/');
$output = $transformation->transform($xml);
is($output, '<?xml version="1.0" encoding="UTF-8"?><out>OK</out>',
	'With trailing slash in base URI');
