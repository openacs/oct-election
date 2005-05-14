ad_page_contract {
    @cvs-id $Id$
} {
    election_id:integer
} 

set user_id [auth::require_login]
set admin_p [acs_user::site_wide_admin_p]
set valid_voter [oct-election::valid_voter_p -election_id $election_id -user_id $user_id]
set valid_voter_p [lindex $valid_voter 0]
set valid_voter_text [lindex $valid_voter 1]

db_1row get_election {
    select start_time,
           end_time,
           vote_forum_cutoff,
           label
      from oct_election
     where election_id = :election_id
}

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
	    display_template {
  		  <img src="/resources/acs-subsite/Delete16.gif" width="16" height="16" border="0">
	    }
	    sub_class narrow
	}
    }

db_multirow \
    -extend { 
	delete_url
    } candidates candidates_select {
	select candidate_id,
               label as candidate_label
          from oct_candidate
         where election = :election_id
    } {
	set delete_url [export_vars -base "candidate-delete" {candidate_id  election_id}]
    }
 
#TODO: show vote total if election is over
#TODO: hide delete button if not admin
#TODO: sort candidates by vote total if election is over, or alpha if not




