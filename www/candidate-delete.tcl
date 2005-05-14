ad_page_contract {
    @cvs-id $Id$
} {
    candidate_id:integer
    election_id:integer
} 

auth::require_login
permission::require_permission -object_id [ad_conn package_id] -privilege admin

db_dml candidate_delete {
    delete from oct_candidate 
    where candidate_id = :candidate_id
}

ad_returnredirect [export_vars -base "election" {election_id}]


