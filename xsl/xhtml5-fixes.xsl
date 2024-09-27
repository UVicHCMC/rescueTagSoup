<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="#all"
    xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    expand-text="yes"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Sep 27, 2024</xd:p>
            <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
            <xd:p>This stylesheet is designed to fix a range of known issues resulting
            from the initial conversion of HTML tagsoup to XHTML; the objective is 
            to get the output as close as possible to valid XHTML5.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>Output should be HTML5 in the XHTML namespace.</xd:desc>
    </xd:doc>
    <xsl:output method="xhtml" html-version="5" cdata-section-elements="script style" encoding="UTF-8"
        normalization-form="NFC" exclude-result-prefixes="#all"/>
    
    <xd:doc>
        <xd:desc>The default template kicks everything off.</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Attributes no longer needed.</xd:desc>
    </xd:doc>
    <xsl:template match="script/@language"/>
    
    <xd:doc>
        <xd:desc>Old font tag.</xd:desc>
    </xd:doc>
    <xsl:template match="font[@face or @FACE] | FONT[@face or @FACE]">
        <span>
            <xsl:attribute name="style">font-family: {if (@FACE) then @FACE else @face}</xsl:attribute>
        </span>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Attributes whose values should become lower-case.</xd:desc>
    </xd:doc>
    <xsl:template match="input/@TYPE | input/@type">
        <xsl:attribute name="{lower-case(local-name())}" select="lower-case(.)"/>
    </xsl:template>
    
</xsl:stylesheet>