# lib_party.R -- resolve majority-branded institutional feeds to a party.
#
# House committees put the minority on a prefixed host (democrats-<cmte>.house.gov)
# and leave the majority on the bare host, and the two swap content when control
# flips. So a release on waysandmeans.house.gov is Republican or Democratic
# depending only on WHO HELD THE CHAMBER ON ITS DATE -- never on who holds it
# today. This is the lookup the README's schema proposal defers to: without it
# ~44% of the collected institutional rows carry the placeholder "MAJ" and have
# no usable party at all.
#
# Congresses begin January 3 of the odd year. Party is the majority (for the
# Senate, the party organising the chamber, so a 50-50 split goes to the party
# holding the vice presidency).

.congress_control <- data.frame(
  congress = 106:119,
  start = as.Date(c("1999-01-03", "2001-01-03", "2003-01-03", "2005-01-03",
                    "2007-01-03", "2009-01-03", "2011-01-03", "2013-01-03",
                    "2015-01-03", "2017-01-03", "2019-01-03", "2021-01-03",
                    "2023-01-03", "2025-01-03")),
  end = as.Date(c("2001-01-02", "2003-01-02", "2005-01-02", "2007-01-02",
                  "2009-01-02", "2011-01-02", "2013-01-02", "2015-01-02",
                  "2017-01-02", "2019-01-02", "2021-01-02", "2023-01-02",
                  "2025-01-02", "2027-01-02")),
  house  = c("R", "R", "R", "R", "D", "D", "R", "R", "R", "R", "D", "D", "R", "R"),
  senate = c("R", "D", "R", "R", "D", "D", "D", "D", "R", "R", "R", "D", "D", "R"),
  stringsAsFactors = FALSE
)

# The 107th Senate changed hands twice mid-Congress, so a single label for it
# would misattribute either end. Overrides are applied after the table lookup.
# 2001-01-03..2001-06-05 R (50-50, Cheney breaking ties)
# 2001-06-06..2002-11-11 D (Jeffords leaves the GOP)
# 2002-11-12..2003-01-02 R (Missouri special election seats Talent)
.senate_overrides <- data.frame(
  start = as.Date(c("2001-01-03", "2001-06-06", "2002-11-12")),
  end   = as.Date(c("2001-06-05", "2002-11-11", "2003-01-02")),
  party = c("R", "D", "R"),
  stringsAsFactors = FALSE
)

# Majority party of `chamber` on each date. Vectorised; NA outside the table and
# for chambers with no single majority (joint bodies).
chamber_majority <- function(dates, chamber) {
  dates <- as.Date(dates)
  chamber <- tolower(as.character(chamber))
  if (length(chamber) == 1L) chamber <- rep(chamber, length(dates))
  out <- rep(NA_character_, length(dates))

  for (i in seq_len(nrow(.congress_control))) {
    r <- .congress_control[i, ]
    in_c <- !is.na(dates) & dates >= r$start & dates <= r$end
    out[in_c & chamber == "house"]  <- r$house
    out[in_c & chamber == "senate"] <- r$senate
  }
  for (i in seq_len(nrow(.senate_overrides))) {
    r <- .senate_overrides[i, ]
    hit <- !is.na(dates) & dates >= r$start & dates <= r$end & chamber == "senate"
    out[hit] <- r$party
  }
  out
}
