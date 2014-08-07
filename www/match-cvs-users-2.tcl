# 

ad_page_contract {
    
    Assigns a given cvs user ( useranem ) for a given user
    
    @author Victor Guerra (guerra@galileo.edu)
    @creation-date 2006-11-17
    @arch-tag: ba6f1ea5-8703-4ff3-8f17-9e0b5f3aeae3
    @cvs-id $Id$
} {
    user_id:naturalnum,notnull
    cvs_user:notnull
} -properties {
} -validate {
} -errors {
}

if {![acs_user::site_wide_admin_p]} {
    ad_return_complaint 1 "You have no permission to manage cvs users!"
}

acs_user::update -user_id $user_id \
	-username $cvs_user

ad_returnredirect match-cvs-users