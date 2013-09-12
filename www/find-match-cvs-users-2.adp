<master>
  <property name="doc(title)">@title@</property>
  <property name="context">@context@</property>
  
<multiple name="users">

  <if @users.assigned_p eq "0">
     <li>@users.last_name@, @users.first_names@ (@users.email@) - <b>CVS user: @users.username@</b></li>
  </if>
  <else>
     <li><a href="match-cvs-users-2?user_id=@users.person_id@&cvs_user=@cvs_user@">@users.last_name@, @users.first_names@ (@users.email@)</a></li>
  </else>
</multiple>
</ul>
