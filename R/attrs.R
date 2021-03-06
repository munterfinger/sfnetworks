attrs_from_sf = function(x) {
  list(sf_column = attr(x, "sf_column"), agr = attr(x, "agr"))
}

empty_agr = function(x, active = NULL) {
  if (is.null(active)) {
    active = attr(x, "active")
  }
  switch(
    active,
    nodes = empty_nodes_agr(x),
    edges = empty_edges_agr(x),
    stop("Unknown active element: ", active, ". Only nodes and edges supported")
  )
}

empty_nodes_agr = function(x) {
  attrs = get_node_attr_names(x)
  structure(rep(sf::NA_agr_, length(attrs)), names = attrs)
}

empty_edges_agr = function(x) {
  attrs = get_edge_attr_names(x)
  structure(rep(sf::NA_agr_, length(attrs)), names = attrs)
}

get_attr_names = function(x) {
  switch(
    attr(x, "active"),
    nodes = get_node_attr_names(x),
    edges = get_edge_attr_names(x)
  )
}

get_node_attr_names = function(x) {
  igraph::vertex_attr_names(x)[!sapply(igraph::vertex_attr(x), is.sfc)]
}

# Note:
# From and to are not really attributes, but still present in the agr specs.
get_edge_attr_names = function(x) {  
  c(
    "from", 
    "to", 
    igraph::edge_attr_names(x)[!sapply(igraph::edge_attr(x), is.sfc)]
  )
}

# Note:
# This is needed because an input edge data frame to the sfnetwork construction
# function can have the required from and to columns at any location. In the
# resulting network however they will always be the first two columns, so the
# order of the agr attribute might not match the column order anymore.
order_agr = function(x) {
  agr = sf_attr(x, "agr", "edges")
  ordered_agr = unlist(
    list(agr["from"], agr["to"], agr[setdiff(names(agr), c("from", "to"))])
  )
  sf_attr(x, "agr", "edges") = ordered_agr
  x
}

#' Query sf attributes from the active element of an sfnetwork object
#'
#' @param x An object of class \code{\link{sfnetwork}}.
#'
#' @param name Name of the attribute to query. If \code{NULL}, then all sf 
#' attributes are returned in a list. Defaults to \code{NULL}.
#'
#' @param active Which network element (i.e. nodes or edges) to activate before
#' extracting. If \code{NULL}, it will be set to the current active element of
#' the given network. Defaults to \code{NULL}.
#'
#' @param value The new value of the attribute, or \code{NULL} to remove the 
#' attribute.
#'
#' @return For the extractor: a list of attributes if \code{name} is \code{NULL},
#' otherwise the value of the attribute matched, or NULL if no exact match is 
#' found and no or more than one partial match is found.
#'
#' @details sf attributes include \code{sf_column} (the name of the sf column)
#' and \code{agr} (the attribute-geometry-relationships).
#'
#' @name sf_attr
#' @importFrom igraph edge_attr vertex_attr
#' @export
sf_attr = function(x, name = NULL, active = NULL) {
  if (is.null(active)) {
    active = attr(x, "active")
  }
  if (is.null(name)) {
    switch(
      active,
      nodes = attr(x, "sf")[["nodes"]],
      edges = attr(x, "sf")[["edges"]],
      stop("Unknown active element: ", active, ". Only nodes and edges supported")
    )
  } else {
    switch(
      active,
      nodes = attr(x, "sf")[["nodes"]][[name]],
      edges = attr(x, "sf")[["edges"]][[name]],
      stop("Unknown active element: ", active, ". Only nodes and edges supported")
    )
  }
}

#' @name sf_attr
#' @export
`sf_attr<-` = function(x, name, active = NULL, value) {
  if (is.null(active)) {
    active = attr(x, "active")
  }
  switch(
    active,
    nodes = set_node_sf_attr(x, name, value),
    edges = set_edge_sf_attr(x, name, value),
    stop("Unknown active element: ", active, ". Only nodes and edges supported")
  )
}

set_node_sf_attr = function(x, name, value) {
  attr(x, "sf")[["nodes"]][[name]] = value
  x
}

set_edge_sf_attr = function(x, name, value) {
  attr(x, "sf")[["edges"]][[name]] = value
  x
}