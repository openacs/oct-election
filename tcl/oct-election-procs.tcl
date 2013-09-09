ad_library {
    Procs for election
}

namespace eval oct-election {}

ad_proc -private oct-election::valid_voter_p {
    -election_id
    -user_id 
} {
    @author Joel Aufrecht
} {
    set status 1
    set text ""
    # Has the user already voted in this election?
    set ballot_p [db_string get_ballot {
	select count(*) 
	from oct_ballot
	where user_id = :user_id
	and election_id = :election_id
    }]

    if {$ballot_p} {
	set status 0
	set text "You have already voted in this election."
	return [list $status $text]
    }
     
    set num_days 180

    set valid_voter_p 0
    db_1row get_election {
 	select start_time,
	       end_time,
	       vote_forum_cutoff,
	       label,
	       cvs_history_days,
               (case when now() > start_time then 1 else 0 end) as past_start_p,
               (case when now() > end_time then 1 else 0 end) as past_end_p
	from oct_election
	where election_id = :election_id
    }

    set pretty_vote_forum_cutoff [lc_time_fmt $vote_forum_cutoff %c]
    set before_sql "to_date(:vote_forum_cutoff, 'YYYY-MM-DD')"
    
    set num_posts [db_string get_count "
         select count(message_id) as num_posts
           from cc_users, forums_messages
          where cc_users.user_id = forums_messages.user_id
            and posting_date between $before_sql - interval '$num_days days' and $before_sql
            and cc_users.user_id = $user_id
    	"]
    
    if {$num_posts < 2} {
	set status 0
	ns_log warning "not valid voter b/c forums $user_id"
	set text "You are not a valid voter for this election because you have not posted at least twice in the OpenACS forums since $pretty_vote_forum_cutoff.  See <a href=\"http://openacs.org/governance/\">OpenACS Governance</a>"
    } else {
	set valid_voter_p 1
    }

    #Checking CVS commit history
    set cvs_user [acs_user::get_element -user_id $user_id -element username]
    set cvs_history_date [db_string get_cvs_days {                 
 	select start_time::date - cvs_history_days   
	from oct_election       
	where election_id = :election_id
    } ]
    
    set ql "select revisions where date in \[${cvs_history_date},[lc_time_fmt $start_time %Y-%m-%d]\] and author=$cvs_user order by date group by directory return totalLines"
    set csv "true"
    set service_url [export_vars -base "http://fisheye.openacs.org/search/OpenACS/" {ql csv}]
    
    ns_log Warning "vguerra trying request: $service_url"
    
    if {![catch {
        set commit_info [ns_httpget $service_url]
    } errmsg] } {
        set commits [llength [split $commit_info "\n"]]
        if {$commits < 3} {
            if {$status} {
                set status 0 
                set text "You are not a valid voter for this election because you have not committed in the CVS Repository in the last $cvs_history_days .  See <a href=\"http://openacs.org/governance/\">OpenACS Governance</a>"
            }
        } else {
            set valid_voter_p 1
        }
    } else {
        if {$status} {
            set status 0 
            set text "We can not confirm your commit history in our CVS Repository, so you can not vote at this moment."
        }
    }
    
    if {!$valid_voter_p} {
	return [list $status $text]
    }
    
    if {!$past_start_p} {
	set status 0
	set text "The election will not begin until [lc_time_fmt $start_time %c]"
	return [list $status $text]
    }
    if {$past_end_p} {
	set status 0
	set text "The election ended at [lc_time_fmt $end_time %c]"
	return [list $status $text]
    }

    set status 1
    set text "We look forward to your vote."
    return [list $status $text]
}

ad_proc -public oct-election::valid_voters {
    {-status "not_voted"}
    -election_id:required
} {
    Return a list of valid voters

    @param status Could be "voted" or "non_voted", reflecting the voters who have voted for the elections already and the ones who did not vote yet.
} {


    if {$status eq "voted"} {
	return [db_list voters "select u. user_id from cc_users u, (select count(user_id) as ballot,user_id from oct_ballot o where election_id = 5 group by user_id) ballots where ballots.user_id = u.user_id and ballot > 0 and u.member_state = 'approved'"]
	ad_script_abort
    } else {
	set voter_ids [list]
	db_foreach possible_voter "select u. user_id from cc_users u where u.member_state = 'approved'" {
	    
	    # Check if the user is actually allowed to vote
	    set valid_voter [oct-election::valid_voter_p -election_id $election_id -user_id $user_id]
	    set valid_voter_p [lindex $valid_voter 0]
	    if {$valid_voter_p} {
		lappend voter_ids $user_id
	    }
	}
    }

    return $voter_ids
}