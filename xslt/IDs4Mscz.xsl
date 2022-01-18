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
                <xd:b>Created on:</xd:b> Jan 18, 2022</xd:p>
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
    <xsl:template match="mei:revisionDesc" mode="mode2">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
            <change xmlns="http://www.music-encoding.org/ns/mei" resp="#bithTeam_lr">
                <xsl:attribute name="n" select="count(child::mei:change) + 1" as="xs:integer"/>
                <xsl:attribute name="isodate" select="substring(string(current-date()),1,10)"/>
                <changeDesc>
                    <p>Applied "IDs4Mscz.xsl"</p>
                    <p>Delete IDs from Musescore; insert UUID(s) for the document, encoding description and music elements</p>
                </changeDesc>
            </change>
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
            <xd:p>Add UUIDs for every music element, the encoding description and the document</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:mei | mei:music//* | mei:encodingDesc//*" mode="mode1">
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
            <xd:p>Match old IDs for music- and encodingDesc-elements</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:music//@xml:id | mei:encodingDesc//@xml:id" mode="mode2"/>
    
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