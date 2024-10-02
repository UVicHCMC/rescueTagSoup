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
            <xsl:variable name="css" as="xs:string+">
                <xsl:sequence select="'&#x0a;.centered{&#x0a;text-align: center;&#x0a;margin-left: auto;&#x0a;margin-right: auto;&#x0a;}'"/>
                <xsl:for-each select="parent::html/body//descendant-or-self::*[@*[local-name() = $deadAttNames]]">
                    <xsl:sequence select="'&#x0a;' || local-name() || '.c_' || generate-id() || '{'"/>
                    <xsl:apply-templates select="@*[local-name() = $deadAttNamesCurrent]" mode="css"/>
                    <xsl:apply-templates select="@*[local-name() = $deadAttNamesDesc]" mode="css"/>
                    <xsl:sequence select="'&#x0a;}'"/>
                </xsl:for-each>
            </xsl:variable>
            
            <style>
                <xsl:comment>
                    <xsl:value-of disable-output-escaping="yes" select="$css"/>
                </xsl:comment>
            </style>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Attributes no longer needed.</xd:desc>
    </xd:doc>
    <xsl:template match="script/@language | script/@LANGUAGE | script/@type | a/descendant::*/@tabindex"/>
    
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
                    <xsl:apply-templates select="@*[not(local-name() = 'class')]"/>
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
        <xd:desc>Fix the duplicate-id problem.</xd:desc>
    </xd:doc>
    <xsl:template match="@id[. = preceding::*/@id]"/>
    
    <xd:doc>
        <xd:desc>There seems to be a problem with xml: prefixed attributes.</xd:desc>
    </xd:doc>
    <xsl:template match="@xmlU00003Alang">
        <xsl:attribute name="xml:lang" select="."/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Suppress any content-language meta tag; this info should be on 
            the root html element. Also suppress obsolete IE-related meta-tag.</xd:desc>
    </xd:doc>
    <xsl:template match="meta[@http-equiv=('content-language', 'X-UA-Compatible')]"/>
    
    <xd:doc>
        <xd:desc>NOTE: THIS FAILS BECAUSE SAXON INSERTS IT AGAIN. Think about alternatives.
            Let's default to the meta/@charset instead of the old http-equiv thing.</xd:desc>
    </xd:doc>
    <xsl:template match="meta[not(@charset) and contains(@content, 'charset')]">
        <meta charset="{substring-after(@content, '=')}"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Suppress language specification using a meta tag.</xd:desc>
    </xd:doc>
    <xsl:template match="html[not(@lang) and descendant::meta[@http-equiv='content-language']]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="lang" select="descendant::meta[@http-equiv='content-language'][1]/@content"/>
            <xsl:apply-templates select="node()"/>
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
    
    <!-- ############ TEMPLATES IN css MODE DEALING WITH OBSOLETE ATTRIBUTES. ############ -->
    
    <xd:doc>
        <xd:desc>Default low-priority do-nothing to suppress stuff.</xd:desc>
    </xd:doc>
    <xsl:template match="@*[local-name() = $deadAttNames][not(parent::img and local-name() = ('width', 'height'))]" mode="#all" priority="-1"/>
    
    <xd:doc>
        <xd:desc>The border attribute just had 1 or 0 for on or off.</xd:desc>
    </xd:doc>
    <xsl:template match="@border" mode="css">
        <xsl:choose>
            <xsl:when test=". = '1'">
                <xsl:sequence select="'&#x0a; border: solid 1px black;'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="'&#x0a; border-style: none;'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>The width and height attributes are converted UNLESS they're on the 
            img element.</xd:desc>
    </xd:doc>
    <xsl:template match="@width[not(parent::img)] | height[not(parent::img)]" mode="css">
        <xsl:sequence select="'&#x0a; ' || local-name() || ': ' || . || ';'"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>The bgcolor attribute converts into straightforward CSS.</xd:desc>
    </xd:doc>
    <xsl:template match="@bgcolor" mode="css">
        <xsl:sequence select="'&#x0a; background-color: ' || . || ';'"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>The valign should (I think) convert into straightforward CSS.</xd:desc>
    </xd:doc>
    <xsl:template match="@valign" mode="css">
        <xsl:sequence select="'&#x0a; vertical-align: ' || lower-case(.) || ';'"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>The align attribute is closest to text-align when it's
            not on an img.</xd:desc>
    </xd:doc>
    <xsl:template match="@align[not(parent::img)]" mode="css">
        <xsl:variable name="val" as="xs:string" select="lower-case(.)"/>
        <xsl:choose>
            <xsl:when test="$val = ('left', 'center', 'right', 'justify')">
                <xsl:sequence select="'&#x0a; text-align: ' || $val || ';'"/>
            </xsl:when>
            <xsl:when test="$val = 'middle'">
                <xsl:sequence select="'&#x0a; vertical-align: ' || $val || ';'"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>The align attribute is goes in all dimensions when it's
            on an img.</xd:desc>
    </xd:doc>
    <xsl:template match="img/@align" mode="css">
        <xsl:variable name="val" as="xs:string" select="lower-case(.)"/>
        <xsl:choose>
            <xsl:when test="$val = 'top'">
                <xsl:sequence select="'&#x0a; vertical-align: top;'"/>
            </xsl:when>
            <xsl:when test="$val = 'middle'">
                <xsl:sequence select="'&#x0a; vertical-align: middle;'"/>
            </xsl:when>
            <xsl:when test="$val = 'left'">
                <xsl:sequence select="'&#x0a; float: left;'"/>
            </xsl:when>
            <xsl:when test="$val = 'right'">
                <xsl:sequence select="'&#x0a; float: right;'"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>The FONT/@SIZE attribute needs coercion into modern
        font sizes.</xd:desc>
    </xd:doc>
    <xsl:template match="font/@size" mode="css">
        <xsl:choose>
            <xsl:when test=". = '1'">
                <xsl:sequence select="'&#x0a; font-size: xx-small;'"/>
            </xsl:when>
            <xsl:when test=". = '2'">
                <xsl:sequence select="'&#x0a; font-size: x-small;'"/>
            </xsl:when>
            <xsl:when test=". = '3'">
                <xsl:sequence select="'&#x0a; font-size: small;'"/>
            </xsl:when>
            <xsl:when test=". = '4'">
                <xsl:sequence select="'&#x0a; font-size: medium;'"/>
            </xsl:when>
            <xsl:when test=". = '5'">
                <xsl:sequence select="'&#x0a; font-size: large;'"/>
            </xsl:when>
            <xsl:when test=". = '6'">
                <xsl:sequence select="'&#x0a; font-size: x-large;'"/>
            </xsl:when>
            <xsl:when test=". = '7'">
                <xsl:sequence select="'&#x0a; font-size: xx-large;'"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>The FONT/@FACE attribute should convert directly.</xd:desc>
    </xd:doc>
    <xsl:template match="font/@face" mode="css">
        <xsl:sequence select="'&#x0a;font-family: ' || . || ';'"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Table cellpadding is realized on descendant td elements.</xd:desc>
    </xd:doc>
    <xsl:template match="table/@cellpadding" mode="css">
        <xsl:sequence select="'&#x0a;&amp;tr&amp;td{' || 'padding: ' || . || 'px;}'"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Table cellspacing is realized on descendant td elements.</xd:desc>
    </xd:doc>
    <xsl:template match="table/@cellspacing" mode="css">
        <xsl:sequence select="'&#x0a;&amp;tr&amp;td{' || 'margin: ' || . || 'px;}'"/>
    </xsl:template>
    
</xsl:stylesheet>