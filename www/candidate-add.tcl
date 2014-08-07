ad_page_contract {
    @cvs-id $Id$
} {
    election_id:naturalnum,notnull
    candidate
} 

auth::require_login
permission::require_permission -object_id [ad_conn package_id] -privilege create

db_dml candidate_add {
    insert into oct_candidate 
    (election, label)
    values (:election_id, :candidate)
}

ad_returnredirect [export_vars -base "election" {election_id}]


