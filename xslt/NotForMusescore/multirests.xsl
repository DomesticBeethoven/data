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
   <xsl:output method="xml" indent="yes"/>
   
   
<!-- NB: This will not differentiate between a multiRest n=1
         and an mRest -->   

<!-- 
        
        Formula:
        Difference between $diff1 and $diff2 = # of measures to add
        Difference($diff2, $diff1) + 1 = Duration of multiRest

-->
   
<!--   <xd:doc scope="stylesheet">
      <xd:desc>
         <xd:p><xd:b>Created on:</xd:b> February 2021</xd:p>
         <xd:p><xd:b>Author:</xd:b> Mark</xd:p>
         <xd:p>      
         
Find multirests in Measures/Zone file by comparing @n and @label
Compare the diff in current measure with the diff in next.
If greater diff in following measure, then current measure has multiRest.

Replace single measure with $multirestDur number of copies

         </xd:p>
      </xd:desc>
   </xd:doc>-->

<!-- Template for XSLT revisions -->    
<xsl:template match="mei:meiHead">
   <xsl:if test="exists(revisionDesc)">
   </xsl:if>
   <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <change xmlns="http://www.music-encoding.org/ns/mei">
         <xsl:attribute name="n" select="max(mei:change/xs:int(@n)) + 1"/>
         <changeDesc xmlns="http://www.music-encoding.org/ns/mei">
            <p xmlns="http://www.music-encoding.org/ns/mei">Resolve multi-rests, multirests.xsl</p>
            <date isodate="{substring(string(current-date()),1,10)}"/>
         </changeDesc>
      </change>
   </xsl:copy>
</xsl:template>
   <xsl:template match="mei:measure"> 
      <xsl:variable name="hasSuccessor" select="exists(following-sibling::mei:measure)" as="xs:boolean"/>
      <xsl:choose>
         <xsl:when test="not($hasSuccessor)">
            <xsl:next-match/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:variable name="n1" select="xs:integer(replace(@n, '\D',''))" as="xs:integer"/>
            <xsl:variable name="label1" select="xs:integer(replace(@label, '\D',''))" as="xs:integer"/>
            <xsl:variable name="diff1" select="$label1 - $n1" as="xs:integer"/>
            
            <xsl:variable name="n2" select="xs:integer(replace(following-sibling::mei:measure[1]/@n, '\D',''))" as="xs:integer"/>
            <xsl:variable name="label2" select="xs:integer(replace(following-sibling::mei:measure[1]/@label, '\D',''))" as="xs:integer"/>
            <xsl:variable name="diff2" select="$label2 - $n2" as="xs:integer"/>
            <xsl:text>&#xa;</xsl:text>
            
            <xsl:variable name="differenceIncrease" select="$diff2 - $diff1"/>
            <xsl:variable name="multirestDur" select="$differenceIncrease + 1"/>
            
            <xsl:variable name="currentMeasure" select="." as="element()"/>
            
            <xsl:choose>

               <xsl:when test="$diff1 = $diff2">
                  <xsl:copy select=".">
                     <xsl:apply-templates select="@xml:id"/>
                     <xsl:apply-templates select="@label"/>
                     <xsl:apply-templates select="@facs"/>
                  </xsl:copy>
                  
               </xsl:when>
               
               <xsl:when test="$diff1 lt $diff2">           
            
                  <xsl:for-each select="(1 to $multirestDur)">
                     <xsl:variable name="currentIteration" select="." as="xs:integer"/>
                     <xsl:apply-templates select="$currentMeasure" mode="resolveMrest">
                        <xsl:with-param name="iteration" select="$currentIteration" tunnel="yes"/>
                     </xsl:apply-templates>
                  </xsl:for-each>

               </xsl:when>
            </xsl:choose>            
         </xsl:otherwise>  
      </xsl:choose>
   </xsl:template>

<xsl:template match="mei:measure" mode="resolveMrest">
   <xsl:param name="iteration" tunnel="yes" as="xs:integer"/>
   <xsl:copy>
      <xsl:apply-templates select="@xml:id" mode="#current"/>
      <xsl:apply-templates select="@label" mode="#current"/>
      <xsl:apply-templates select="@facs" mode="#current"/>
      <xsl:attribute name="type" select="'mRest mRest-' || $iteration"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="mei:measure/@label" mode="resolveMrest">
   <xsl:param name="iteration" tunnel="yes" as="xs:integer"/>
   <xsl:variable name="num" select="xs:integer(.)+$iteration - 1"/>
   <xsl:attribute name="label" select="$num"/>
</xsl:template>
   
<xsl:template match="mei:measure/@xml:id" mode="resolveMrest">
   <xsl:attribute name="xml:id" select="'m' || uuid:randomUUID()"/>
</xsl:template>


<!-- copy template -->
   <xsl:template match="@* | node()" mode="#all">
      <xsl:copy>
         <xsl:apply-templates select="@* | node()" mode="#current"/>
      </xsl:copy>
   </xsl:template>
</xsl:stylesheet>

