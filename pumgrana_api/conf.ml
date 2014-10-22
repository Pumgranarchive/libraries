let pumgrana_api_uri = ref "http://127.0.0.1:8081/api/"

let content_uri = "content/"
let content_detail_uri = content_uri ^ "detail/"
let contents_uri = content_uri ^ "list_content/"
let content_insert_uri = content_uri ^ "insert"
let content_update_uri = content_uri ^ "update"
let content_update_tags_uri = content_uri ^ "update_tags"
let content_delete_uri = content_uri ^ "delete"

let tag_uri = "tag/"
let tag_type_uri = tag_uri ^ "list_by_type/"
let tag_content_uri = tag_uri ^ "list_from_content/"
let tag_content_links_uri = tag_uri ^ "list_from_content_links/"
let tag_insert_uri = tag_uri ^ "insert"
let tag_delete_uri = tag_uri ^ "delete"

let link_uri = "link/"
let link_detail_uri = link_uri ^ "detail/"
let link_content_uri = link_uri ^ "from_content/"
let link_content_tags_uri = link_uri ^ "from_content_tags/"
let link_insert_uri = link_uri ^ "insert"
let link_update_uri = link_uri ^ "update"
let link_delete_uri = link_uri ^ "delete"

let max_request_list_size = 100
