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
    <xsl:output method="xhtml" html-version="5" cdata-section-elements="script" encoding="UTF-8"
        normalization-form="NFC" exclude-result-prefixes="#all" omit-xml-declaration="yes"/>
    
    <!-- This is an identity transform essentially. -->
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xd:doc>
        <xd:desc>We need a sequence of obsolete attribute names so that we can 
        intervene for elements that carry them and construct CSS classes.</xd:desc>
    </xd:doc>
    <xsl:variable name="deadAttNames" as="xs:string+" 
        select="('bgcolor', 'cellpadding', 'cellspacing', 'border', 
        'width', 'height', 'align', 'valign', 'hspace', 'link', 'alink',
        'vlink', 'text')"/>
    
    <xd:doc>
        <xd:desc>The default template kicks everything off.</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>We have a lot of work to do in the head tag, if there are 
        obsolete style-like attributes from HTML4 and below.</xd:desc>
    </xd:doc>
    <xsl:template match="html[body/descendant::*/@*[local-name() = $deadAttNames]]/head">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <style>
                <xsl:for-each select="parent::html/body//*[@*[local-name() = $deadAttNames]]">
                    <xsl:sequence select="'&#x0a;.c_' || generate-id() || '{'"/>
          
                    <xsl:sequence select="'&#x0a;}'"/>
                </xsl:for-each>
            </style>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Attributes no longer needed.</xd:desc>
    </xd:doc>
    <xsl:template match="script/@language | script/@LANGUAGE | @*[local-name() = $deadAttNames]"/>
    
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
    
    <xd:doc>
        <xd:desc>Image tags must have an alt attribute.</xd:desc>
    </xd:doc>
    <xsl:template match="img[not(@alt)]">
        <xsl:comment>Please check the @alt attribute and ensure it is useful and accurate.</xsl:comment>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="alt" select="if (@title) then @title else if (@src) then @src else '[Alt attribute is required.]'"/>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>This is a temporary implementation of handling for the style element.
        We will need to enhance this to allow for CORS-friendly processing which would
        externalize the stylesheet.</xd:desc>
    </xd:doc>
    <xsl:template match="style">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:comment>
                <xsl:apply-templates select="node()"/>
            </xsl:comment>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Suppress any old comments aimed at IE.</xd:desc>
    </xd:doc>
    <xsl:template match="comment()[matches(., '\[if ') and matches(., ' IE ')]"/>
    
</xsl:stylesheet>