<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:uuid="java:java.util.UUID"
    xmlns:ba="none"

    version="3.0">

    
    <xsl:template match="/">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    <!-- this template finds elements with out the @xml:id attribute
            It then copies in an attribute named "xml:id" and 
            provides a random UUID -->
    
    <xsl:template match="//mei:*[not(@xml:id)]" >
        
        <xsl:copy>
            <xsl:attribute name="new.id" select="'b' || uuid:randomUUID()"/>
            <xsl:apply-templates select="node() | @*" />

        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@dur.ppq"/>
    
    <!-- This is a basic template that copies all the other content into the new document 
         It does this by matching every node, and applying the "default" template.
         The default template is the template that is automatically applied to any selected node
         if nothing else is specified. -->
    
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>