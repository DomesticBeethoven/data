<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:uuid="java:java.util.UUID"
    xmlns:ba="none"
    exclude-result-prefixes="xs math xd mei uuid ba"
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
    
    
    <!-- 
    TODO: 
    
    im header elemente einfügen
    
    add schema 
    <?xml-model href="../../schema/bith.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>
    
    mei:dir
    
    in header nötige ids behalten, anpassen
    
    tenuto?
    
    -->
    
    
    <xd:doc>
        <xd:desc>
            <xd:p>Record XSLT in revisionDesc</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:revisionDesc" mode="mode2">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
            <change xmlns="http://www.music-encoding.org/ns/mei" resp="#bithTeam_lr">
                <xsl:attribute name="n" select="xs:int(mei:change[1]/@n) + 1"/>
                <xsl:attribute name="isodate" select="substring(string(current-date()),1,10)"/>
                <changeDesc>
                    <p>Applied "musescore2mei.xsl"</p>
                    <p>Remove unwanted attributes and mistakes from MuseScore export; insert UUIDs</p>
                </changeDesc>
            </change>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Copy template</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Let run mode1 first and then mode2</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:variable name="after.mode1">
            <xsl:apply-templates select="node()" mode="mode1"/>
        </xsl:variable>
        <xsl:apply-templates select="$after.mode1" mode="mode2"/>
    </xsl:template>
    
    <!-- Remove unnecessary graphic/MIDI attributes from MuseScore -->
    <xd:doc>
        <xd:desc>
            <xd:p>Remove text and font attributes</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:pgHead | mei:rend | @fontstyle | @fontweight" mode="#all"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Remove MIDI attributes</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:instrDef | @ppq | @dur.ppq | @val | @vgrp | @midi.bpm" mode="#all"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Remove trailing zeros from @tStamp</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@tstamp" mode="#all">
        <xsl:attribute name="tstamp">
            <xsl:value-of select="number(.)"/>
        </xsl:attribute>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Normalize space on @label</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@label" mode="#all">
        <xsl:attribute name="label">
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:attribute>
    </xsl:template>
    
    <!-- Remove mistakes --> 
    <xd:doc>
        <xd:desc>
            <xd:p>Remove @wordpos with the value "s"</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@wordpos[.='s']" mode="#all"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Remove @accid.ges when @accid = @accid.ges</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:accid[@accid.ges = @accid]/@accid.ges" mode="#all"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Make sure ties have endpoint</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:tie[not(@endid) and not(@tstamp2)]" mode="#all">
        <xsl:copy select=".">
            <xsl:apply-templates select="node() | @*"/>
            <xsl:attribute name="tstamp2">1m+1</xsl:attribute>
        </xsl:copy>
    </xsl:template>
  
    <!-- Add IDs -->
    <xd:doc>
        <xd:desc>
            <xd:p>Add UUIDs for every music element and the document</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:mei | mei:music//*" mode="mode1">
        <xsl:copy>
            <xsl:attribute name="new.id" select="'m' || uuid:randomUUID()"/>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Replace old ID with new ID</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@new.id" mode="mode2">
        <xsl:attribute name="xml:id" select="."/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Match old IDs</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:mei//@xml:id" mode="mode2"/>

    <xd:doc>
        <xd:desc>
            <xd:p>Replace startid with new ID</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@startid" mode="mode2">
        <xsl:variable name="id" select="replace(.,'#','')" as="xs:string"/>
        <xsl:variable name="elem" select="ancestor::mei:music//element()[@xml:id = $id]" as="node()?"/>
        <xsl:if test="exists($elem)">
            <xsl:attribute name="startid" select="'#' || $elem/@new.id"/>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Replace endid with new ID</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@endid" mode="mode2">
        <xsl:variable name="id" select="replace(.,'#','')" as="xs:string"/>
        <xsl:variable name="elem" select="ancestor::mei:music//element()[@xml:id = $id]" as="node()?"/>
        <xsl:if test="exists($elem)">
            <xsl:attribute name="endid" select="'#' || $elem/@new.id"/>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>