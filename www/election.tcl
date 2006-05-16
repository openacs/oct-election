ad_page_contract {
    @cvs-id $Id$
} {
    election_id:integer
} 

set user_id [auth::require_login]
set admin_p [permission::permission_p -object_id [ad_conn package_id] -privilege create]
set valid_voter [oct-election::valid_voter_p -election_id $election_id -user_id $user_id]
set valid_voter_p [lindex $valid_voter 0]
set valid_voter_text [lindex $valid_voter 1]

db_1row get_election {
    select start_time,
           end_time,
           vote_forum_cutoff,
           number_of_candidates,
           label,
           (case when now() > start_time then 1 else 0 end) as past_start_p,
           (case when now() > end_time then 1 else 0 end) as past_end_p
      from oct_election
     where election_id = :election_id
}

set pretty_start_time [lc_time_fmt $start_time %c]
set pretty_end_time [lc_time_fmt $end_time %c]
set pretty_vote_forum_cutoff [lc_time_fmt $vote_forum_cutoff %c]

set ballot_count [db_string get_ballot_count {
    select count(*) 
      from oct_ballot
    where election_id = :election_id;
}]

set page_title $label
set context $page_title

template::list::create \
    -name candidates \
    -multirow candidates \
    -elements {
	candidate_label {
	    label "Candidate"
	}
	delete {
	    link_url_col delete_url 
	    display_template "
		<if $admin_p and $past_start_p ne 1>
  		  <img src=\"/resources/acs-subsite/Delete16.gif\" width=\"16\" height=\"16\" border=\"0\">
		</if>
	    "
	    sub_class narrow
	}
	count {
	    label "Votes"
	}
    }

if {!$past_end_p} {
    set order_clause "order by label"
} else {
    set order_clause "order by cand_count desc"
}

db_multirow \
    -extend { 
	delete_url
	count
    } candidates candidates_select "
	select oc.candidate_id,
               oc.label as candidate_label,
               count(ov.candidate_id) as cand_count
	  from oct_candidate oc left outer join oct_vote ov using (candidate_id)
         where oc.election = :election_id
         group by oc.candidate_id, oc.label
         $order_clause
    " {
	set delete_url [export_vars -base "candidate-delete" {candidate_id  election_id}]
	if {$past_end_p} {
	    set count $cand_count
	} else {
	    set count "Results pending"
	}
    }
 
#TODO: hide delete button if not admin
#TODO: sort candidates by vote total if election is over, or alpha if not

#DEBUG
db_1row get_now {
    select now() as now
    from dual;
}
