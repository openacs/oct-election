<master>
  <property name="doc(title)">@page_title;literal@</property>
  <property name="context">"@context;noquote@"</property>

<listtemplate name="elections"></listtemplate>
<if @admin_p;literal@ true>
<p><a href="election-edit">Add an Election</a></p>
</if>