# pressR

Automating the collection of U.S. House members' press releases.

`pressR` scrapes press releases from the ~440 U.S. House of
Representatives members' `*.house.gov` websites over a date range and returns a
tidy data frame. Instead of guessing among dozens of CSS/XPath selectors per
site, it **detects the content-management system** behind each site and routes
to a dedicated extractor.

## Why CMS detection

A survey of the chamber shows House sites cluster into a few vendor families:

| CMS | Share | How it's scraped |
|-----|------:|------------------|
| **Drupal** (official House template) | ~54% | `/media/press-releases` listing, `?page=N` pagination |
| **ASP.NET** ("DocumentID") | ~20% | `documentquery.aspx` listing, `documentsingle.aspx` items |
| **WordPress** | ~12% | `wp-json` REST API (`congress_press_release` category) |
| **Other** | ~14% | generic heuristic extractor (heading-link titles + nearest date) |

Three vendor extractors plus one generic fallback cover the whole chamber.
Pages are fetched statically by default; a headless-browser fallback
([`render_html()`], via the suggested **chromote** package) is available for the
rare JS-rendered site.

## Installation

```r
# install.packages("pak")
pak::pak("zaynesember/pressR")
```

## Usage

```r
library(pressR)

# Current members and their sites
members <- list_members()
#> # A tibble: 438 × 5
#>   name           state   district party url
#>   <chr>          <chr>   <chr>    <chr> <chr>
#> 1 Moore, Barry   Alabama 1st      R     https://barrymoore.house.gov
#> ...

# One member
moore <- scrape_member("barrymoore.house.gov", from = "2026-01-01")

# A set of members (metadata carried through)
res <- scrape_pressers(
  members[1:10, ],
  from = "2026-01-01",
  to   = Sys.Date(),
  log_fails = TRUE          # writes fails.csv
)

# The whole House (optionally capped for a quick sample)
all <- scrape_house(from = "2026-01-01", max_members = 50)
```

Every release-returning function yields columns `date`, `title`, `body`,
`tags`, `url`, `cms` (plus any member metadata). `scrape_pressers()` /
`scrape_house()` also attach a failures table:

```r
attr(res, "failures")   # tibble(url, stage, message)
```

## How it works

1. **`list_members()`** parses <https://www.house.gov/representatives>.
2. **`detect_cms()`** classifies a homepage via its `<meta generator>` tag and
   markup fingerprints.
3. The matching **extractor** finds the press-release listing, walks its pages
   newest-first until the window's start, and pulls each release's body.
4. **`scrape_member()`** ties these together for one site; **`scrape_pressers()`**
   runs many, isolating per-site failures.

## Politeness & configuration

Requests carry an identifying user agent and are throttled and retried via
[httr2](https://httr2.r-lib.org/). Tunable via options:

```r
options(pressR.throttle = 20)            # requests/minute (default 20)
options(pressR.cache_dir = "~/.cache/pressR")  # enable on-disk HTTP cache
```

## Development

```r
devtools::load_all()
devtools::test()     # offline unit tests run against saved HTML fixtures
devtools::check()
```

The original grad-school notebook implementation is preserved under
[`legacy/`](legacy/) for reference.

## License

MIT © Zayne Sember
