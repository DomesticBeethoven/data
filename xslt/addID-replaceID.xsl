<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:uuid="java:java.util.UUID"
    xmlns:ba="none"
    exclude-result-prefixes="xs math xd mei uuid ba"
    version="3.0">
    <xsl:output method="xml"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Oct 10, 2014</xd:p>
            <xd:p><xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p><xd:b>Editor:</xd:b> Mark Saccomano</xd:p>
            <xd:p><xd:b>Edited on:</xd:b>April 9, 2021</xd:p>
        </xd:desc>
    </xd:doc>

<!-- updated to extend to meiHead 2021-04-16 -->
    
    <!-- Important TODO: insert a change description when this is run.  --> 
    
<!-- Checks each element for @xml:id
     Provides uuid if missing.
     Replaces existing xml:id with uuid.

     Provides the new xml:id in any @startid and @endid (mode2)
-->

<xsl:template match="/">
    <xsl:variable name="after.mode1">
        <xsl:apply-templates select="node()" mode="mode1"/>
    </xsl:variable>
    <xsl:apply-templates select="$after.mode1" mode="mode2"/>
</xsl:template>
        
    <xd:doc>
        <xd:desc>Insert Change Description</xd:desc>
    </xd:doc>
    <xsl:template match="mei:revisionDesc" mode="mode1">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <change xmlns="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="n" select="max(mei:change/xs:int(@n)) + 1"/>
                <changeDesc xmlns="http://www.music-encoding.org/ns/mei">
                    <p xmlns="http://www.music-encoding.org/ns/mei">Provide UUID for all elements. Replace old xml:id, update tie/slur IDs. addID-replaceID.xsl</p>
                    <xsl:text>&#xa;</xsl:text>
                <date isodate="{substring(string(current-date()),1,10)}"/>
                </changeDesc>
            </change>
        </xsl:copy>
    </xsl:template>
    
    <!-- First: Give every element a new UUID @new.id -->
    
<xsl:template match="mei:*" mode="mode1">
    <xsl:copy>
        <xsl:attribute name="new.id" select="'m' || uuid:randomUUID()"/>
        <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
</xsl:template>

<!-- MODE 2 -->
<!-- replace the old @xml:id with @new.id -->
    
<xsl:template match="@new.id" mode="mode2">
    <xsl:attribute name="xml:id" select="."/>
</xsl:template>

<!-- match each OLD @xml:id  -->
<xsl:template match="mei:mei//@xml:id" mode="mode2"/>


<!-- replace any @startid and @endid with new @xml:id number-->
<xsl:template match="@startid" mode="mode2">
    <xsl:variable name="id" select="replace(.,'#','')" as="xs:string"/>
    <xsl:variable name="elem" select="ancestor::mei:music//element()[@xml:id = $id]" as="node()?"/>
    <xsl:if test="exists($elem)">
        <xsl:attribute name="startid" select="'#' || $elem/@new.id"/>
    </xsl:if>
</xsl:template>

<xsl:template match="@endid" mode="mode2">
    <xsl:variable name="id" select="replace(.,'#','')" as="xs:string"/>
    <xsl:variable name="elem" select="ancestor::mei:music//element()[@xml:id = $id]" as="node()?"/>
    <xsl:if test="exists($elem)">
        <xsl:attribute name="endid" select="'#' || $elem/@new.id"/>
    </xsl:if>
</xsl:template>

<!-- replace all @facs with new zone @xml:id number-->
<xsl:template match="@facs" mode="mode2">
    <xsl:variable name="id" select="replace(.,'#','')" as="xs:string"/>
    <xsl:variable name="elem" select="ancestor::mei:music//element()[@xml:id = $id]" as="node()?"/>
    <xsl:if test="exists($elem)">
        <xsl:attribute name="facs" select="'#' || $elem/@new.id"/>
    </xsl:if>
</xsl:template>

<!-- replace @resp IDs -->
<xsl:template match="@resp" mode="mode2">
    <xsl:variable name="id" select="replace(.,'#','')" as="xs:string"/>
    <xsl:variable name="elem" select="ancestor::mei:music//element()[@xml:id = $id]" as="node()?"/>
    <xsl:if test="exists($elem)">
        <xsl:attribute name="resp" select="'#' || $elem/@new.id"/>
    </xsl:if>
</xsl:template>

<xd:doc>
    <xd:desc>
        <xd:p>generic copy template</xd:p>
    </xd:desc>
</xd:doc>


<xsl:template match="node() | @*" mode="#all">
    <xsl:copy>
        <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
</xsl:template>
    
<!--
   <xd:doc>
    <xd:desc>
        <xd:p>This ensures that all relevant elements have xml:ids</xd:p>
    </xd:desc>
 </xd:doc>

<xsl:template match="mei:body//mei:*[not(@xml:id)]"  >
    <xsl:copy>
        <xsl:attribute name="xml:id" select="'x' || uuid:randomUUID()"/>
        <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
</xsl:template>
-->

</xsl:stylesheet>
