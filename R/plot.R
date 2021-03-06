#' Plot sfnetwork object
#'
#' Plot the geometries of an object of class \code{\link{sfnetwork}}.
#'
#' @param x Object of class \code{\link{sfnetwork}}.
#'
#' @param draw_lines If the edges of the network are spatially implicit, should
#' straight lines be drawn between connected nodes? Defaults to \code{TRUE}.
#' Ignored when the edges of the network are spatially explicit.
#'
#' @param ... Arguments passed on to \code{\link[sf:plot]{plot.sf}}
#'
#' @details This is a basic plotting functionality. For more advanced plotting,
#' it is recommended to extract the nodes and edges from the network, and plot
#' them separately with one of the many available spatial plotting functions
#' as can be found in \code{sf}, \code{tmap}, \code{ggplot2}, \code{ggspatial},
#' and others.
#'
#' @importFrom graphics plot
#' @importFrom sf st_geometry
#' @export
plot.sfnetwork = function(x, draw_lines = TRUE, ...) {
  dots = list(...)
  # Get geometries of nodes.
  nsf = sf::st_geometry(activate(x, "nodes"))
  # Combine node geometries with edge geometries if needed.
  use_edges = TRUE
  if (! has_spatially_explicit_edges(x)) {
    if (draw_lines) {
      x = explicitize_edges(x)
    } else {
      use_edges = FALSE
    }
  }
  dots$x = if (use_edges) c(nsf, sf::st_geometry(activate(x, "edges"))) else nsf
  # Use pch of 20 by default.
  pch_missing = is.null(dots$pch)
  dots$pch = if (pch_missing) 20 else dots$pch
  # Plot.
  do.call(plot, dots)
}