ad_page_contract {
    @cvs-id $Id$
} {
    election_id:integer
    q:integer,array,optional
} 

set user_id [auth::require_login]
set valid_voter [oct-election::valid_voter_p -election_id $election_id -user_id $user_id]
set valid_voter_p [lindex $valid_voter 0]
set valid_voter_text [lindex $valid_voter 1]

if {!$valid_voter_p} {
    ad_return_complaint 1 "$valid_voter_text"
    ad_script_abort
}

set votes 0
set max_votes [db_string get_max_votes {
    select number_of_candidates
      from oct_election
    where election_id = :election_id}]

# TODO: this should all be in a transaction, and would if I knew/trusted how to do that

# process the ballot one candidate at a time, keeping an eye on the total vote limit
set searchId [array startsearch q]
while {[array anymore q $searchId]} {
    if {$votes  > $max_votes} {
	#don't process this vote or any others
	# this may be early by 1 - should it go after set candidate?
	break
    }

    set candidate_id [array nextelement q $searchId]
    set votes [expr $votes + 1]

    # TODO: verify that the candidate is actually in the election
    db_dml tally_vote {
	insert into oct_vote values (:candidate_id);
    }


}

db_dml mark_user_ballot {
    insert into oct_ballot values (:user_id, :election_id);
}

