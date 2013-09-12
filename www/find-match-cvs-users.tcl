# 

ad_page_contract {
    
     Matchs a openacs.org user with a given cvs user.
     
     @author Victor Guerra (guerra@galileo.edu)
     @creation-date 2006-11-17
     @arch-tag: bb0f9ebe-7f89-4e2c-a40e-e0086ff80d70
     @cvs-id $Id$
 } {
     cvs_user:notnull
} -properties {
} -validate {
} -errors {
}

if {![acs_user::site_wide_admin_p]} {
    ad_return_complaint 1 "You have no permission to manage cvs users!"
}

set title "Searching user"
set context [list $title]
