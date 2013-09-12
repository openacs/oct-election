ad_page_contract {
    @cvs-id $Id$
} {
    election_id:integer,optional
} 

permission::require_permission -object_id [ad_conn package_id] -privilege admin
set page_title "Editing Election"
set context [list $page_title]


ad_form -name election -form {
    {election_id:key}
    {label:text {label Election}}
    {start_time:text {label "Start Time (2005-04-01 10:00PST)"}}
    {end_time:text {label "End Time"}}
    {vote_forum_cutoff:text {label "Forum Posting cutoff date (2005-04-01 10:00PST)"}}
    {cvs_history_days:text {label "Number of days for checking Commit History"}}
    {number_of_candidates:integer {label "Number of Candidates"}}
} -new_request {
    auth::require_login
    permission::require_permission -object_id [ad_conn package_id] -privilege create
    set page_title "Add an election"
    set context [list $page_title]
} -edit_request {
    auth::require_login
    # this permission check is a lazy workaround for not having elections as real objects
    permission::require_write_permission -object_id [ad_conn package_id]

    db_1row get_election {
	select start_time,
               end_time,
	       label,
	       vote_forum_cutoff,
	       cvs_history_days,
               number_of_candidates
	  from oct_election
	 where election_id = :election_id;
    }
    set page_title "Edit $label"
    set context [list $page_title]
} -new_data {
    db_dml create_election {
	insert into oct_election
	(start_time, end_time, number_of_candidates, vote_forum_cutoff, label, cvs_history_days)
	values (:start_time, :end_time, :number_of_candidates, :vote_forum_cutoff, :label, :cvs_history_days);
    }
} -edit_data {
    db_dml update_election {
	update oct_election
	set start_time = :start_time,
	end_time = :end_time,
	vote_forum_cutoff = :vote_forum_cutoff,
	cvs_history_days = :cvs_history_days,
        number_of_candidates = :number_of_candidates,
        label = :label	
	where election_id = :election_id}
    ad_returnredirect [export_vars -base election {election_id}]
}
