-- 
-- 
-- 
-- @author Victor Guerra (guerra@galileo.edu)
-- @creation-date 2006-10-03
-- @arch-tag: 56805ca6-5f68-4ef7-883f-9026e46fcfa1
-- @cvs-id $Id$
--

alter table oct_election add column cvs_history_days integer;
update oct_election set cvs_history_days = 0;
