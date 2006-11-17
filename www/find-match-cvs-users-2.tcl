# 

ad_page_contract {
    
    
    
    @author Victor Guerra (guerra@galileo.edu)
    @creation-date 2006-11-17
    @arch-tag: e71ac791-82c4-4e2d-9bc6-9d773c882bd3
    @cvs-id $Id$
} {
    search_text
    cvs_user:notnull
} -properties {
} -validate {
} -errors {
}

if {![acs_user::site_wide_admin_p]} {
    ad_return_complaint 1 "You have no permission to manage cvs users!"
}

set search_text [string trim $search_text]
set title "Searching user"
set context [list $title]

db_multirow users select_users {
    select pe.person_id,
    pe.first_names,
    pe.last_name,
    pa.email,
    us.username
    from persons pe, parties pa, users us
    where pe.person_id = pa.party_id 
    and pe.person_id = us.user_id
    and (lower(last_name) like lower('%' || :search_text || '%')
    or lower(first_names) like lower('%' || :search_text || '%')
    or lower(email) like lower('%' || :search_text || '%'))
} {
}

ad_return_template
