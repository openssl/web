<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:template name="dateformat">

  <xsl:param name="date" select="."/>

  <xsl:variable name="day" select="number(substring($date,7,2))"/>
  <xsl:variable name="month" select="number(substring($date,5,2))"/>
  <xsl:variable name="year" select="number(substring($date,1,4))"/>
  
  <xsl:if test="$day &gt; 0"> 
  <xsl:value-of select="$day" />
  
    <xsl:choose>
      <xsl:when test="$day=1 or $day=21 or $day=31">st</xsl:when>
      <xsl:when test="$day=2 or $day=22">nd</xsl:when>
      <xsl:when test="$day=3 or $day=23">rd</xsl:when>
      <xsl:otherwise>th</xsl:otherwise>
    </xsl:choose>
    
    <xsl:text> </xsl:text>
  </xsl:if>

  <xsl:call-template name="whatmonth">
  <xsl:with-param name="month" select="$month"/>
  </xsl:call-template>
  
  <xsl:if test="$year&gt;0">
    <xsl:text> </xsl:text>
    <xsl:value-of select="$year"/>
    </xsl:if>
    
</xsl:template>

<xsl:template name="whatmonth">
<xsl:param name="month" select="."/>
  <xsl:choose>
    <xsl:when test="$month=01">January</xsl:when>
    <xsl:when test="$month=02">February</xsl:when>
    <xsl:when test="$month=03">March</xsl:when>
    <xsl:when test="$month=04">April</xsl:when>
    <xsl:when test="$month=05">May</xsl:when>
    <xsl:when test="$month=06">June</xsl:when>
    <xsl:when test="$month=07">July</xsl:when>
    <xsl:when test="$month=08">August</xsl:when>
    <xsl:when test="$month=09">September</xsl:when>
    <xsl:when test="$month=10">October</xsl:when>
    <xsl:when test="$month=11">November</xsl:when>
    <xsl:when test="$month=12">December</xsl:when>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
