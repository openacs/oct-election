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
     
    set num_days 90
    set valid_voter_p 0
    db_1row get_election {
 	select start_time,
	       end_time,
	       vote_forum_cutoff,
	       label,
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
	set text "You are not a valid voter for this election because you have not posted at least twice in the OpenACS forums since $pretty_vote_forum_cutoff.  See <a href=\"http://openacs.org/governance/\">OpenACS Governance</a>"
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
    set text "You have already voted in this election."
    return [list $status $text]
}
