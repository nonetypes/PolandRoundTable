#------- By Organization ------#

#' Find the degree measures for a set of organizations over a time period
#'
#' @param orgs A character vector of organization IDs.
#' @param start A start of date range, in DD-MM-YYYY string format.  Defaults to beginning of dates in data.
#' @param end An end of date range, in DD-MM-YYYY string format. Defaults to end of dates in data.
#'
#' @return A tibble with pairs of organizations and their number of shared members in that range.
#'
#' @import dplyr
#' @import lubridate
#' @export
get_degree_orgs <- function(orgs, start = NULL, end = NULL, timesteps = "months") {

  if (is.null(start)) {
    start <- min(affiliation_dates$Start.Date)
  }

  if (is.null(end)) {
    end <- max(affiliation_dates$Start.Date)
  }

  start <- lubridate::ymd(start)
  end <- lubridate::ymd(end)
  range <- lubridate::interval(start, end)

  if (timesteps == "months") {

    n_steps <- range %/% months(1) - 1
    starts <- start + months(0:n_steps)
    ends <- starts + months(1)

  } else if (timesteps == "days") {

    n_steps <- range %/% days(1) - 1
    starts <- start + days(0:n_steps)
    ends <- starts + days(1)

  } else if (timesteps == "years") {

    n_steps <- range %/% years(1) - 1
    starts <- start + years(0:n_steps)
    ends <- starts + years(1)
  }

  res <- purrr::map2_dfr(starts, ends,
              ~get_one_degree_orgs(orgs,
                                    start = .x,
                                    end = .y))

  res$Start.Date = starts
  res$End.Date = ends


  res <- res %>%
    tidyr::pivot_longer(all_of(orgs),
                        names_to = "Org.ID",
                        values_to = "degree") %>%
    filter(!(is.na(degree)))

  return(res)

}

#' Find the degree measures for a set of organizations over a time period
#'
#' @param ... A set of organization IDs.
#' @param start A start of date range, in DD-MM-YYYY string format.  Defaults to beginning of dates in data.
#' @param end An end of date range, in DD-MM-YYYY string format. Defaults to end of dates in data.
#'
#' @return A tibble with pairs of organizations and their number of shared members in that range.
#' @import dplyr
#' @export
get_one_degree_orgs <- function(orgs, start = NULL, end = NULL) {

  if (is.null(start)) {
    start <- min(affiliation_dates$Start.Date)
  }

  if (is.null(end)) {
    end <- max(affiliation_dates$Start.Date)
  }


  start <- lubridate::ymd(start)
  end <- lubridate::ymd(end)

  edgelist <- get_edgelist_orgs(start, end)

  if (is.null(edgelist)) {
    res <- rep(NA, length(orgs))
    names(res) <- orgs
    return(res)
  }


  graph <- igraph::graph_from_data_frame(edgelist, directed = FALSE)

  res <- purrr::map_dbl(orgs,
                 ~degree_checked(graph, edgelist, .x))

  names(res) <- orgs

  return(res)

}

#------- By Individual ------#

#' Find the degree measures for a set of individuals over a time period
#'
#' @param members A character vector of member IDs.
#' @param start A start of date range, in DD-MM-YYYY string format.  Defaults to beginning of dates in data.
#' @param end An end of date range, in DD-MM-YYYY string format. Defaults to end of dates in data.
#'
#' @return A tibble with pairs of organizations and their number of shared members in that range.
#'
#' @import dplyr
#' @import lubridate
#' @export
get_degree_members <- function(members, start = NULL, end = NULL, timesteps = "months") {

  if (is.null(start)) {
    start <- min(affiliation_dates$Start.Date)
  }

  if (is.null(end)) {
    end <- max(affiliation_dates$Start.Date)
  }

  start <- lubridate::ymd(start)
  end <- lubridate::ymd(end)
  range <- lubridate::interval(start, end)

  if (timesteps == "months") {

    n_steps <- range %/% months(1) - 1
    starts <- start + months(0:n_steps)
    ends <- starts + months(1)

  } else if (timesteps == "days") {

    n_steps <- range %/% days(1) - 1
    starts <- start + days(0:n_steps)
    ends <- starts + days(1)

  } else if (timesteps == "years") {

    n_steps <- range %/% years(1) - 1
    starts <- start + years(0:n_steps)
    ends <- starts + years(1)
  }

  res <- purrr::map2_dfr(starts, ends,
                         ~get_one_degree_members(members,
                                                   start = .x,
                                                   end = .y))

  res$Start.Date = starts
  res$End.Date = ends


  res <- res %>%
    tidyr::pivot_longer(all_of(members),
                        names_to = "Member.ID",
                        values_to = "degree") %>%
    filter(!(is.na(degree)))

  return(res)

}

#' Find the degree measures for a set of organizations over a time period
#'
#' @param members A vector of member IDs.
#' @param start A start of date range, in DD-MM-YYYY string format.  Defaults to beginning of dates in data.
#' @param end An end of date range, in DD-MM-YYYY string format. Defaults to end of dates in data.
#'
#' @return A tibble with pairs of organizations and their number of shared members in that range.
#' @import dplyr
#' @export
get_one_degree_members <- function(members, start = NULL, end = NULL) {

  if (is.null(start)) {
    start <- min(affiliation_dates$Start.Date)
  }

  if (is.null(end)) {
    end <- max(affiliation_dates$Start.Date)
  }


  start <- lubridate::ymd(start)
  end <- lubridate::ymd(end)

  edgelist <- get_edgelist_members(start, end)

  if (is.null(edgelist)) {
    res <- rep(NA, length(members))
    names(res) <- members
    return(res)
  }

  graph <- igraph::graph_from_data_frame(edgelist, directed = FALSE)

  res <- purrr::map_dbl(members,
                        ~degree_checked(graph, edgelist, .x))

  names(res) <- members

  return(res)

}




#------- Helpers -------#

#' Calculates degree but first checks if vertex is valid
#'
#' @param graph An igraph object
#' @param edgelist A tibble of edges
#' @param vertex The vertex to calculate degree of
#'
#' @return A double
#'
degree_checked <- function(graph, edgelist, vertex) {

  if (vertex %in% c(edgelist$from, edgelist$to)) {

    igraph::degree(graph, vertex)

  } else {

    NA

  }

}
