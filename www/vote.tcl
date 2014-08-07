ad_page_contract {
    @cvs-id $Id$
} {
    election_id:naturalnum,notnull
} 

#TODO: add javascript to prevent people from voting too many times

db_1row get_election {
    select start_time,
           end_time,
           vote_forum_cutoff,
           number_of_candidates,
           label
      from oct_election
     where election_id = :election_id
}

set user_id [auth::require_login]
set page_title "Vote for $label"
set context [list $page_title]
set valid_voter [oct-election::valid_voter_p -election_id $election_id -user_id $user_id]
set valid_voter_p [lindex $valid_voter 0]
set valid_voter_text [lindex $valid_voter 1]

if {!$valid_voter_p} {
    ad_return_complaint 1 "$valid_voter_text"
    ad_script_abort
}

db_multirow candidates candidates_select {
	select candidate_id,
	label as candidate_label
	from oct_candidate
	where election = :election_id
    }
