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
    <xsl:output method="xhtml" html-version="5" encoding="UTF-8"
        normalization-form="NFC" exclude-result-prefixes="#all" omit-xml-declaration="yes"/>
    
    <xd:doc>
        <xd:desc>Default mode is an identity transform.</xd:desc>
    </xd:doc>
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xd:doc>
        <xd:desc>Special css mode does not cascade.</xd:desc>
    </xd:doc>
    <xsl:mode name="css" on-no-match="deep-skip"/>
    
    <xd:doc>
        <xd:desc>We need a sequence of obsolete attribute names so that we can 
        intervene for elements that carry them and construct CSS classes. These
        are the attributes which define properties for their parent elements.</xd:desc>
    </xd:doc>
    <xsl:variable name="deadAttNamesCurrent" as="xs:string+" 
        select="('bgcolor', 'border', 
        'width', 'height', 'align', 'valign', 'hspace', 'link', 'alink',
        'vlink', 'text', 'face', 'size')"/>
    
    <xd:doc>
        <xd:desc>These are the attributes which define properties for 
            some of their descendant elements.</xd:desc>
    </xd:doc>
    <xsl:variable name="deadAttNamesDesc" as="xs:string+" 
        select="('cellpadding', 'cellspacing', 'alink',
        'vlink', 'text')"/>
    
    <xd:doc>
        <xd:desc>For @match, it's useful to have a union of these.</xd:desc>
    </xd:doc>
    <xsl:variable name="deadAttNames" as="xs:string+" select="($deadAttNamesCurrent, $deadAttNamesDesc)"/>
    
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
    <xsl:template match="html[body/descendant-or-self::*/@*[local-name() = $deadAttNames] or descendant::center]/head">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <style>
                <xsl:sequence select="'&#x0a;.centered{&#x0a;text-align: center;&#x0a;margin-left: auto;&#x0a;margin-right: auto;&#x0a;}'"/>
                <xsl:for-each select="parent::html/body//descendant-or-self::*[@*[local-name() = $deadAttNames]]">
                    <xsl:sequence select="'&#x0a;.c_' || generate-id() || '{'"/>
                        <xsl:apply-templates select="@*[local-name() = $deadAttNamesCurrent]" mode="css"/>
                        <xsl:apply-templates select="@*[local-name() = $deadAttNamesDesc]" mode="css"/>
                    <xsl:sequence select="'&#x0a;}'"/>
                </xsl:for-each>
            </style>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Attributes no longer needed.</xd:desc>
    </xd:doc>
    <xsl:template match="script/@language | script/@LANGUAGE | script/@type | @*[local-name() = $deadAttNames] | a/descendant::*/@tabindex"/>
    
    <xd:doc>
        <xd:desc>When we meet an element that carries obsolete attributes, we
        need to give it a class. TODO: This is a temporary hack, since these elements
        may need other specific processing as well.</xd:desc>
    </xd:doc>
    <xsl:template match="body/descendant-or-self::*[@*[local-name() = $deadAttNames]]">
        <xsl:choose>
            <xsl:when test="self::font or self::FONT">
                <span class="{string-join((generate-id(), @class), ' ')}">
                    <xsl:apply-templates select="@*|node()"/>
                </span>
            </xsl:when>
            <xsl:when test="self::img">
                <xsl:comment>Please supply good @alt attribute.</xsl:comment>
                <xsl:copy>
                    <xsl:apply-templates select="@*[not(local-name() eq 'class')]"/>
                    <xsl:attribute name="class" select="string-join(('c_' || generate-id(), @class), ' ')"/>
                    <xsl:attribute name="alt" select="if (@title) then @title else if (@src) then @src else '[Alt attribute is required.]'"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*[not(local-name() eq 'class')]"/>
                    <xsl:attribute name="class" select="string-join(('c_' || generate-id(), @class), ' ')"/>
                    <xsl:apply-templates select="node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
        
    <xd:doc>
        <xd:desc>We need to catch img tags without @alt which don't have other weird attributes.</xd:desc>
    </xd:doc>
    <xsl:template match="img[not(@*[local-name() = $deadAttNames]) and not(@alt)]">
        <xsl:comment>Please supply good @alt attribute.</xsl:comment>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="alt" select="if (@title) then @title else if (@src) then @src else '[Alt attribute is required.]'"/>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>This is a bit of a hack -- we don't know if a div element
        will be valid in this context.</xd:desc>
    </xd:doc>
    <xsl:template match="center">
        <div class="centered">
            <xsl:apply-templates select="node()"/>
        </div>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>The script element is special: we need it to be output as CDATA,
        but the CDATA wrapper itself needs to be commented out in JS, then the 
        JS code itself needs to be commented out for XML purposes.</xd:desc>
    </xd:doc>
    <xsl:template match="script[not(@src) and not(contains(., '[CDATA['))]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:text disable-output-escaping="yes">//&lt;![CDATA[</xsl:text>
            <xsl:comment>
                <xsl:sequence select="."/>
            </xsl:comment>   
            <xsl:text disable-output-escaping="yes">//]]&gt;</xsl:text>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>When the script element already has appropriate CDATA 
        handling, we just need to output it appropriately.</xd:desc>
    </xd:doc>
    <xsl:template match="script[not(@src) and contains(., '[CDATA[')]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:value-of select="." disable-output-escaping="yes"/>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Attributes whose values should become lower-case.</xd:desc>
    </xd:doc>
    <xsl:template match="input/@TYPE | input/@type">
        <xsl:attribute name="{lower-case(local-name())}" select="lower-case(.)"/>
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
    
    <!-- ############ TEMPLATES IN css MODE DEALING WITH OBSOLETE ATTRIBUTES. ############ -->
    
    <xd:doc>
        <xd:desc>Default low-priority do-nothing to suppress stuff.</xd:desc>
    </xd:doc>
    <xsl:template match="@*[local-name() = $deadAttNames]" mode="#all" priority="-1"/>
    
    <xd:doc>
        <xd:desc>The border attribute just had 1 or 0 for on or off.</xd:desc>
    </xd:doc>
    <xsl:template match="@border" mode="css">
        <xsl:if test=". = '1'">
            <xsl:sequence select="'&#x0a; border: solid 1px black'"/>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>