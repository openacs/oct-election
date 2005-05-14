ad_page_contract {
    @cvs-id $Id$
} {
}

set page_title "OCT Elections"
set context $page_title
set admin_p [acs_user::site_wide_admin_p]

template::list::create \
    -name elections \
    -multirow elections \
    -elements {
	label {
	    link_url_col election_url
	    label "Election"
	}
    }

db_multirow \
    -extend { 
	election_url
    } elections elections_select {
	select election_id,
               label,
               start_time,
               end_time
          from oct_election
    } {
	set election_url [export_vars -base "election" {election_id}]
    }
 

