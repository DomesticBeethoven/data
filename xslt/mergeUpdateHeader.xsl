<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    exclude-result-prefixes="xs math xd mei"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jun 14, 2018</xd:p>
            <xd:p><xd:b>Edited on:</xd:b> Feb 2021</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p>This XSLT merges two MEI encodings (one with measure positions,
                the other one with music) into one file.
                Applies to the music file
                
            ----> "XML Source" is MEI music file
            
                    xml and xsl must be in same folder
            
            enter:  measure(zones).file.name
                    music.file.name             

                      -->    
<!-- Important TODO: insert a change description when this is run.  --> 
                
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:param name="measure.file.name" select="'TrioVcMeasuresEd.xml'" as="xs:string"/>
    <xsl:param name="music.file.name" select="'TrioMetadataOnly.xml'" as="xs:string"/>
    
    <xsl:variable name="music.file" select="/mei:mei" as="node()"/>
    <xsl:variable name="music.file.path" select="document-uri(/)" as="xs:string"/>
    <xsl:variable name="music.file.path.tokens" select="tokenize($music.file.path,'/')" as="xs:string*"/>

    <xsl:variable name="measure.file.path" select="string-join($music.file.path.tokens[position() lt count($music.file.path.tokens)],'/')" as="xs:string"/>
    <xsl:variable name="measure.file.path.complete" select="$measure.file.path || '/' || $measure.file.name" as="xs:string"/>
    <xsl:variable name="measure.file" select="doc($measure.file.path.complete)" as="node()"/>
    <xsl:variable name="mdiv.n" select="$music.file//mei:mdiv/@n" as="xs:string"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="$measure.file/processing-instruction()"/>
        <xsl:apply-templates select="$measure.file/mei:mei"/>
    </xsl:template>

<xsl:template match="mei:meiHead">
    <xsl:copy>
        <xsl:apply-templates select="$music.file//mei:meiHead/@* | $music.file//mei:meiHead/node()"/>
    </xsl:copy>
</xsl:template>
    
    <xsl:template match="mei:appInfo">
        <!-- assumes to run on the music file -->
        
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
            
            <xsl:variable name="measure.apps" select="$measure.file//mei:application" as="element()*"/>
            <xsl:variable name="music.apps" select="$music.file//mei:application" as="element()*"/>
            <xsl:for-each select="$measure.apps">
                <xsl:variable name="current.app" select="." as="element()"/>
                <xsl:if test="not($current.app/@label = $music.apps/@label)">
                    <xsl:copy-of select="$current.app"/>
                </xsl:if>
            </xsl:for-each>
            
            <!-- maybe put this elsewhere??? -->
            <!-- Needs changeDesc -->
<!--            <change xmlns="http://www.music-encoding.org/ns/mei">
                <date isodate="{substring(string(current-date()),1,10)}"/>
            </change>
            -->
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:measure">
        <xsl:choose>
            <xsl:when test="ancestor::mei:mdiv[@n ne $mdiv.n]">
                <xsl:next-match/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="measure.label" select="@label" as="xs:string"/>
                <xsl:variable name="corresponding.music.measure" select="$music.file//mei:mdiv[1]//mei:measure[@n = $measure.label]" as="node()?"/>
                
                <xsl:choose>
                    <xsl:when test="exists($corresponding.music.measure)">
                        <xsl:copy>
                            <xsl:apply-templates select="@facs"/>
                            <xsl:apply-templates select="@label"/>
                            <xsl:apply-templates select="@type"/>
                            <xsl:apply-templates select="$corresponding.music.measure/node() | $corresponding.music.measure/@*"/>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:next-match/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
<xsl:template match="mei:scoreDef">
    <xsl:choose>
        <xsl:when test="ancestor::mei:mdiv[@n ne $mdiv.n]">
            <xsl:next-match/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="corresponding.scoreDef" select="($music.file//mei:mdiv[1]//mei:scoreDef)[1]" as="node()?"/>
            <xsl:choose>
                <xsl:when test="exists($corresponding.scoreDef)">
                    <xsl:copy>
                        <xsl:apply-templates select="$corresponding.scoreDef/node() | $corresponding.scoreDef/@*"/>
                    </xsl:copy>  
                </xsl:when>
                <xsl:otherwise>
                    <xsl:next-match/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

    
<xsl:template match="node() | @*" mode="#all">
    <xsl:copy>
        <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
</xsl:template>

</xsl:stylesheet>