use Test::More tests => 2;
use XML::Saxon::XSLT3;

my $xslt = <<'XSLT';
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0">

<xsl:param name="when" as="xs:dateTime"/>

<xsl:template match="/">
    <result value="{$when}">
        <year><xsl:value-of select="year-from-dateTime($when)"/></year>
    </result>
</xsl:template>

</xsl:stylesheet>
XSLT

my $input = <<'XML';
<?xml version="1.0" encoding="UTF-8"?>
<dummy/>
XML

my $transformation = XML::Saxon::XSLT3->new($xslt);
$transformation->parameters(
	'when' => [ datetime => '2010-02-28T12:34:56' ],
);

my $output = $transformation->transform_document($input, 'xml');

is(
	$output->documentElement->getAttribute('value'),
	'2010-02-28T12:34:56',
	'xs:dateTime parameter is passed through correctly',
);

is(
	($output->getElementsByTagName('year'))[0]->textContent,
	'2010',
	'xs:dateTime parameter is really typed as dateTime',
);
