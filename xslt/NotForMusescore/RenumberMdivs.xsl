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
            <xd:p><xd:b>Created on:</xd:b> 2021</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p><xd:b>Edit:</xd:b> Mark</xd:p> 
            <xd:p> Renumber mdivs - for merging movements</xd:p>
            <xd:p> Needs two xsl:param: $mdiv.n and $offset (as xs:integer) </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="xml" indent="yes"/>
<xd:doc>
    <xd:desc>
        <xd:p>This mdiv number and offset value specifically for</xd:p>
        <xd:p>joining op 93 mvt 3 Minuet and Trio</xd:p>
        <xd:p>This makes continuous measure sequence</xd:p>
        <xd:p>Keeps mdiv separation between Minuet and Trio</xd:p>
    </xd:desc>/>
</xd:doc> 
    
    
    <!--  FIX Mvt numbers and Names !!  -->
    <!-- mdiv @types .. movement, minuet, trio . . . -->
    
    <xsl:param name="mdiv.n" select="'4'" as="xs:string"/>
    <xsl:param name="offset" select="47" as="xs:integer"/>
    
    
    
    <xsl:template match="/">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
  
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
<xd:doc>
    <xd:desc>
        <xd:p>Can't convert '9b' to an integer</xd:p>
        <xd:p>Fortunately, a 2bar multirest in 1st system means @n = @label.
            Here, the match is on @n, because they happen to be sequential.
            
            Would be good to have a $var to be copied into @label and @n
        </xd:p>
    </xd:desc>
</xd:doc>

    <xsl:template match="mei:mdiv[@n = $mdiv.n]/mei:score/mei:section/mei:measure/@n">
        <xsl:variable name="newMeasure" select="xs:integer(.) + $offset"/>
        <xsl:attribute name="n" select="$newMeasure"/>
    </xsl:template>


    <xsl:template match="mei:mdiv[@n = $mdiv.n]/mei:score/mei:section/mei:measure/@label">
        <xsl:choose>
            <xsl:when test="(number(.))">
            <xsl:attribute name="label" select="xs:integer(.) + $offset"/> 
            </xsl:when>
        </xsl:choose>
    </xsl:template>

<xd:doc>
    <xd:desc>
        <xd:p>Change @n and @label for mvt 3 Trio and mvt 4</xd:p>
    </xd:desc>
</xd:doc>

     <!-- test -->  

<xsl:template match="//mei:fileDesc" >
    <xsl:variable name="fourthMvtMdiv" select="//mei:mdiv[@n='5']" as="node()"/>
    <xsl:variable name="value" select="4444"/>
    <xsl:copy select="."/>
<!--    <xsl:value-of select="1111"/>-->
    <xsl:value-of select="$fourthMvtMdiv"></xsl:value-of>
    <xsl:text>IUSDFSKDJFÖKJX</xsl:text>
</xsl:template>
    

<xd:doc>
    <xd:desc>
        <xd:p>Change 2nd ending from x-b (just 103b, 9b in trio taken care of in mdiv renumbering)
               to new number (104)</xd:p>
    </xd:desc>
</xd:doc>
<xsl:template match="mei:measure[@label='103b']/@label">

    <xsl:attribute name="label" select="104"/>
    
</xsl:template>
    


<!-- mdiv type=mvt n=3
        mdiv type=minuet label=3.1
        mdiv type=trio label=3.2
-->
    
<xsl:template match="mei:mdiv[@n='3']">
    <mdiv type="movement" n="3" label="3. Tempo di Menuetto">
    <mdiv type="minuet" label="3.1 Tempo di Menuetto"/>
    <xsl:copy-of select="mei:score"></xsl:copy-of>
    <mdiv type="trio" label="3.2 Trio">
  <xsl:copy-of select="mei:mdiv[@n='4']/mei:score"></xsl:copy-of>
    </mdiv>
    </mdiv>
        

</xsl:template>



<xsl:template match="mei:mdiv[@n='4']/@n">
    <xsl:attribute name="n">3</xsl:attribute>    
</xsl:template>
<xsl:template match="mei:mdiv[@n='4']/@label">
    <xsl:attribute name="label">3.2 Trio.</xsl:attribute>    
</xsl:template>


<xsl:template match="mei:mdiv[@n='5']/@n">
    <xsl:attribute name="n">4</xsl:attribute>    
</xsl:template>
<xsl:template match="mei:mdiv[@n='5']/@label">
    <xsl:attribute name="label">4. Allegro vivace.</xsl:attribute>    
</xsl:template>
    
<!--     
<xsl:template match="mei:measure">
    <xsl:variable name="mNum" select="(preceding-sibling::*[1]/@label)+1"/>
    <xsl:if test="contains(@label, 'b')">
        <xsl:comment>Second Ending Measure</xsl:comment>
        <xsl:value-of select="$mNum"/>
    </xsl:if>
</xsl:template>    
-->
<!-- 
    <xsl:copy>
        <xsl:apply-templates select="$measure.file//mei:mdiv[@n = $mdiv.n]//mei:measure[@n = $measure.n]/@facs"/>
        <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
    

    
    <xsl:template match="mei:mdiv[@n = $mdiv.n]/mei:measure/@label">
        <xsl:attribute name="label" select="xs:integer(.) + $offset"/>
    </xsl:template>
    
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
 -->   
    
</xsl:stylesheet>