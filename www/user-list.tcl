ad_page_contract {
    @cvs-id $Id$
} {
}

set page_title "OCT Voting List"
set context $page_title

template::list::create \
    -name voters_foo \
    -multirow voters \
    -elements {
        name {
            label "Name"
	    html { align center}
	    aggregate count
	    aggregate_label "Total"
        }
        cvs_user {
            label "cvs_user"
	    html { align center}
        }
	num_posts {
            label "num_posts"
	    html { align center}
        }
    }

# set up basic vars

set election_id 5

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
set cvs_history_days [db_string get_cvs_days {
    select cvs_history_days
    from oct_election
    where election_id = :election_id
} ]



set num_days 90
set valid_voter_p 0

set before_sql "to_date(:vote_forum_cutoff, 'YYYY-MM-DD')"

set usernames [list]


db_multirow \
    -extend { 
	mailto
	name
    } voters voters_select "
	(select u2.user_id, u2.username as cvs_user, count(message_id) as num_posts
	from users u2, forums_messages
	where u2.user_id = forums_messages.user_id
	and posting_date between $before_sql - interval \'$num_days days\' and $before_sql
	group by u2.user_id, u2.username
	having count(*) > 1)
	UNION
	(select user_id, username as cvs_user, -1 as num_post from users
	where username not like '%@%')
	order by num_posts DESC
    " {

	# don't repeat users
	if {$cvs_user in $usernames} {
	    continue
	}
	lappend usernames $cvs_user
	
	set status 0
	if {$num_posts < 2} {

	    set num_posts "Through CVS commits"
	    #Checking CVS commit history
	    #    set cvs_user [acs_user::get_element -user_id $user_id -element username]
	    if {$cvs_history_days eq 0} {
		set cvs_history_days "all"
	    }
	    set service_url "http://xarg.net/tools/cvs/rss/?user=$cvs_user&days=$cvs_history_days"
	    if {![catch {
		set commit_info [ns_httpget $service_url]
	    } errmsg] } {
		set doc [dom parse $commit_info]
		set root_node [$doc documentElement]
		set commits [llength [$root_node selectNodes /rss/channel/item]]
		if {!$commits} {
		    continue
		} 
	    } else {
		continue
	    }

	}

	set name [acs_user::get_element -user_id $user_id -element name]

    }
