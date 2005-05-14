create table oct_election (
    election_id          serial 
                         primary key,
    start_time           timestamptz,
    end_time             timestamptz,
    vote_forum_cutoff    timestamptz,
    number_of_candidates integer,
    label                varchar(100)
);

create table oct_candidate (
    candidate_id         serial 
                         primary key,
    election             integer
                         references oct_election,
    label                varchar(50)
);

create table oct_vote (
    candidate_id         integer
                         references oct_candidate
);

create table oct_ballot (
    user_id              integer
                         references users,
    election_id          integer
                         references oct_election,
    primary key (user_id, election_id)
);


   
    