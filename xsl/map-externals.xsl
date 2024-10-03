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
            <xd:p><xd:b>Created on:</xd:b> Oct 3, 2024</xd:p>
            <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
            <xd:p>This stylesheet parses through all the now-XHTML temporary
                files and compiles a lookup table of all the resources 
                which have been externally referenced (CSS, JS, images
                and so on) using full http requests in the HTML and CSS.
                The lookup is in the form of an XHTML file which can
                be used in a process to replace external links with local
                links. The process also compiles a command-line script which
                will retrieve all of these files and place them in a 
                folder called "externals" in the output folder.</xd:p>
            <xd:p>This file runs on itself and outputs two products.</xd:p>
        </xd:desc>
        <xd:param name="sourceFolder" as="xs:string">The folder containing the original source documents, which is where we look for CSS files.</xd:param>
        <xd:param name="xhtmlFolder" as="xs:string">The temporary folder where the parsable XHTML files are found.</xd:param>
        <xd:param name="outputFolder" as="xs:string">The folder where the two generated resources
            will be stored.</xd:param>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>Main output should be HTML5 in the XHTML namespace.</xd:desc>
    </xd:doc>
    <xsl:output method="xhtml" html-version="5" encoding="UTF-8"
        normalization-form="NFC" exclude-result-prefixes="#all" omit-xml-declaration="yes"/>


    <xd:doc>
        <xd:desc>The source folder where the original site resources are found; 
            we look in here for CSS files.</xd:desc>
    </xd:doc>
    <xsl:param name="sourceFolder" as="xs:string" select="'../temp'"/>

    <xd:doc>
        <xd:desc>The temporary folder where the parsable XHTML files are found.</xd:desc>
    </xd:doc>
    <xsl:param name="xhtmlFolder" as="xs:string" select="'../temp'"/>
    

    <xd:doc>
        <xd:desc>The collection of HTML files to be parsed.</xd:desc>
    </xd:doc>
    <xsl:variable name="htmlToParse" as="document-node()*" select="collection($xhtmlFolder || '/?select=*.(htm|html|HTM|HTML);recurse=yes')"/>
    
    <xd:doc>
        <xd:desc>The collection of CSS files to be parsed.</xd:desc>
    </xd:doc>
    <xsl:variable name="cssToParse" as="xs:string*" select="uri-collection($sourceFolder || '/?select=*.(css|CSS);recurse=yes')!unparsed-text(.)"/>
    
    <xd:doc>
        <xd:desc>The output folder where the resources need to be stored.</xd:desc>
    </xd:doc>
    <xsl:param name="outputFolder" as="xs:string" select="'../temp/externals'"/>
    
    <xd:doc>
        <xd:desc>The root template does all the work.</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:message select="'Parsing through ' || $xhtmlFolder || ' to find externals.'"/>
        <!-- Note: img/@data-orig-file seems to be a WordPress-specific way to encode
             the base image where various sizes are being proffered. -->
        <xsl:variable name="externals" as="xs:string*" select="distinct-values(($htmlToParse//(link[@type='text/css']/@href, script/@src, img/@src, img/@data-orig-file)[starts-with(., 'http')]))"/>
        
        <xsl:message select="'Found ' || count($externals) || ' externals directly in HTML.'"/>
        <!--<xsl:message select="string-join($externals, '&#x0a;')"/>-->
        
        <!-- Create the output file we can turn into a lookup for changing links. -->
        <xsl:result-document href="{$outputFolder}/listing.html">
            <html>
                <head>
                    
                    <title>Listing of external files in the site</title>
                    
                </head>
                
                <body>
                    
                    <h1>Listing of external files in the site</h1>
                    
                    <table>
                        <thead>
                            <tr>
                                <td>Source URL</td>
                                <td>Local path</td>
                            </tr>
                        </thead>
                        <tbody>
                            <xsl:for-each select="$externals">
                                <tr>
                                    <td><xsl:sequence select="."/></td>
                                    <td><xsl:sequence select="$outputFolder || '/' || substring-after(., '://')"/></td>
                                </tr>
                            </xsl:for-each>
                        </tbody>
                    </table>
                    
                </body>
            </html>
        </xsl:result-document>
        
        <!-- Now we output a script which will download the documents. -->
        <xsl:result-document method="text" encoding="UTF8" href="{$outputFolder}/get-externals.sh">
            <xsl:sequence select="'#!/bin/bash&#x0a;&#x0a;'"/>
            <xsl:for-each select="$externals">
                <xsl:sequence select="'wget ' || . || ' ' || $outputFolder || '/' || substring-after(., '://') || '&#x0a;&#x0a;'"/>
            </xsl:for-each>
        </xsl:result-document>
        
        
    </xsl:template>
    
</xsl:stylesheet>