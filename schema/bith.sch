<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
   xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
   <sch:ns uri="http://www.music-encoding.org/ns/mei" prefix="mei"/>
<!-- EXAMPLE 
   <sch:pattern id="check-ancestor-staff">
      <sch:rule context="mei:scoreDef">
         <sch:assert role="warning" test="@hurz">A scoreDef should have a @hurz attribute (or not)</sch:assert>
      </sch:rule>
   </sch:pattern>   -->

   <sch:pattern id="check-mei-id">
      <sch:rule context="mei:mei">
         <sch:assert test="@xml:id">An mei file must have an id</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="check-title">
      <sch:rule context="mei:work">
         <sch:assert  test="mei:title">A work must have a title</sch:assert>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="check-page-layout-attributes">
      <sch:rule context="mei:rend">
         <sch:report role="warning" test="@fontfam">fontfamily unnecessary and should be deleted</sch:report>
      </sch:rule>
      <!-- etc for other font atts -->
   </sch:pattern>
   <sch:pattern id="check-multiple-rend-children">
      <sch:rule context="mei:dir">
         <sch:report role="warning" test="mei:rend[2]">dir should only have 1 rend element</sch:report>
      </sch:rule>
   </sch:pattern>
   <sch:pattern id="check-tie-endpoints">
      <sch:rule context="mei:tie">
         <sch:assert test="@startid or @tstamp">A tie needs @startid</sch:assert>
         <sch:assert test="@endid or @tstamp2">A tie needs @endid</sch:assert>
      </sch:rule>
   </sch:pattern>
   
   <!-- API rules -->
   
   <sch:pattern id="check_presence">
      <sch:rule context="mei:meiHead">
         <sch:assert test="mei:workList[count(mei:work) = 1]">
            There needs to be a workList, with exactly one work in there.
         </sch:assert>
         <sch:assert test="mei:manifestationList[count(mei:manifestation) = 1]">
            There needs to be a manifestationList, with exactly one manifestation in there.
         </sch:assert>
      </sch:rule>
   </sch:pattern>
   
   <sch:pattern id="check_manifestation">
      <sch:rule context="mei:manifestation">
         <sch:assert test="./mei:titleStmt/mei:title/text() and string-length(./mei:titleStmt/mei:title/text()) gt 0">
            Every manifestation should have a title.
         </sch:assert>
         <sch:assert test="./mei:pubStmt">
            Every manifestation needs a publication statement.
         </sch:assert>
         <sch:assert test="./mei:pubStmt/mei:pubPlace/mei:geogName">
            Every manifestation needs a publication place, expressed as a geogName.
         </sch:assert>
         <sch:assert test="./mei:pubStmt/mei:date">
            Every manifestation needs a publication date.
         </sch:assert>
         <sch:assert test="./mei:pubStmt/mei:publisher/mei:corpName">
            Every manifestation should have a publisher with a corpName.
         </sch:assert>
         <sch:assert test=".//mei:item">
            Every manifestations needs at least one item.
         </sch:assert>
         
         <sch:let name="expressionLink" value="./mei:relationList/mei:relation[@rel='isEmbodimentOf']"/>
         <sch:let name="expressionIDs" value="./ancestor::mei:meiHead//mei:expression/@xml:id"/>
         <sch:assert test="exists($expressionLink)">
            Every manifestation needs a relation to an expression.
         </sch:assert>
         <sch:assert test="$expressionLink/substring(@target,2) = $expressionIDs">
            Every manifestation needs to relate to an existing expression xml:id. mei:manifestation/mei:relationList/mei:relation/@target seems broken.
         </sch:assert>
      </sch:rule>
   </sch:pattern>
   
   <sch:pattern id="check_work">
      <sch:rule context="mei:work">
         <sch:assert test="@auth.uri">
            Every work should have an auth.uri.
         </sch:assert>
         <sch:assert test="./mei:identifier[@type='opusNumber']">
            Every work should have an identifier with @type="opusNumber".
         </sch:assert>
         <sch:assert test="./mei:title[@type='uniform']">
            Every work should have a title with @type="uniform".
         </sch:assert>
         <sch:assert test="./mei:title[@type='abbreviated']">
            Every work should have a short title with @type="abbreviated".
         </sch:assert>
         <sch:assert test="./mei:composer/mei:persName[@auth.uri]">
            Every work should have a composer, which needs to be encoded as persName with @auth.uri.
         </sch:assert>
         <sch:assert test="./mei:creation/mei:date">
            Every work should have a creation date.
         </sch:assert>
         <sch:assert test="./mei:expressionList/mei:expression">
            Every work needs an expression.
         </sch:assert>
      </sch:rule>
   </sch:pattern>
   
   <sch:pattern id="check_expression">
      <sch:rule context="mei:expression">
         <sch:assert test="@xml:id">
            Every expression needs an xml:id.
         </sch:assert>
         <sch:assert test="./mei:identifier[@type='genre']/@auth.uri">
            Every expression needs a genre reference (./mei:identifier[@type='genre']/@auth.uri).
         </sch:assert>
         <sch:assert test="./mei:title[@type='desc']/text()">
            Every expression needs a descriptive title (./mei:title[@type='desc']/text()).
         </sch:assert>
         <!-- <sch:assert test="./mei:arranger/mei:persName[@auth.uri and text()]">
            Every expression needs an arranger 
         </sch:assert> -->
         <sch:assert test="./mei:perfMedium/mei:perfResList/mei:perfRes/@auth.uri">
            Every expression needs a perfResList/perfRes/@auth.uri.
         </sch:assert>
      </sch:rule>
   </sch:pattern>
   
   <sch:pattern id="check_fileDesc">
      <sch:rule context="mei:fileDesc">
         <sch:assert test="./mei:titleStmt/mei:title[@type='desc']">
            Every fileDesc needs a descriptive title (./mei:title[@type='desc']/text()).
         </sch:assert>
      </sch:rule>
   </sch:pattern>
   
   <sch:pattern id="check_item">
      <sch:rule context="mei:item">
         <sch:assert test="./@xml:id">
            Every item should have an xml:id.
         </sch:assert>
         <sch:assert test="./mei:physLoc">
            Every item should have a physLoc.
         </sch:assert>
         <sch:assert test="./mei:physLoc/mei:repository[string-length(normalize-space(text())) gt 0]">
            Every physLoc should have a repository.
         </sch:assert>
         <sch:assert test="./mei:physLoc/mei:identifier[string-length(normalize-space(text())) gt 0]">
            Every physLoc should have an identifier.
         </sch:assert>
      </sch:rule>
   </sch:pattern>
   
   <sch:pattern id="check_geogNames">
      <sch:rule context="mei:geogName">
         <sch:assert test="@auth.uri or (string-length(normalize-space(text())) gt 0)">
            A geographical name needs either an authority reference, or a specified place name.
         </sch:assert>
      </sch:rule>
   </sch:pattern>
   
   <sch:pattern id="check_dates">
      <sch:rule context="mei:date">
         <sch:assert test="@isodate or (@startdate and @enddate)">
            A date needs either an @isodate or a @startdate and an @enddate.
         </sch:assert>         
      </sch:rule>
   </sch:pattern>
   
   <sch:pattern id="check_auth.uri">
      <sch:rule context="@auth.uri">
         <sch:assert test="string-length(normalize-space(.)) gt 0">
            Every reference to an authority needs to be longer than zero.
         </sch:assert>
      </sch:rule>
   </sch:pattern>
   
</sch:schema>