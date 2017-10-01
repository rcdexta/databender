#!/bin/bash
set -e

#Utility function to fire queries opening a connection with database
function target_execute() {
   MYSQL_PWD='' mysql -uroot -h127.0.0.1 -P3306 magic_list_service_test_subset -e "$1"
}

function execute() {
   MYSQL_PWD='' mysql -uroot -h127.0.0.1 -P3306 -e "$1"
}

#Pull schema from source database
echo "Pulling schema from magic_list_service_test.."
MYSQL_PWD='' mysqldump -uroot -h127.0.0.1 -P3306 --no-data magic_list_service_test > /tmp/databender_schema.sql

#Drop & create destination database. Load source schema.
echo "Creating and loading schema to magic_list_service_test_subset.."
execute 'drop database if exists magic_list_service_test_subset;'
execute 'create database magic_list_service_test_subset;'
MYSQL_PWD='' mysql -uroot -h127.0.0.1 -P3306 magic_list_service_test_subset < /tmp/databender_schema.sql

echo ""
echo "Processing tables..."

## Process each table
echo "\033[36mcustomer_fingerprint:\033[0m \033[32mINSERT INTO customer_fingerprint SELECT * FROM magic_list_service_test.customer_fingerprint limit 1000\033[0m"
target_execute "INSERT INTO customer_fingerprint SELECT * FROM magic_list_service_test.customer_fingerprint limit 1000"
echo ""
echo ""
echo "\033[36mmagic_lists:\033[0m \033[32mINSERT INTO magic_lists SELECT * FROM magic_list_service_test.magic_lists limit 1000\033[0m"
target_execute "INSERT INTO magic_lists SELECT * FROM magic_list_service_test.magic_lists limit 1000"
echo ""
echo ""
echo "\033[36mquote_notes:\033[0m \033[32mINSERT INTO quote_notes SELECT * FROM magic_list_service_test.quote_notes limit 1000\033[0m"
target_execute "INSERT INTO quote_notes SELECT * FROM magic_list_service_test.quote_notes limit 1000"
echo ""
echo ""
echo "\033[36mquote_subcontractor_appointment_alerts:\033[0m \033[32mINSERT INTO quote_subcontractor_appointment_alerts SELECT * FROM magic_list_service_test.quote_subcontractor_appointment_alerts limit 1000\033[0m"
target_execute "INSERT INTO quote_subcontractor_appointment_alerts SELECT * FROM magic_list_service_test.quote_subcontractor_appointment_alerts limit 1000"
echo ""
echo ""
echo "\033[36mquote_version_download_history:\033[0m \033[32mINSERT INTO quote_version_download_history SELECT * FROM magic_list_service_test.quote_version_download_history limit 1000\033[0m"
target_execute "INSERT INTO quote_version_download_history SELECT * FROM magic_list_service_test.quote_version_download_history limit 1000"
echo ""
echo ""
echo "\033[36mquote_version_status_history:\033[0m \033[32mINSERT INTO quote_version_status_history SELECT * FROM magic_list_service_test.quote_version_status_history limit 1000\033[0m"
target_execute "INSERT INTO quote_version_status_history SELECT * FROM magic_list_service_test.quote_version_status_history limit 1000"
echo ""
echo ""
echo "\033[36mquotes:\033[0m \033[32mINSERT INTO quotes SELECT * FROM magic_list_service_test.quotes limit 1000\033[0m"
target_execute "INSERT INTO quotes SELECT * FROM magic_list_service_test.quotes limit 1000"
echo ""
echo ""
echo "\033[36mschema_version:\033[0m \033[32mINSERT INTO schema_version SELECT * FROM magic_list_service_test.schema_version limit 1000\033[0m"
target_execute "INSERT INTO schema_version SELECT * FROM magic_list_service_test.schema_version limit 1000"
echo ""
echo ""
echo "\033[36mquote_versions:\033[0m \033[32mINSERT INTO quote_versions SELECT * FROM magic_list_service_test.quote_versions WHERE quote_id in (select id from magic_list_service_test_subset.quotes)\033[0m"
target_execute "INSERT INTO quote_versions SELECT * FROM magic_list_service_test.quote_versions WHERE quote_id in (select id from magic_list_service_test_subset.quotes)"
echo ""
echo ""
echo "\033[36mmagic_list_items:\033[0m \033[32mINSERT INTO magic_list_items SELECT * FROM magic_list_service_test.magic_list_items WHERE magic_list_id in (select magic_list_id from magic_list_service_test_subset.magic_lists)\033[0m"
target_execute "INSERT INTO magic_list_items SELECT * FROM magic_list_service_test.magic_list_items WHERE magic_list_id in (select magic_list_id from magic_list_service_test_subset.magic_lists)"
echo ""
echo ""
echo "\033[36msubcontractor_dispatch_requests:\033[0m \033[32mINSERT INTO subcontractor_dispatch_requests SELECT * FROM magic_list_service_test.subcontractor_dispatch_requests WHERE quote_id in (select id from magic_list_service_test_subset.quotes)\033[0m"
target_execute "INSERT INTO subcontractor_dispatch_requests SELECT * FROM magic_list_service_test.subcontractor_dispatch_requests WHERE quote_id in (select id from magic_list_service_test_subset.quotes)"
echo ""
echo ""
echo "\033[36mquote_metadata:\033[0m \033[32mINSERT INTO quote_metadata SELECT * FROM magic_list_service_test.quote_metadata WHERE quote_id in (select id from magic_list_service_test_subset.quotes)\033[0m"
target_execute "INSERT INTO quote_metadata SELECT * FROM magic_list_service_test.quote_metadata WHERE quote_id in (select id from magic_list_service_test_subset.quotes)"
echo ""
echo ""
echo "\033[36mquote_change_requests:\033[0m \033[32mINSERT INTO quote_change_requests SELECT * FROM magic_list_service_test.quote_change_requests WHERE quote_version_id in (select id from magic_list_service_test_subset.quote_versions) and quote_id in (select id from magic_list_service_test_subset.quotes) and resolution_quote_version_id in (select id from magic_list_service_test_subset.quote_versions)\033[0m"
target_execute "INSERT INTO quote_change_requests SELECT * FROM magic_list_service_test.quote_change_requests WHERE quote_version_id in (select id from magic_list_service_test_subset.quote_versions) and quote_id in (select id from magic_list_service_test_subset.quotes) and resolution_quote_version_id in (select id from magic_list_service_test_subset.quote_versions)"
echo ""
echo ""
echo "\033[36mmagic_list_item_search_skus:\033[0m \033[32mINSERT INTO magic_list_item_search_skus SELECT * FROM magic_list_service_test.magic_list_item_search_skus WHERE magic_list_item_id in (select magic_list_item_id from magic_list_service_test_subset.magic_list_items)\033[0m"
target_execute "INSERT INTO magic_list_item_search_skus SELECT * FROM magic_list_service_test.magic_list_item_search_skus WHERE magic_list_item_id in (select magic_list_item_id from magic_list_service_test_subset.magic_list_items)"
echo ""
echo ""
echo "\033[36mquote_version_sections:\033[0m \033[32mINSERT INTO quote_version_sections SELECT * FROM magic_list_service_test.quote_version_sections WHERE quote_version_id in (select id from magic_list_service_test_subset.quote_versions) and magic_list_item_id in (select magic_list_item_id from magic_list_service_test_subset.magic_list_items)\033[0m"
target_execute "INSERT INTO quote_version_sections SELECT * FROM magic_list_service_test.quote_version_sections WHERE quote_version_id in (select id from magic_list_service_test_subset.quote_versions) and magic_list_item_id in (select magic_list_item_id from magic_list_service_test_subset.magic_list_items)"
echo ""
echo ""
echo "\033[36mmagic_list_item_human_recommendations:\033[0m \033[32mINSERT INTO magic_list_item_human_recommendations SELECT * FROM magic_list_service_test.magic_list_item_human_recommendations WHERE magic_list_item_id in (select magic_list_item_id from magic_list_service_test_subset.magic_list_items)\033[0m"
target_execute "INSERT INTO magic_list_item_human_recommendations SELECT * FROM magic_list_service_test.magic_list_item_human_recommendations WHERE magic_list_item_id in (select magic_list_item_id from magic_list_service_test_subset.magic_list_items)"
echo ""
echo ""
echo "\033[36msubcontractor_dispatch_responses:\033[0m \033[32mINSERT INTO subcontractor_dispatch_responses SELECT * FROM magic_list_service_test.subcontractor_dispatch_responses WHERE dispatch_request_id in (select id from magic_list_service_test_subset.subcontractor_dispatch_requests)\033[0m"
target_execute "INSERT INTO subcontractor_dispatch_responses SELECT * FROM magic_list_service_test.subcontractor_dispatch_responses WHERE dispatch_request_id in (select id from magic_list_service_test_subset.subcontractor_dispatch_requests)"
echo ""
echo ""
echo "\033[36mquote_version_line_items:\033[0m \033[32mINSERT INTO quote_version_line_items SELECT * FROM magic_list_service_test.quote_version_line_items WHERE quote_version_section_id in (select id from magic_list_service_test_subset.quote_version_sections)\033[0m"
target_execute "INSERT INTO quote_version_line_items SELECT * FROM magic_list_service_test.quote_version_line_items WHERE quote_version_section_id in (select id from magic_list_service_test_subset.quote_version_sections)"
echo ""
echo ""
echo "\033[36msubcontractor_dispatch_uploads:\033[0m \033[32mINSERT INTO subcontractor_dispatch_uploads SELECT * FROM magic_list_service_test.subcontractor_dispatch_uploads WHERE response_id in (select id from magic_list_service_test_subset.subcontractor_dispatch_responses)\033[0m"
target_execute "INSERT INTO subcontractor_dispatch_uploads SELECT * FROM magic_list_service_test.subcontractor_dispatch_uploads WHERE response_id in (select id from magic_list_service_test_subset.subcontractor_dispatch_responses)"
echo ""
echo ""

echo "Done.."

mkdir -p dumps

MYSQL_PWD='' mysqldump -uroot -h127.0.0.1 -P3306 magic_list_service_test_subset | gzip > dumps/magic_list_service_test.sql.gz

echo "The dump of db_subset is available at dumps/magic_list_service_test.sql.gz. Use gunzip to extract followed by mysql command to load"

execute 'drop database magic_list_service_test_subset;'