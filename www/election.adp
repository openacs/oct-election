<master>
  <property name="doc(title)">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

<p>Election: @label@
<p>Number of OCT vacancies: @number_of_candidates@
<p>Start time: @pretty_start_time@
<p>End time: @pretty_end_time@
<p>Forum cutoff date: @pretty_vote_forum_cutoff@
<p>Check CVS Commit History for the las @cvs_history_days@ days
<p>Ballots: @ballot_count@
<if @admin_p@>
<p>  <a href="election-edit?election_id=@election_id@">Edit</a></p>
</if>
<h2>Candidates</h2>
<listtemplate name="candidates"></listtemplate>
<if @admin_p@ and @past_start_p@ ne 1>
<p>
  <form action="candidate-add">
    <input type="hidden" name="election_id" value="@election_id@"/>
    <input type="text" name="candidate"/>
    <input type="submit" value="add candidate"/>
  </form>
</p>
</if>

<if @valid_voter_p@>
  <form action="vote">
    <input type="hidden" name="election_id" value="@election_id@"/>
    <input type="submit" value="Vote"/>
  </form>
</if>
<else>
  @valid_voter_text;noquote@
</else>

