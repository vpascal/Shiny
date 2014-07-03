load("a.RData")


all_values <- function(x) {
  if(is.null(x)) return(NULL)
  paste0(names(x), ": ", format(x), collapse = "<br />")
}

gender%>%
  ggvis(x=~Date,y=~value,stroke= ~variable) %>%
  layer_lines() %>%
  layer_points(stroke=~variable) %>%
	add_axis("x", title = "")%>%
	add_axis("y", title = "")%>%
  add_tooltip(function(gender) round((gender$value),digits=1),"hover")


data_age%>%
  ggvis(x=~Date,y=~value,stroke= ~variable) %>%
  layer_lines() %>%
  layer_points(stroke=~variable) %>%
  add_axis("x", title = "")%>%
  add_axis("y", title = "")%>%
  add_tooltip(all_values, "hover")

area%>%
  ggvis(x=~long,y=~lat, stroke := "white") %>%
  group_by(group) %>%
  layer_paths() %>%
  layer_paths(fill=~Key) %>%
  hide_axis("x")%>%
  hide_axis("y") %>%
  #layer_points() %>%
  add_tooltip(all_values, "hover") %>%
 set_options(width = 400, height = 500)

