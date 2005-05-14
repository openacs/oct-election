<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

<listtemplate name="elections"></listtemplate>
<if @admin_p@>
<p><a href="election-edit">Add an Election</a></p>
</if>