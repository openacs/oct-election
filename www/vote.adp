<master>
  <property name="doc(title)">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

<p>Vote for up to @number_of_candidates@ candidates.  (Extra votes will be ignored.)  Ballots are anonymous and cannot be revoked or altered.</p>
<form action="vote-process">
  <input type="hidden" name="election_id" value="@election_id@">

<multiple name="candidates">
<p><input type="checkbox" name="q.@candidates.candidate_id@" value="@candidates.candidate_id@"/> <b>@candidates.candidate_label@</b></p>
</multiple>

<p>  <input type="submit" value="Submit Ballot"></p>
</form>