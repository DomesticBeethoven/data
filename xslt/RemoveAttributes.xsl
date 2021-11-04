<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:math="http://www.w3.org/2005/xpath-functions/math"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                xmlns:mei="http://www.music-encoding.org/ns/mei"
                xmlns:uuid="java:java.util.UUID"
                exclude-result-prefixes="xs math xd mei"
                version="3.0">
   
   <!-- Replace STACCISS with SPICC -->
   <!-- Plus: see TODO below .... -->
   

   <xd:doc scope="stylesheet">
      <xd:desc>
         <xd:p>
            <xd:b>Created on:</xd:b> Sep 4, 2020</xd:p>
         <xd:p>
            <xd:b>Author:</xd:b> johannes</xd:p>
         <xd:p>
            <xd:b>Edited by</xd:b> Mark</xd:p>
         
         <xd:p>Adaptation of original by JK</xd:p>
         <xd:p>Augmented to include conversion of bTrem, add slur endings, remove trailing zeros from tstamp</xd:p>
         
         <xd:p>Basic XSLT to remove unwanted attributes from Sibelius MEI exports</xd:p>
         <xd:doc scope="stylesheet">
            <xd:desc>
               <xd:p>
                  <xd:b>Created on:</xd:b> Jan 26, 2021</xd:p>
               <xd:p>
                  <xd:b>Author:</xd:b> MS</xd:p>
               <xd:p>
                  <xd:b>Edited on: </xd:b> April 22, 2021</xd:p>
               <xd:p/>
            </xd:desc>
         </xd:doc>
         
         <!-- TODO: -->
         <!-- INSERT revisionDesc/change automatically, with date and filename -->
         
         <xd:doc>
            <xd:desc>
               <xd:p>match root, include processing instructions</xd:p>
            </xd:desc>
         </xd:doc>
         <xsl:template match="/">
            <xsl:apply-templates select="node()"/>
            <xsl:apply-templates select="processing-instruction()"/>
         </xsl:template>
      </xd:desc>
   </xd:doc>
   <xd:doc>
      <xd:desc>
         <xd:p>set output to xml</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:output indent="yes" method="xml"/>
   <xd:doc>
      <xd:desc>
         <xd:p>MEI version number: 4.0.1</xd:p>
      </xd:desc>/&gt;
  </xd:doc>
   <xsl:template match="/mei:mei/@meiversion">
      <xsl:attribute name="meiversion" select="'4.0.1'"/>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>remove @music.name"</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="@music.name"/>
   <xd:doc>
      <xd:desc>
         <xd:p>remove text and font attributes</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="@rend | @text.name | @fontstyle |                         @fontfam | @fontweight | @color"/>
   <xd:doc>
      <xd:desc>
         <xd:p>Remove font for lyrics</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="@lyric.name"/>
   <xd:doc>
      <xd:desc>
         <xd:p>remove page margin attributes</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="@page.rightmar | @page.leftmar | @page.botmar | @page.topmar"/>
   <xd:doc>
      <xd:desc>
         <xd:p>remove page size atts</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="@page.height | @page.width"/>
   <xd:desc>
      <xd:p>Remove distributor/copyright statement 
        from pubStmt/availabilty</xd:p>
   </xd:desc>
   <xsl:template match="mei:distributor"/>
   <xd:doc>
      <xd:desc>
         <xd:p>Removes @accid.ges
          when @accid = @accid.ges</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="mei:accid[@accid.ges = @accid]/@accid.ges"/>
   <xd:doc>
      <xd:desc>
         <xd:p>Remove MIDI atts</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="mei:instrDef | @pnum | @ppq | @dur.ppq | @dur.ges | @vel"/>
   <xd:doc>
      <xd:desc>
         <xd:p>Remove instrDef comments</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="comment()[following-sibling::mei:instrDef[1]]"/>
   <xd:doc>
      <xd:desc>
         <xd:p>Remove annotation of total duration in seconds</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="mei:annot[@type='duration']"/>
   <xd:doc>
      <xd:desc>
         <xd:p>Remove tstamp.ges, tstamp.real</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="@tstamp.ges | @tstamp.real"/>
   <xd:doc>
      <xd:desc>
         <xd:p>Remove horizontal and vertical offset details</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="@ho | @vo"/>

   <xd:doc>
      <xd:desc>
         <xd:p>Remove trailing zeros from @tStamp</xd:p>
      </xd:desc>/&gt;
</xd:doc>
   <xsl:template match="@tstamp">
      <xsl:attribute name="tstamp">
         <xsl:value-of select="number(.)"/>
      </xsl:attribute>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>Normalize space on @label</xd:p>
      </xd:desc>/&gt;
</xd:doc>
   <xsl:template match="@label">
      <xsl:attribute name="label">
         <xsl:value-of select="normalize-space(.)"/>
      </xsl:attribute>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>Make sure ties have endpoint</xd:p>
      </xd:desc>/&gt;
  </xd:doc>
   <xsl:template match="mei:tie[not(@endid) and not(@tstamp2)]">
      <xsl:copy select=".">
         <xsl:apply-templates select="node() | @*"/>
         <xsl:attribute name="tstamp2">1m+1</xsl:attribute>
      </xsl:copy>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>If @right="single", delete</xd:p>
      </xd:desc>/&gt;
  </xd:doc>
   <xsl:template match="mei:measure/@single"/>
   <xd:doc>
      <xd:desc>
         <xd:p>Find tuplets notated with slash on stem 
        and insert bTrem element and @unitdur </xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="mei:tuplet[mei:note[@stem.mod='1slash']]">
      <xsl:copy select=".">
         <xsl:apply-templates select="@*"/>
         <bTrem xmlns="http://www.music-encoding.org/ns/mei">
        <!-- Maybe edit so that 1slash=8th, 2slash=16th, etc.  -->
            <xsl:attribute name="unitdur" select="8"/>
            <xsl:copy select="./mei:note">
               <xsl:apply-templates select="@*"/>
            </xsl:copy>
         </bTrem>
      </xsl:copy>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>Record XSLT in revisionDesc</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="mei:encodingDesc">
      <xsl:copy>
         <xsl:apply-templates select="node() | @*"/>
         <change xmlns="http://www.music-encoding.org/ns/mei">
            <xsl:attribute name="n" select="xs:int(mei:change[1]/@n) + 1"/>
            <changeDesc>
               <p>Apply XSLT "RemoveAttributes.xsl":</p>
               <p>Remove unwanted attributes from SIBMEI export;</p>
               <p>insert tie endpoints; insert bTrem"</p>
            </changeDesc>
            <date isodate="{substring(string(current-date()),1,10)}"/>
         </change>
      </xsl:copy>
   </xsl:template>
   <xd:doc>
      <xd:desc>
         <xd:p>A simple copy template</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="node() | @*" mode="#all">
      <xsl:copy>
         <xsl:apply-templates select="node() | @*" mode="#current"/>
      </xsl:copy>
   </xsl:template>
</xsl:stylesheet>
