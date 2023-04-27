<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:uuid="java:java.util.UUID"
    exclude-result-prefixes="xs math xd mei uuid"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jun 22, 2022</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="xml" indent="yes"/>
    
    <!-- INPUT : number of staves
                 <section> / @xml:id  -->
    
    <xsl:param name="requiredStaves" select="'3'" as="xs:string?"/>
    <xsl:param name="sectionId" select="'gap1'" as="xs:string?"/>
    
    <xsl:variable name="staff.count" select="if(exists($requiredStaves)) then(xs:integer($requiredStaves)) else(0)" as="xs:integer"/>
    <xsl:variable name="height.padding.top" select=".2" as="xs:double"/>
    <xsl:variable name="height.padding.bottom" select=".2" as="xs:double"/>
    <xsl:variable name="height.padding.first.bottom" select=".4" as="xs:double"/>
    <xsl:variable name="height.padding.last.top" select=".4" as="xs:double"/>
    
    <xsl:variable name="section" select="if(exists($sectionId)) then(id($sectionId)) else()" as="node()?"/>
    <xsl:variable name="relevant.zones" select="for $facs in $section//mei:measure/substring(@facs,2) return $facs" as="xs:string*"/>
    
    <xsl:template match="/">
        <!-- if necessary, generate staff zones -->
        <xsl:variable name="zones">
            <xsl:choose>
                <xsl:when test="$staff.count gt 1">
                    <xsl:apply-templates select="node()" mode="adjustZones"/>        
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="node()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- generate staff elements, potentially link to zones -->
        <xsl:variable name="staves">
            <xsl:apply-templates select="$zones" mode="generateStaves">
                <xsl:with-param name="zones" select="$zones//mei:zone[@type = 'staff']" tunnel="yes" as="element(mei:zone)*"/>
            </xsl:apply-templates>
        </xsl:variable>
        <!-- output -->
        <xsl:apply-templates select="$staves" mode="cleanUp"/>
    </xsl:template>
    
    <xsl:template match="mei:zone[@type = 'measure']" mode="adjustZones">
        <!-- keep a copy of the measure -->
        <xsl:next-match/>
        
        <xsl:variable name="zone.id" select="string(@xml:id)" as="xs:string"/>
        
        <!-- proceed only if either all zones are requested, or this is one of the requested ones -->
        <xsl:if test="count($relevant.zones) = 0 or $zone.id = $relevant.zones">
            <!-- keep left / right for later use -->
            <xsl:variable name="measure.left" select="string(@ulx)" as="xs:string"/>
            <xsl:variable name="measure.right" select="string(@lrx)" as="xs:string"/>
            
            
            <!-- make y-dimensions operable -->
            <xsl:variable name="measure.top" select="number(@uly)" as="xs:double"/>
            <xsl:variable name="measure.bottom" select="number(@lry)" as="xs:double"/>
            <xsl:variable name="measure.height" select="$measure.bottom - $measure.top" as="xs:double"/>
            
            <!-- fair share for each staff. will be padded later -->
            <xsl:variable name="height.share" select="$measure.height div $staff.count" as="xs:double"/>
            <xsl:for-each select="(1 to $staff.count)">
                
                <xsl:variable name="position" select="position()" as="xs:integer"/>
                
                <xsl:choose>
                    <!-- first staff -->
                    <xsl:when test="$position = 1">
                        <xsl:variable name="staff.top" select="round($measure.top)" as="xs:double"/>
                        <xsl:variable name="staff.bottom" select="round(min(($measure.top + $height.share * (1 + $height.padding.first.bottom), $measure.bottom)))" as="xs:double"/>
                        
                        <zone xmlns="http://www.music-encoding.org/ns/mei" xml:id="z{uuid:randomUUID()}" corresp="#{$zone.id}" type="staff" staff="{$position}" ulx="{$measure.left}" uly="{$staff.top}" lrx="{$measure.right}" lry="{$staff.bottom}"/>
                    </xsl:when>
                    <!-- last staff -->
                    <xsl:when test="$position = last()">
                        <xsl:variable name="staff.top" select="round(max(($measure.bottom - $height.share * (1 + $height.padding.last.top), $measure.top)))" as="xs:double"/>
                        <xsl:variable name="staff.bottom" select="round($measure.bottom)" as="xs:double"/>
                        
                        <zone xmlns="http://www.music-encoding.org/ns/mei" xml:id="z{uuid:randomUUID()}" corresp="#{$zone.id}" type="staff" staff="{$position}" ulx="{$measure.left}" uly="{$staff.top}" lrx="{$measure.right}" lry="{$staff.bottom}"/>
                    </xsl:when>
                    <!-- staves in between -->
                    <xsl:otherwise>
                        <xsl:variable name="base.bottom" select="$measure.top + $position * $height.share" as="xs:double"/>
                        <xsl:variable name="base.top" select="$base.bottom - $height.share" as="xs:double"/>
                        
                        <xsl:variable name="staff.top" select="round(max(($base.top - $height.share * $height.padding.top, $measure.top)))" as="xs:double"/>
                        <xsl:variable name="staff.bottom" select="round(min(($base.bottom + $height.share * $height.padding.bottom, $measure.bottom)))" as="xs:double"/>
                        
                        <zone xmlns="http://www.music-encoding.org/ns/mei" xml:id="z{uuid:randomUUID()}" corresp="#{$zone.id}" type="staff" staff="{$position}" ulx="{$measure.left}" uly="{$staff.top}" lrx="{$measure.right}" lry="{$staff.bottom}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <!-- generate the simplest possible staffDef -->
    <xsl:template match="mei:scoreDef[not(element())]" mode="generateStaves">
        
        <xsl:choose>
            <xsl:when test="exists($sectionId) and string-length($sectionId) gt 0 and following-sibling::mei:*[1]/@xml:id = $sectionId">
                <xsl:copy>
                    <xsl:apply-templates select="@*" mode="#current"/>
                    <staffGrp xmlns="http://www.music-encoding.org/ns/mei">
                        <xsl:for-each select="(1 to $staff.count)">
                            <staffDef n="{.}" lines="5"/>
                        </xsl:for-each>
                    </staffGrp>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="exists($sectionId) and string-length($sectionId) gt 0 and $sectionId = ancestor::mei:*/@xml:id">
                <xsl:copy>
                    <xsl:apply-templates select="@*" mode="#current"/>
                    <staffGrp xmlns="http://www.music-encoding.org/ns/mei">
                        <xsl:for-each select="(1 to $staff.count)">
                            <staffDef n="{.}" lines="5"/>
                        </xsl:for-each>
                    </staffGrp>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="not(exists($sectionId)) or string-length($sectionId) = 0">
                <xsl:copy>
                    <xsl:apply-templates select="@*" mode="#current"/>
                    <staffGrp xmlns="http://www.music-encoding.org/ns/mei">
                        <xsl:for-each select="(1 to $staff.count)">
                            <staffDef n="{.}" lines="5"/>
                        </xsl:for-each>
                    </staffGrp>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
        
        
    </xsl:template>
    
    <!-- decide if section needs to be processed -->
    <xsl:template match="mei:section | mei:ending" mode="generateStaves">
        <xsl:choose>
            <xsl:when test="not(@xml:id) and exists($sectionId) and string-length($sectionId) gt 0">
                <xsl:next-match>
                    <xsl:with-param name="expand" select="false()" tunnel="yes" as="xs:boolean"/>
                </xsl:next-match>
            </xsl:when>
            <xsl:when test="exists($sectionId) and string-length($sectionId) gt 0 and @xml:id = $sectionId">
                <xsl:next-match>
                    <xsl:with-param name="expand" select="true()" tunnel="yes" as="xs:boolean"/>
                </xsl:next-match>
            </xsl:when>
            <xsl:when test="not(exists($sectionId)) or string-length($sectionId) = 0">
                <xsl:next-match>
                    <xsl:with-param name="expand" select="true()" tunnel="yes" as="xs:boolean"/>
                </xsl:next-match>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match>
                    <xsl:with-param name="expand" select="false()" tunnel="yes" as="xs:boolean"/>
                </xsl:next-match>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- generate staves, connect facs -->
    <xsl:template match="mei:measure[not(mei:staff)]" mode="generateStaves">
        <xsl:param name="zones" tunnel="yes" as="element(mei:zone)*"/>
        <xsl:param name="expand" tunnel="yes" as="xs:boolean"/>
        
        <xsl:variable name="measure.zone.id" select="@facs"/>
        
        <xsl:choose>
            <xsl:when test="$expand">
                <xsl:copy>
                    <xsl:apply-templates select="@*" mode="#current"/>
                    <xsl:for-each select="(1 to $staff.count)">
                        <xsl:variable name="staff" select="xs:string(.)" as="xs:string"/>
                        <xsl:variable name="staffZone" select="$zones[@corresp = $measure.zone.id][@staff = $staff]" as="element(mei:zone)?"/>
                        <staff xmlns="http://www.music-encoding.org/ns/mei" n="{.}">
                            <xsl:if test="exists($staffZone)">
                                <xsl:attribute name="facs" select="'#' || $staffZone/@xml:id"/>
                            </xsl:if>
                            <layer/>
                        </staff>
                    </xsl:for-each>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <!-- remove generation artifacts -->
    <xsl:template match="mei:zone[@type = 'staff']" mode="cleanUp">
        <xsl:copy>
            <xsl:apply-templates select="node() | @* except (@corresp, @staff)" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>