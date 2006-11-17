# 

ad_page_contract {
    
    This script tries to match the cvs accounts with the openacs.org accounts
    
    @author Victor Guerra (guerra@galileo.edu)
    @creation-date 2006-11-13
    @arch-tag: 868cdf88-cbc4-4e37-8f6c-ba7caab5d2cd
    @cvs-id $Id$
} {
    
} -properties {
} -validate {
} -errors {
}

if {![acs_user::site_wide_admin_p]} {
    ad_return_complaint 1 "You have no permission to manage cvs users!"
}

set title "CVS Users Sync"
set context [list $title]
set cvs_users_file "[acs_root_dir]/cvs_users.txt"

if {![file exists $cvs_users_file]} {
    ad_return_complaint 1 "file cvs_users.txt not found!!, it should be under [acs_root_dir]"
}

set fp [open $cvs_users_file r]
set cvs_users [read $fp]
close $fp

template::list::create \
    -name users_info \
    -multirow users_info \
    -key line_id \
    -elements {
	line_id {
	    label "Line \#"
	    html { align center }
	}
	cvs_user {
	    label "CVS User"
	    display_template { <a href="http://xarg.net/tools/cvs/change-sets?user=@users_info.cvs_user@">@users_info.cvs_user@</a> }
	    html { align center}
	}
	associated_user {
	    label "openacs.org user"
	    html { align center }
	}
	possible_user {
	    label "Possible openacs.org user"
	    display_template { @users_info.possible_user;noquote@ }
	    html { align center}
	}
	actions {
	    label "Actions"
	    display_template { @users_info.actions;noquote@}
	    html { align center }
	}
    }

multirow create users_info line_id cvs_user associated_user possible_user actions

set line_number 0
foreach line [split $cvs_users "\n"] {
    set actions "-"
    set associated_user ""
    set possible_user ""
    incr line_number
    set line_splitted [split $line ":"]
    set cvs_user [lindex $line_splitted 0]

    if {$cvs_user ne ""} {
	set user_names [lindex $line_splitted 4]
	set user_id [acs_user::get_by_username -username $cvs_user]
	if {$user_id ne ""} {
	    acs_user::get -user_id $user_id -array user_info
	    set associated_user "$user_info(name) ($user_info(email))"
	} else {
	    regsub " " [string tolower $user_names] "" lower_user_names 
	    foreach person_id [db_list get_persons {
		select person_id from persons
	     	where lower(replace(first_names || last_name, ' ', '')) = :lower_user_names
	    }] {
		acs_user::get -user_id $person_id -array user_info 
		append possible_user "$user_info(name) ($user_info(email)) <a href=\"match-cvs-users-2?user_id=$person_id&cvs_user=$cvs_user\"> match </a><br />" 
	    }
	}
	if {$associated_user eq "" && $possible_user eq ""} {
	    set actions "<a href=\"find-match-cvs-users?cvs_user=$cvs_user\">Find a match</a>"
	}
	multirow append users_info $line_number "$user_names ($cvs_user)" $associated_user $possible_user $actions
    }
}

