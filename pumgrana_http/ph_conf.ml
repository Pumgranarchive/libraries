let pumgrana_api_uri = ref "http://127.0.0.1:8081/"

let content_uri = "content/"
let content_detail_uri = content_uri ^ "detail/"
let contents_uri = content_uri ^ "list/"
let search_contents_uri = content_uri ^ "search/"
let content_insert_uri = content_uri ^ "insert"
let content_delete_uri = content_uri ^ "delete"

let tag_uri = "tag/"
let search_tag_content_uri = tag_uri ^ "search/"
let tag_content_uri = tag_uri ^ "from_content/"

let linkedcontent_uri = "linkedcontent/"
let linkedcontent_detail_uri = linkedcontent_uri ^ "detail/"
let search_linkedcontent_content_uri = linkedcontent_uri ^ "search/"
let linkedcontent_content_uri = linkedcontent_uri ^ "from_content/"
let linkedcontent_content_tags_uri = linkedcontent_uri ^ "from_content_tags/"

let link_uri = "link/"
let link_insert_uri = link_uri ^ "insert"
let link_delete_uri = link_uri ^ "delete"

let max_request_list_size = 20
