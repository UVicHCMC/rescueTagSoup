<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="#all"
    xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns:hcmc="http://hcmc.uvic.ca/ns"
    expand-text="yes"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Oct 8, 2024</xd:p>
            <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
            <xd:p>This module contains discrete functions used in different
            contexts in the processing chain.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc><xd:ref name="hcmc:fix-bad-filename"/> provides a remedy for the 
        common scenario in which a page or resource on the original site is actually constructed
        from a query string. The resulting filename looks like:
        
        index.htmlshare=facebook.html
        
        or 
        
        index.html?share=facebook.html
        
        of
        
        <![CDATA[
        koster_-009_ed6.jpg?w=362&h=362&crop=1&ssl=1
        ]]>
        
        Filenames like this need to be massaged into something which 
        retains the key data (and therefore the uniqueness of the identifier)
        but is not a mess of inadvisable characters.
        
        </xd:desc>
        <xd:param name="fileName" as="xs:string">The incoming filename.</xd:param>
    </xd:doc>
    <xsl:function name="hcmc:fix-bad-filename" as="xs:string">
        <xsl:param name="fileName" as="xs:string"/>
        <!-- The first phase removes any embedded file extension, since there's
             a final extension anyway. -->
        <xsl:variable name="noNestedExtension" as="xs:string" select="
            if (matches($fileName, '\.html.{2,}', 'i')) then replace($fileName, '\.html(.+)', '$1', 'i')
            else if (matches($fileName, '\.htm.{2,}', 'i')) then replace($fileName, '\.htm(.+)', '$1', 'i') 
            else $fileName"/>
        
        <!-- We need a mapping of unwanted characters to decent replacements. -->
        
        
        
        <!-- Placeholder. -->
        <xsl:sequence select="$noNestedExtension"/>
    </xsl:function>
    
</xsl:stylesheet>