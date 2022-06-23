# Check if need to install rvest` library
require(rvest)

url <- "https://en.wikipedia.org/wiki/List_of_bicycle-sharing_systems"


#making GET request andparse website into xml document
root_node <- read_html(url)


table_nodes <- html_elements(root_node, "head")

