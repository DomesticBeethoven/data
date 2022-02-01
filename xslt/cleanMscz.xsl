<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:ba="none"
    exclude-result-prefixes="xs math xd mei ba"
    version="4.0">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 18, 2021</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> Lisa</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Record XSLT in revisionDesc</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:revisionDesc">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
            <change xmlns="http://www.music-encoding.org/ns/mei" resp="#bithTeam_lr">
                <xsl:attribute name="n" select="count(child::mei:change) + 1" as="xs:integer"/>
                <xsl:attribute name="isodate" select="substring(string(current-date()),1,10)"/>
                <changeDesc>
                    <p>Applied "cleanMscz.xsl"</p>
                    <p>Remove unwanted attributes and mistakes from MuseScore export; add schema</p>
                </changeDesc>
            </change>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Copy template</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Add schematron</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:processing-instruction name="xml-model">
            href="../../../schema/bith.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"
        </xsl:processing-instruction>
        <xsl:apply-templates/>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Remove text and font attributes</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:pgHead | @fontstyle | @fontweight"/>
    
    <xd:doc>
        <xd:desc>Delete rend, but keep content for dir</xd:desc>
    </xd:doc>
    <xsl:template match="mei:rend">
        <xsl:apply-templates select="node()"/>        
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Create artic attributes for notes and chords</xd:desc>
    </xd:doc>    
    <xsl:template match="mei:chord | mei:note">
        <xsl:copy>
            <xsl:if test=".//@artic">
                <xsl:attribute name="artic" select=".//@artic"/>
            </xsl:if>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Remove articulation elements and labelAbbr</xd:desc>
    </xd:doc>
    <xsl:template match="mei:artic | mei:labelAbbr"/>
   
    <xd:doc>
        <xd:desc>
            <xd:p>Remove MIDI attributes</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:instrDef | @ppq | @dur.ppq | @val | @vgrp | @midi.bpm"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Remove trailing zeros from @tStamp</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@tstamp">
        <xsl:attribute name="tstamp">
            <xsl:value-of select="number(.)"/>
        </xsl:attribute>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Normalize space on @label</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@label">
        <xsl:attribute name="label">
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:attribute>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Remove @wordpos with the value "s"</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@wordpos[.='s']"/>

    <xd:doc>
        <xd:desc>
            <xd:p>Remove @accid.ges when @accid = @accid.ges</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:accid[@accid.ges = @accid]/@accid.ges"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Make sure ties have endpoint</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:tie[not(@endid) and not(@tstamp2)]">
        <xsl:copy select=".">
            <xsl:apply-templates select="node() | @*"/>
            <xsl:attribute name="tstamp2">1m+1</xsl:attribute>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>