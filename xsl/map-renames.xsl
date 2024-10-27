<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="#all"
    xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns:hcmc="http://hcmc.uvic.ca/ns"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    expand-text="yes"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Oct 25, 2024</xd:p>
            <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
            <xd:p>This stylesheet reads a pre-generated file listing for 
            the entire source file tree and constructs a map of old locations
            to new locations in the output folder; the idea is to remediate
            stupid and dangerous file and folder names before we do anything
            else.</xd:p>
            <xd:p>This file runs on itself and outputs one product in the 
                form of an XML map, and another in the form of a bash script
                that will copy the files over to the new locations with their
                new names.</xd:p>
        </xd:desc>
        <xd:param name="sourceListing" as="xs:string">The text file 
        containing the output from ls -al on the source folder.</xd:param>
        <xd:param name="outputFolder" as="xs:string">The folder where the renamed files
            and folders will be stored.</xd:param>
        <xd:param name="outputScript" as="xs:string">Where to output the bash 
        script that will copy the content over.</xd:param>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>Main output should be text.</xd:desc>
    </xd:doc>
    <xsl:output method="text" encoding="UTF-8"
        normalization-form="NFC"/>

    <xd:doc>
        <xd:desc>Include the function lib to convert the problem paths.</xd:desc>
    </xd:doc>
    <xsl:include href="module_functions.xsl"/>
    
    <xd:doc>
        <xd:desc>The folder from which things will be copied/renamed.</xd:desc>
    </xd:doc>
    <xsl:param name="sourceFolder" as="xs:string" select="'../tests/source'"/>
    
    <xd:doc>
        <xd:desc>The text file 
            containing the output from ls -al on the source folder.</xd:desc>
    </xd:doc>
    <xsl:param name="sourceListing" as="xs:string" select="'../temp/sourceFiles.txt'"/>

    <xd:doc>
        <xd:desc>The folder where the renamed files
        and folders will be stored.</xd:desc>
    </xd:doc>
    <xsl:param name="outputFolder" as="xs:string" select="'../tests/output'"/>

    <xd:doc>
        <xd:desc>Where to output the bash 
            script that will copy the content over.</xd:desc>
    </xd:doc>
    <xsl:param name="outputScript" as="xs:string" select="'../temp/copyRename.sh'"/>
    
    <xd:doc>
        <xd:desc>The individual filenames with full paths from the listing.</xd:desc>
    </xd:doc>
    <xsl:variable name="files" as="xs:string*" select="tokenize(replace(unparsed-text($sourceListing), '(^\s+)|(\s+$)', ''), '\s*&#x0a;\s*')"/>
    

    <xd:doc>
        <xd:desc>The root template does all the work.</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:message select="'Mapping ' || count($files) || ' files to their new names/locations.'"/>
        <xsl:message select="'Source folder is ' || $sourceFolder || '; output folder is ' || $outputFolder || '.'"/>
        
        <!-- First build an in-memory map. -->
        <xsl:variable name="mapRenames" as="map(xs:string, xs:string)">
            <xsl:map>
                <xsl:for-each select="$files">
                    <xsl:variable name="unfixedOutput" as="xs:string" select="$outputFolder || substring-after(., $sourceFolder)"/>
                    <xsl:map-entry key="." select="hcmc:fix-bad-filename($unfixedOutput)"/>
                </xsl:for-each>
            </xsl:map>
        </xsl:variable>
        
        <!-- Now output the map into custom simple XML. -->
        <xsl:result-document href="{replace($outputScript, '\.sh$', '.xml')}" method="xml" encoding="UTF-8" exclude-result-prefixes="#all" normalization-form="NFC" indent="yes">
            <renames xmlns="http://hcmc.uvic.ca/ns">
                <xsl:for-each select="map:keys($mapRenames)">
                    <rename from="{.}" to="{map:get($mapRenames, .)}"/>
                </xsl:for-each>
            </renames>
        </xsl:result-document>
        
        <!-- Finally write the script to move the files. -->
        
        <xsl:result-document href="{$outputScript}">
            <xsl:sequence select="'#!/bin/bash&#x0a;&#x0a;'"/>
            <xsl:for-each select="map:keys($mapRenames)">
                <xsl:sequence select="'cp &quot;' || . || '&quot; &quot;' || map:get($mapRenames, .) || '&quot;&#x0a;'"/>
            </xsl:for-each>
        </xsl:result-document>
        
    </xsl:template>
    
</xsl:stylesheet>