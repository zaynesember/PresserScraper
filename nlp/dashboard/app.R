# pressR dashboard - precompute-then-serve over the DuckDB store.
# Loads the small precomputed aggregates (dashboard.rds) at startup; queries the
# ~894k `releases` table live ONLY for the Explore tab, drill-downs, and CSV
# downloads (short-lived read_only connections). Corpus = scraped pressR archive
# (2010-2026) + folded external datasets (Stout 114-117, Wang & Tucker 109-115).
suppressMessages({
  library(shiny); library(bslib); library(DT); library(plotly)
  library(ggplot2); library(dplyr); library(DBI); library(duckdb); library(visNetwork)
})

NLP  <- file.path(dirname(tools::R_user_dir("pressR", "data")), "pressR_nlp")
DB   <- file.path(NLP, "press.duckdb")
dash <- readRDS(file.path(NLP, "dashboard", "dashboard.rds"))
ov   <- dash$overview
PARTY_COL <- c(D = "#2166ac", R = "#b2182b")
SOURCE_LABEL <- c(scraped = "Scraped (pressR)", stout = "Stout 114-117",
                  wangtucker = "Wang & Tucker 109-115")

# Presidential terms (for background shading on the negativity-flip chart).
# xmin/xmax bracket each term in continuous year coordinates.
PREZ_TERMS <- data.frame(
  president = c("Obama", "Trump", "Biden", "Trump"),
  party     = c("D", "R", "D", "R"),
  xmin      = c(2009.5, 2016.5, 2020.5, 2024.5),
  xmax      = c(2016.5, 2020.5, 2024.5, 2025.5),
  stringsAsFactors = FALSE)
# readable labels for the entity_stance entity ids
ENT_LABEL <- c(trump = "Trump (pres)", biden = "Biden (pres)", obama = "Obama (pres)",
  bush = "Bush (pres)", democrats = "Democrats (party)", republicans = "Republicans (party)",
  pelosi = "Pelosi (leader)", schumer = "Schumer (leader)", mcconnell = "McConnell (leader)",
  mccarthy = "McCarthy (leader)", ice = "ICE (agency)", fbi = "FBI (agency)",
  cdc = "CDC (agency)", irs = "IRS (agency)", cfpb = "CFPB (agency)",
  iran = "Iran", russia = "Russia", china = "China")
ent_lab <- function(x) ifelse(x %in% names(ENT_LABEL), ENT_LABEL[x], tools::toTitleCase(x))

# short-lived read_only query (never holds the connection open)
qd <- function(sql, params = NULL) {
  con <- dbConnect(duckdb::duckdb(), DB, read_only = TRUE)
  on.exit(dbDisconnect(con, shutdown = TRUE))
  if (is.null(params)) dbGetQuery(con, sql) else dbGetQuery(con, sql, params = params)
}
fmt <- function(x) format(x, big.mark = ",")
HAS_SENT <- tryCatch({ qd("SELECT 1 FROM sentiment LIMIT 1"); TRUE }, error = function(e) FALSE)
NETW <- dash$network

# node colors for the member network, by the chosen scheme
net_node_color <- function(nd, by) {
  if (by == "party")
    return(ifelse(nd$party == "D", "#2166ac", ifelse(nd$party == "R", "#b2182b", "#777777")))
  if (by == "ideology") {
    nm <- nd$nominate; out <- rep("#cccccc", length(nm)); ok <- !is.na(nm)
    if (any(ok)) {
      sc <- pmin(pmax((nm[ok] + 1) / 2, 0), 1)               # NOMINATE ~[-1,1] -> [0,1]
      cr <- grDevices::colorRamp(c("#2166ac", "#dddddd", "#b2182b"))(sc)
      out[ok] <- grDevices::rgb(cr[, 1], cr[, 2], cr[, 3], maxColorValue = 255)
    }
    return(out)
  }
  pal <- grDevices::hcl.colors(max(nd$community, na.rm = TRUE), "Dark 3")
  pal[nd$community]
}

theme_pr <- function() theme_minimal(base_size = 13) +
  theme(legend.position = "top", panel.grid.minor = element_blank())

# ---- verified citations for the Data & Methods tab --------------------------
CITES <- list(
  list(t = "Scraped corpus (pressR)", w = "Both-chamber CMS-detecting scraper built for this project; one archive per office, 2010-2026.",
       c = "pressR (this project). On-disk archive of 436,201 House + Senate press releases, 2010-2026.", u = NULL),
  list(t = "Stout dataset (114th-117th)", w = "288k House press releases (2015-2023). Folded in with attribution; cited as source lineage (no standalone dataset DOI).",
       c = "Garcia, J. R., Stout, C. T., & Tate, K. (2025). Black Voices in the Halls of Power: Race and Rhetorical Representation in Congress. Cambridge Studies in American Legislatures. Cambridge University Press.",
       u = "https://doi.org/10.1017/9781009681469"),
  list(t = "Wang & Tucker dataset (109th-115th)", w = "169k House + Senate press releases (2004-2019). Folded in with attribution.",
       c = "Wang, R. T., & Tucker, P. D. (2020). How Partisanship Influences What Congress Says Online and How They Say It. American Politics Research, 49(1), 76-90.",
       u = "https://doi.org/10.1177/1532673X20939498"),
  list(t = "Text processing (quanteda)", w = "Tokenization, document-feature matrices, tf-idf.",
       c = "Benoit, K., Watanabe, K., Wang, H., Nulty, P., Obeng, A., Muller, S., & Matsuo, A. (2018). quanteda: An R package for the quantitative analysis of textual data. Journal of Open Source Software, 3(30), 774.",
       u = "https://doi.org/10.21105/joss.00774"),
  list(t = "Coordinated-message detection (MinHash + LSH)", w = "Near-duplicate bodies found via MinHash/banded LSH over 5-gram shingles, then connected components -> family_id.",
       c = "Broder, A. Z. (1997). On the resemblance and containment of documents. Compression and Complexity of SEQUENCES 1997, 21-29.",
       u = "https://doi.org/10.1109/SEQUEN.1997.666900"),
  list(t = "Text-reuse implementation (textreuse)", w = "MinHash generator, LSH candidate buckets, Jaccard comparison.",
       c = "Mullen, L. (2016). textreuse: Detect Text Reuse and Document Similarity. R package.",
       u = "https://docs.ropensci.org/textreuse/"),
  list(t = "Graph components (igraph)", w = "Union of near-dup edges -> connected components = message families.",
       c = "Csardi, G., & Nepusz, T. (2006). The igraph software package for complex network research. InterJournal, Complex Systems, 1695.",
       u = "https://igraph.org"),
  list(t = "Coordination network (communities + ideology)", w = "Members linked by shared message families; Louvain communities, weighted-betweenness brokerage, ideological homophily vs DW-NOMINATE. Built with igraph, rendered with visNetwork.",
       c = "Blondel, V. D., Guillaume, J.-L., Lambiotte, R., & Lefebvre, E. (2008). Fast unfolding of communities in large networks. J. Stat. Mech., P10008. Ideology: Voteview (Lewis, Poole, Rosenthal, Boche, Rudkin & Sonnet).",
       u = "https://voteview.com/"),
  list(t = "Readability / complexity (quanteda.textstats)", w = "Per release: Flesch reading ease, Flesch-Kincaid grade, Gunning Fog, words/sentence, syllables/word.",
       c = "quanteda.textstats (Benoit et al. 2018), implementing the Flesch-Kincaid, Gunning Fog, and Flesch reading-ease formulas.",
       u = "https://CRAN.R-project.org/package=quanteda.textstats"),
  list(t = "Issue-tag completion (glmnet)", w = "Per-issue one-vs-rest ridge logistic regression on tf-idf, group-aware splits by family_id; test macro-F1 ~0.78.",
       c = "Friedman, J. H., Hastie, T., & Tibshirani, R. (2010). Regularization Paths for Generalized Linear Models via Coordinate Descent. Journal of Statistical Software, 33(1), 1-22.",
       u = "https://doi.org/10.18637/jss.v033.i01"),
  list(t = "Topic discovery (STM)", w = "Structural Topic Model, prevalence ~ party + chamber + s(year), fit on a family-deduped stratified sample.",
       c = "Roberts, M. E., Stewart, B. M., & Tingley, D. (2019). stm: An R Package for Structural Topic Models. Journal of Statistical Software, 91(2), 1-40.",
       u = "https://doi.org/10.18637/jss.v091.i02"),
  list(t = "Sentiment (sentimentr)", w = "Sentence-level polarity with valence shifters (negators/amplifiers). WEAK on congressional/promotional prose - read with caveats.",
       c = "Rinker, T. W. (2021). sentimentr: Calculate Text Polarity Sentiment. R package version 2.9.0. CRAN.",
       u = "https://CRAN.R-project.org/package=sentimentr"),
  list(t = "Targeted tone (directed sentiment)", w = "Sentence-level sentimentr scored only on sentences that NAME a target (date-keyed presidents, parties, leaders, agencies, China); out-party attack = negativity aimed at the other party. De-leaked by family; validated on a sample.",
       c = "Method (this project): sentence-window sentimentr (Rinker 2021) over a versioned entity gazetteer; cf. aspect-based sentiment analysis.",
       u = NULL),
  list(t = "Partisan language (weighted log-odds)", w = "D-vs-R distinctive words, z-scored with an informative Dirichlet prior, computed WITHIN issues to separate framing from agenda; de-leaked by message family. Implemented with the tidylo package (Silge, Hayes & Schnoebelen).",
       c = "Monroe, B. L., Colaresi, M. P., & Quinn, K. M. (2008). Fightin' Words: Lexical Feature Selection and Evaluation for Identifying the Content of Political Conflict. Political Analysis, 16(4), 372-403.",
       u = "https://doi.org/10.1093/pan/mpn018"),
  list(t = "Columnar store (DuckDB)", w = "In-process analytical database backing the corpus + precomputed layers.",
       c = "Raasveldt, M., & Muhleisen, H. (2019). DuckDB: an Embeddable Analytical Database. SIGMOD '19, 1981-1984.",
       u = "https://doi.org/10.1145/3299869.3320212")
)

ui <- page_navbar(
  title = "pressR · Congressional Press Releases",
  theme = bs_theme(version = 5, bootswatch = "cosmo", primary = "#2c3e50"),
  nav_panel(
    "Overview", icon = icon("chart-line"),
    layout_columns(
      fill = FALSE,
      value_box("Releases", fmt(ov$n_total), showcase = icon("file-lines"),
                p(sprintf("%s-%s · %s%% with body text", substr(ov$dmin,1,4), substr(ov$dmax,1,4), ov$pct_body))),
      value_box("Issue-labeled", paste0(ov$pct_labeled, "%"), theme = "info",
                showcase = icon("tags"), p(sprintf("%s%% office-tagged, rest model-assigned", ov$pct_office_tagged))),
      value_box("Reuse text", paste0(ov$pct_reused, "%"), theme = "warning",
                showcase = icon("copy"), p(sprintf("%s reused families", fmt(ov$n_reused_fam)))),
      value_box("Cross-party messages", fmt(ov$n_xparty), theme = "secondary",
                showcase = icon("handshake"), p(sprintf("%s cross-chamber", fmt(ov$n_xchamber))))
    ),
    layout_columns(
      card(card_header("Top issues across the corpus"), plotlyOutput("ov_issues", height = 420)),
      card(card_header("Corpus sources"), DTOutput("ov_sources"),
           div(class = "small text-muted px-2 pb-2",
               "Scraped + two folded external datasets. See Data & Methods for attribution.")),
      col_widths = c(7, 5)
    )
  ),
  nav_panel(
    "Issue Trends", icon = icon("arrow-trend-up"),
    layout_sidebar(
      sidebar = sidebar(
        selectizeInput("it_issues", "Issues", choices = dash$issues,
                       selected = c("Health Care","Economy & Jobs","Immigration & Border","Environment & Climate"),
                       multiple = TRUE),
        radioButtons("it_chamber", "Chamber", c("Both","House","Senate"), inline = TRUE),
        radioButtons("it_src", "Labels", c("Office + model-assigned" = "all", "Office-tagged only" = "office")),
        downloadButton("dl_trends", "Download trend data (CSV)", class = "btn-sm btn-outline-primary"),
        helpText("Share = % of a party's labeled releases that year touching the issue. ",
                 "2010 (sparse) and 2026 (partial) are caveated endpoints.")
      ),
      plotlyOutput("it_plot", height = 560)
    )
  ),
  nav_panel(
    "Topics (STM)", icon = icon("layer-group"),
    layout_columns(
      card(card_header("Discovered topics - click a row"), DTOutput("tp_table")),
      card(card_header(textOutput("tp_title")),
           plotlyOutput("tp_plot", height = 300), uiOutput("tp_examples")),
      col_widths = c(6, 6)
    )
  ),
  nav_panel(
    "Tone", icon = icon("face-smile"),
    layout_sidebar(
      sidebar = sidebar(
        radioButtons("sent_unit", "View",
          c("Over time" = "time", "By issue" = "issue", "Issue divergence" = "divergence")),
        helpText(tags$b("Caveat:"), " off-the-shelf sentiment (sentimentr) is a weak, ",
                 "noisy measure on congressional / promotional prose: most releases skew ",
                 "mildly positive. Read differences as suggestive, not definitive; compare ",
                 "WITHIN an issue where possible.")
      ),
      uiOutput("tone_body")
    )
  ),
  nav_panel(
    "Targeted Tone", icon = icon("crosshairs"),
    layout_sidebar(
      sidebar = sidebar(
        radioButtons("at_view", "View",
          c("Out-party attack" = "attack", "Tone toward entity" = "entity")),
        conditionalPanel("input.at_view == 'entity'",
          selectInput("at_entity", "Entity", choices = NULL)),
        helpText(tags$b("Directed tone."), " sentimentr scored only on sentences that ",
          "NAME a target (presidents, parties, leaders, agencies, China). ",
          tags$b("Out-party attack"), " = negativity aimed at the other party's president, ",
          "party, or leaders. De-leaked by message family; validated on a 2019 sample. ",
          "Residual co-mention noise averages out — suggestive, not definitive."),
        textOutput("at_caption")
      ),
      uiOutput("at_body")
    )
  ),
  nav_panel(
    "Power & Status", icon = icon("chess"),
    layout_sidebar(
      fillable = FALSE,
      sidebar = sidebar(
        width = 330,
        radioButtons("ps_view", "Finding",
          c("Negativity flips with the White House" = "neg",
            "Who owns each issue (& flips)"          = "own")),
        conditionalPanel("input.ps_view == 'neg'",
          radioButtons("ps_neg_sub", "Panel",
            c("Out-party attack by year" = "share",
              "Polarized perception (by entity)" = "stance",
              "Most-attacked entities" = "attacked"))),
        conditionalPanel("input.ps_view == 'own'",
          radioButtons("ps_own_sub", "Panel",
            c("Issue ownership (overall)" = "rank",
              "Attention over time" = "attn",
              "Ownership flips over time" = "flip")),
          conditionalPanel("input.ps_own_sub == 'attn'",
            selectizeInput("ps_attn_iss", "Issues", choices = NULL, multiple = TRUE)),
          conditionalPanel("input.ps_own_sub == 'flip'",
            selectInput("ps_flip_iss", "Issue", choices = NULL))),
        helpText(tags$b("One thesis:"), " a lot of what looks like a fixed party ",
          "trait — meanness, issue ownership — is really a ", tags$b("status / context"),
          " variable: it tracks who holds power. Negativity is opposition behavior; ",
          "issue ownership shifts with the White House."),
        textOutput("ps_caption")
      ),
      uiOutput("ps_body")
    )
  ),
  nav_panel(
    "Partisan Language", icon = icon("comments"),
    layout_sidebar(
      sidebar = sidebar(
        selectInput("pl_scope", "Scope", choices = NULL),
        helpText(tags$b("Words each party uses more"), " — Monroe et al. (2008) ",
                 "weighted log-odds. ", tags$b("Within an issue"), " these reflect ",
                 "framing / rhetoric; ", tags$b("(overall)"), " mixes framing with ",
                 "agenda (which party raises a topic at all). De-leaked by message ",
                 "family. Residual proper nouns / place names are byline noise."),
        textOutput("pl_caption")
      ),
      card(card_header("Distinctive words — Republican (left) vs Democratic (right)"),
           plotlyOutput("pl_plot", height = 620))
    )
  ),
  nav_panel(
    "Readability", icon = icon("book-open-reader"),
    layout_sidebar(
      sidebar = sidebar(
        selectInput("rd_metric", "Measure", c(
          "Flesch-Kincaid grade (higher = harder)" = "fk_grade",
          "Gunning Fog index (higher = harder)"    = "fog",
          "Flesch reading ease (higher = easier)"  = "flesch",
          "Words per sentence"                     = "sent_len",
          "Syllables per word"                     = "syll")),
        helpText("Readability / sentence complexity of release bodies (quanteda.textstats). ",
          "Congressional prose is dense — typically a college-to-graduate reading level."),
        textOutput("rd_caption")
      ),
      layout_columns(
        card(card_header("Over time, by party"), plotlyOutput("rd_trend", height = 400)),
        card(card_header("By issue (top 18 by volume)"), plotlyOutput("rd_issue", height = 400)),
        col_widths = c(7, 5)
      )
    )
  ),
  nav_panel(
    "Coordinated Messaging", icon = icon("share-nodes"),
    layout_sidebar(
      sidebar = sidebar(
        checkboxInput("cm_xparty", "Cross-party only", FALSE),
        checkboxInput("cm_xchamber", "Cross-chamber only", FALSE),
        checkboxInput("cm_hide_xsrc", "Hide cross-collection (mechanical) dupes", FALSE),
        sliderInput("cm_min", "Min members", 2, 45, 3),
        downloadButton("dl_families", "Download families (CSV)", class = "btn-sm btn-outline-primary"),
        helpText("Families of releases sharing the same / near-same body. ",
                 "Cross-collection families appear in more than one source dataset ",
                 "(the same release captured twice) - usually mechanical, not coordination.")
      ),
      layout_columns(
        card(card_header("Message families - click a row"), DTOutput("cm_table")),
        card(card_header(textOutput("cm_title")), uiOutput("cm_detail")),
        col_widths = c(7, 5)
      )
    )
  ),
  nav_panel(
    "Member Network", icon = icon("circle-nodes"),
    layout_sidebar(
      fillable = FALSE,   # tab stacks graph (520px) + two plot rows -> let it scroll, not squeeze
      sidebar = sidebar(
        radioButtons("net_color", "Color nodes by",
          c("Party" = "party", "Community" = "community", "Ideology (DW-NOMINATE)" = "ideology")),
        sliderInput("net_minw", "Min tie strength",
          min = floor((NETW$w_min %||% 0) * 100) / 100, max = round(NETW$w_max %||% 1, 2),
          value = NETW$w_default %||% 0, step = 0.05),
        checkboxInput("net_crossonly", "Cross-party ties only", FALSE),
        helpText("Members are linked when they share a near-duplicate message family ",
          "(joint statements, sign-on letters, reused talking points), de-leaked; ",
          "scraped corpus 2010-26. Tie strength down-weights mass sign-ons; node size = ",
          "betweenness. Click a node to highlight its ties."),
        textOutput("net_caption")
      ),
      card(visNetworkOutput("net", height = "520px")),
      layout_columns(
        card(card_header("Top cross-party brokers"), DTOutput("net_brokers")),
        card(card_header("Bipartisan coordination over time"),
             plotlyOutput("net_ts", height = 300),
             div(class = "small text-muted px-2", textOutput("net_xpchamber"))),
        col_widths = c(5, 7)
      ),
      card(card_header("Which issues draw cross-party coordination (% of coordinating families that are cross-party)"),
           plotlyOutput("net_xpissue", height = 380))
    )
  ),
  nav_panel(
    "Explore", icon = icon("magnifying-glass"),
    layout_sidebar(
      sidebar = sidebar(
        textInput("ex_q", "Search title/body"),
        selectizeInput("ex_member", "Member", choices = NULL, multiple = TRUE),
        selectizeInput("ex_issue", "Issue", choices = dash$issues, multiple = TRUE),
        radioButtons("ex_chamber", "Chamber", c("Both","House","Senate"), inline = TRUE),
        radioButtons("ex_party", "Party", c("Both","D","R"), inline = TRUE),
        selectInput("ex_source", "Source", c("All", SOURCE_LABEL)),
        sliderInput("ex_years", "Years", min(dash$years), max(dash$years),
                    c(min(dash$years), max(dash$years)), sep = ""),
        actionButton("ex_go", "Search", class = "btn-primary"),
        downloadButton("dl_explore", "Download results (CSV)", class = "btn-sm btn-outline-primary mt-2")
      ),
      layout_columns(
        card(card_header("Results (max 500)"), DTOutput("ex_table")),
        card(card_header(textOutput("ex_title")), uiOutput("ex_body")),
        col_widths = c(7, 5)
      )
    )
  ),
  nav_panel(
    "Data & Methods", icon = icon("book"),
    div(class = "container-fluid", style = "max-width:1000px",
      h3("Corpus & sources"),
      p("A corpus of U.S. congressional press releases assembled from several sources and merged ",
        "into one DuckDB store with a ", tags$code("source"), " provenance column. Releases are ",
        "scraped per member office, de-duplicated by URL, written as year-partitioned xz files, and ",
        "loaded into DuckDB for columnar querying. Member metadata (name, state, district, party, ",
        "chamber, committee) is carried throughout; issue tags are kept as each office filed them."),
      DTOutput("dm_sources"),
      p(class = "small text-muted mt-2",
        "The scraper detects each office's content-management system (Drupal, ASP.NET, WordPress ",
        "REST, headless-WordPress GraphQL, or a generic fallback) and routes to a dedicated ",
        "extractor. The two external datasets and the Internet-Archive backfill of former members ",
        "are mapped to the same schema; their raw files are not redistributed."),
      h3("Analysis pipeline", class = "mt-4"),
      tags$ol(class = "small",
        tags$li(tags$b("Message families"), " — near-duplicate bodies (MinHash/LSH over 5-gram ",
          "shingles, Jaccard >= 0.7) grouped via connected components into coordination families; ",
          "the de-leak primitive every other layer reuses."),
        tags$li(tags$b("Issue labels"), " — office-filed tags canonicalized to 31 issues via a ",
          "versioned crosswalk; the rest model-assigned by per-issue ridge classifiers on sublinear ",
          "tf-idf, with group-aware splits by family (test macro-F1 0.79)."),
        tags$li(tags$b("Topics"), " — a 40-topic structural topic model (prevalence ~ party + chamber ",
          "+ s(year)) on a family-deduped, year-stratified sample."),
        tags$li(tags$b("Sentiment & targeted tone"), " — document-level sentiment, plus directed tone ",
          "toward named targets (an out-party attack score), scored on mention sentences only."),
        tags$li(tags$b("Partisan language"), " — Monroe weighted log-odds for D-vs-R distinctive ",
          "words, overall and conditioned within each issue."),
        tags$li(tags$b("Coordination network & readability"), " — the member co-messaging graph ",
          "(communities, brokers, ideological homophily) and classic readability / complexity ",
          "measures.")),
      h3("Methods & citations", class = "mt-4"),
      p(class = "text-muted small",
        "Each layer is precomputed and served from DuckDB. Citations verified against publisher / ",
        "DOI / CRAN pages."),
      uiOutput("dm_methods"),
      h3("Caveats", class = "mt-4"),
      tags$ul(class = "small",
        tags$li(tags$b("MNAR issue tags:"), " tag availability is missing-not-at-random by CMS — ",
          "some offices never tag — so model-assigned labels on never-tagged offices are ",
          "extrapolation, not validated against ground truth there."),
        tags$li(tags$b("Cross-source duplicates:"), " folded datasets overlap the scraped corpus in ",
          "time, so a release can appear in more than one collection; these are flagged ",
          tags$code("cross_source"), " and de-leaked by family."),
        tags$li(tags$b("Sentiment is weak on promotional prose:"), " off-the-shelf sentiment skews ",
          "mildly positive — read the gap and the trend, not absolute values."),
        tags$li(tags$b("Coverage skew:"), " pre-2015 under-represents short-serving members; the ",
          "Internet-Archive backfill of former members is closing this gap."),
        tags$li(tags$b("Other:"), " within-year proportions; 2004 and 2026 are partial endpoints; ",
          "some folded member names are derived and join imperfectly across sources."))
    )
  ),
  nav_spacer(),
  nav_item(tags$span(class = "navbar-text small", sprintf("DuckDB · built %s", substr(dash$built_at,1,16))))
)

server <- function(input, output, session) {
  updateSelectizeInput(session, "ex_member", choices = dash$members$name, server = TRUE)

  ## Overview: top issues bar + source table
  output$ov_issues <- renderPlotly({
    tot <- dash$issue_trends_all |> group_by(issue) |>
      summarise(n = sum(n_issue), .groups = "drop") |> slice_max(n, n = 15)
    p <- ggplot(tot, aes(reorder(issue, n), n)) +
      geom_col(fill = "#2c3e50") + coord_flip() +
      labs(x = NULL, y = "releases (issue mentions)") + theme_pr()
    ggplotly(p, tooltip = c("y"))
  })
  output$ov_sources <- renderDT({
    d <- dash$sources |> transmute(
      source = SOURCE_LABEL[source], releases = n, usable,
      years = paste(substr(dmin,1,4), substr(dmax,1,4), sep = "-"),
      `%body` = pct_body, `%tagged` = pct_tagged)
    datatable(d, rownames = FALSE, options = list(dom = "t", pageLength = 5))
  })

  ## Issue Trends
  itrend <- reactive({
    d <- if (input$it_src == "office") dash$issue_trends_office else dash$issue_trends_all
    req(length(input$it_issues) > 0)
    d <- d[d$issue %in% input$it_issues, ]
    if (input$it_chamber != "Both") d <- d[d$chamber == tolower(input$it_chamber), ]
    d |> group_by(year, party, issue) |>
      summarise(share = sum(n_issue) / sum(n_rel), .groups = "drop")
  })
  output$it_plot <- renderPlotly({
    d <- itrend(); validate(need(nrow(d) > 0, "Pick at least one issue."))
    p <- ggplot(d, aes(year, share, color = party,
                       group = party, text = sprintf("%s %d\n%s: %.1f%%", party, year, issue, 100*share))) +
      geom_line(linewidth = 0.9) + geom_point(size = 1) +
      facet_wrap(~issue, scales = "free_y") +
      scale_color_manual(values = PARTY_COL) +
      scale_y_continuous(labels = scales::percent) +
      labs(x = NULL, y = "share of party's labeled releases", color = NULL) + theme_pr()
    ggplotly(p, tooltip = "text")
  })
  output$dl_trends <- downloadHandler(
    filename = function() "pressR_issue_trends.csv",
    content = function(file) write.csv(dash$issue_trends_all, file, row.names = FALSE))

  ## Topics
  output$tp_table <- renderDT({
    datatable(dash$topic_dict |> transmute(topic, prevalence = round(prevalence, 3),
                top_terms = substr(frex, 1, 60)),
              selection = "single", rownames = FALSE,
              options = list(pageLength = 12, order = list(list(1, "desc"))))
  })
  tp_sel <- reactive({ s <- input$tp_table_rows_selected; if (length(s)) dash$topic_dict$topic[s] else dash$topic_dict$topic[1] })
  output$tp_title <- renderText(sprintf("Topic %d over time", tp_sel()))
  output$tp_plot <- renderPlotly({
    d <- dash$topic_trends |> filter(topic == tp_sel(), party %in% c("D","R"))
    p <- ggplot(d, aes(year, mean_prev, color = party, group = party)) +
      geom_line(linewidth = 0.9) + scale_color_manual(values = PARTY_COL) +
      labs(x = NULL, y = "mean topic proportion", color = NULL) + theme_pr()
    ggplotly(p)
  })
  output$tp_examples <- renderUI({
    row <- dash$topic_dict |> filter(topic == tp_sel())
    ex <- if (!is.null(row$examples)) strsplit(row$examples, " \\| ")[[1]] else character(0)
    tagList(tags$b("FREX terms: "), row$frex, tags$hr(),
            tags$b("Example releases:"),
            tags$ul(lapply(ex, function(u) tags$li(tags$a(href = u, target = "_blank", u)))))
  })

  ## Tone (sentiment)
  output$tone_body <- renderUI({
    if (is.null(dash$sentiment_trends))
      return(div(class = "alert alert-warning",
                 "Sentiment layer not present in this build (run sentiment + persist, then prep)."))
    if (input$sent_unit == "time")
      tagList(card(card_header("Mean release sentiment over time, by party"),
                   plotlyOutput("tone_trend", height = 460)),
              card(card_header("Mean sentiment by source"), DTOutput("tone_src")))
    else if (input$sent_unit == "issue")
      card(card_header("Mean sentiment by issue (D vs R)"),
           plotlyOutput("tone_issue", height = 640))
    else
      tagList(
        card(card_header("Issue-specific D-R divergence (2010-13 -> 2021-24, baseline-adjusted)"),
             plotlyOutput("tone_divergence", height = 600)),
        div(class = "small text-muted px-2",
          "Bars = change in the issue's D-R sentiment gap after removing each year's overall ",
          "D-R drift (which itself tracks who holds the White House). Blue = pulled toward ",
          "Democratic-warmer tone; red = toward Republican-warmer. Directional only (sentimentr is noisy)."))
  })
  output$tone_trend <- renderPlotly({
    d <- dash$sentiment_trends |> filter(party %in% c("D","R"))
    p <- ggplot(d, aes(year, mean_sent, color = party, group = party,
                       text = sprintf("%s %d: %.3f (n=%s)", party, year, mean_sent, format(n, big.mark=",")))) +
      geom_hline(yintercept = 0, color = "grey70") +
      geom_line(linewidth = 0.9) + geom_point(size = 1) +
      scale_color_manual(values = PARTY_COL) +
      labs(x = NULL, y = "mean sentiment (sentimentr)", color = NULL) + theme_pr()
    ggplotly(p, tooltip = "text")
  })
  output$tone_issue <- renderPlotly({
    d <- dash$sentiment_by_issue |> filter(party %in% c("D","R"))
    ord <- d |> group_by(issue) |> summarise(m = mean(mean_sent), .groups="drop") |> arrange(m)
    d$issue <- factor(d$issue, levels = ord$issue)
    p <- ggplot(d, aes(mean_sent, issue, color = party,
                       text = sprintf("%s - %s: %.3f (n=%s)", issue, party, mean_sent, format(n, big.mark=",")))) +
      geom_vline(xintercept = 0, color = "grey70") +
      geom_point(size = 2.4) +
      scale_color_manual(values = PARTY_COL) +
      labs(x = "mean sentiment", y = NULL, color = NULL) + theme_pr()
    ggplotly(p, tooltip = "text")
  })
  output$tone_src <- renderDT({
    datatable(dash$sentiment_sources |> transmute(source = SOURCE_LABEL[source],
                mean = mean_sent, median = med_sent, n),
              rownames = FALSE, options = list(dom = "t"))
  })
  output$tone_divergence <- renderPlotly({
    req(dash$sentiment_divergence)
    d <- dash$sentiment_divergence$by_issue
    d$dir <- ifelse(d$change >= 0, "D", "R")
    d$issue <- factor(d$issue, levels = d$issue[order(d$change)])
    p <- ggplot(d, aes(change, issue, fill = dir,
        text = sprintf("%s\nchange %+.3f (excess D-R gap %.3f -> %.3f)", issue, change, early, late))) +
      geom_col() + geom_vline(xintercept = 0, color = "grey60") +
      scale_fill_manual(values = c(D = unname(PARTY_COL["D"]), R = unname(PARTY_COL["R"])), guide = "none") +
      labs(x = "<- more Republican-warmer   change in D-R gap   more Democratic-warmer ->", y = NULL) +
      theme_pr()
    ggplotly(p, tooltip = "text")
  })

  ## Partisan language (Monroe weighted log-odds)
  if (!is.null(dash$partisan_scopes)) {
    scs <- dash$partisan_scopes$scope
    updateSelectInput(session, "pl_scope",
                      choices = c("(overall)", sort(setdiff(scs, "(overall)"))),
                      selected = "(overall)")
  }
  output$pl_caption <- renderText({
    req(input$pl_scope, !is.null(dash$partisan_scopes))
    s <- dash$partisan_scopes[dash$partisan_scopes$scope == input$pl_scope, ]
    if (!nrow(s)) return("")
    sprintf("%s by %s Democratic and %s Republican releases (de-leaked).",
            if (input$pl_scope == "(overall)") "Released" else "On this issue, released",
            format(s$n_d_docs, big.mark = ","), format(s$n_r_docs, big.mark = ","))
  })
  output$pl_plot <- renderPlotly({
    validate(need(!is.null(dash$partisan_terms),
                  "Partisan layer not in this build (run nlp/run_partisan.R then prep)."))
    req(input$pl_scope)
    d <- dash$partisan_terms |> filter(scope == input$pl_scope) |>
      group_by(lean) |> slice_max(abs(z), n = 18) |> ungroup()
    validate(need(nrow(d) > 0, "No terms for this scope."))
    d$word <- factor(d$word, levels = d$word[order(d$z)])
    p <- ggplot(d, aes(z, word, fill = lean,
          text = sprintf("%s\nz = %.1f   (D uses %s, R uses %s)", word, z,
                         format(n_d, big.mark = ","), format(n_r, big.mark = ",")))) +
      geom_col() + geom_vline(xintercept = 0, color = "grey60") +
      scale_fill_manual(values = c(D = unname(PARTY_COL["D"]), R = unname(PARTY_COL["R"]))) +
      labs(x = "<- more Republican      weighted log-odds (z)      more Democratic ->",
           y = NULL, fill = NULL) + theme_pr()
    ggplotly(p, tooltip = "text")
  })

  ## Coordinated messaging
  cm_data <- reactive({
    d <- dash$fam_top |> filter(n_members >= input$cm_min)
    if (input$cm_xparty)     d <- d |> filter(cross_party)
    if (input$cm_xchamber)   d <- d |> filter(cross_chamber)
    if (input$cm_hide_xsrc)  d <- d |> filter(!cross_source)
    d
  })
  output$cm_table <- renderDT({
    datatable(cm_data() |> transmute(members = n_members, copies = n_docs, parties,
                sources, xsrc = cross_source, span_days, message = substr(rep_title, 1, 60)),
              selection = "single", rownames = FALSE,
              options = list(pageLength = 12, order = list(list(0, "desc"))))
  })
  cm_fam <- reactive({ s <- input$cm_table_rows_selected; req(length(s)); cm_data()$family_id[s] })
  output$cm_title <- renderText({ req(input$cm_table_rows_selected); "Who shared this message" })
  output$cm_detail <- renderUI({
    req(input$cm_table_rows_selected)
    fid <- cm_fam()
    d <- qd("SELECT r.name, r.party, r.chamber, r.source, r.date, r.title, r.url
             FROM release_family rf JOIN releases r USING(url)
             WHERE rf.family_id = ? ORDER BY r.date", params = list(fid))
    body <- qd("SELECT body FROM release_family rf JOIN releases r USING(url)
                WHERE rf.family_id = ? AND r.body IS NOT NULL LIMIT 1", params = list(fid))$body
    tagList(
      tags$p(tags$b(sprintf("%d releases by %d members across %d source(s)",
                            nrow(d), length(unique(d$name)), length(unique(d$source))))),
      tags$table(class = "table table-sm",
        tags$thead(tags$tr(tags$th("Member"), tags$th("Party"), tags$th("Source"), tags$th("Date"))),
        tags$tbody(lapply(seq_len(nrow(d)), function(i)
          tags$tr(tags$td(tags$a(href = d$url[i], target="_blank", d$name[i])),
                  tags$td(d$party[i]), tags$td(SOURCE_LABEL[d$source[i]]),
                  tags$td(as.character(d$date[i])))))),
      tags$hr(), tags$b("Shared text (excerpt):"),
      tags$div(style = "max-height:240px;overflow:auto;font-size:0.85em;white-space:pre-wrap",
               substr(body %||% "(none)", 1, 1500)))
  })
  output$dl_families <- downloadHandler(
    filename = function() "pressR_message_families.csv",
    content = function(file) write.csv(cm_data(), file, row.names = FALSE))

  ## Readability / sentence complexity
  RD_LAB <- c(fk_grade = "Flesch-Kincaid grade", fog = "Gunning Fog index",
              flesch = "Flesch reading ease", sent_len = "words per sentence",
              syll = "syllables per word")
  output$rd_caption <- renderText({
    req(dash$readability); s <- dash$readability$by_source
    sprintf("By source — %s", paste(sprintf("%s FK %.1f", SOURCE_LABEL[s$source], s$fk_grade), collapse = " · "))
  })
  output$rd_trend <- renderPlotly({
    req(dash$readability); m <- input$rd_metric
    d <- dash$readability$by_party_year |> filter(party %in% c("D","R"))
    d$val <- d[[m]]
    p <- ggplot(d, aes(year, val, color = party, group = party,
        text = sprintf("%s %d: %.2f (n=%s)", party, year, val, format(n, big.mark = ",")))) +
      geom_line(linewidth = 0.9) + geom_point(size = 1) +
      scale_color_manual(values = PARTY_COL) +
      labs(x = NULL, y = unname(RD_LAB[m]), color = NULL) + theme_pr()
    ggplotly(p, tooltip = "text")
  })
  output$rd_issue <- renderPlotly({
    req(dash$readability); m <- input$rd_metric
    d <- dash$readability$by_issue; d$val <- d[[m]]
    d <- d |> slice_max(n, n = 18) |> arrange(val)
    d$issue <- factor(d$issue, levels = d$issue)
    p <- ggplot(d, aes(val, issue, text = sprintf("%s: %.2f (n=%s)", issue, val, format(n, big.mark = ",")))) +
      geom_col(fill = "#2c3e50") + labs(x = unname(RD_LAB[m]), y = NULL) + theme_pr()
    ggplotly(p, tooltip = "text")
  })

  ## Targeted tone (directed attack / entity stance)
  if (!is.null(dash$attack))
    updateSelectInput(session, "at_entity", choices = dash$attack$entities,
      selected = if ("trump" %in% dash$attack$entities) "trump" else dash$attack$entities[1])
  output$at_caption <- renderText({
    req(dash$attack); s <- dash$attack$summary
    sprintf("Mean out-party attack: D %.3f vs R %.3f (higher = more hostile).",
      s$mean_attack[s$party == "D"], s$mean_attack[s$party == "R"])
  })
  output$at_body <- renderUI({
    if (is.null(dash$attack))
      return(div(class = "alert alert-warning",
        "Targeted-tone layer not in this build (run nlp/run_attack.R, then prep)."))
    if (input$at_view == "attack")
      tagList(
        card(card_header("Out-party attack over time, by speaker party"),
             plotlyOutput("at_trend", height = 420)),
        card(card_header("Most hostile toward the out-party (de-leaked, >=40 targeted releases)"),
             DTOutput("at_brokers")))
    else
      card(card_header(textOutput("at_etitle")), plotlyOutput("at_entity_plot", height = 460))
  })
  output$at_trend <- renderPlotly({
    d <- dash$attack$by_party_year |> filter(party %in% c("D","R"))
    p <- ggplot(d, aes(year, mean_attack, color = party, group = party,
        text = sprintf("%s %d: %.3f (n=%s)", party, year, mean_attack, format(n, big.mark = ",")))) +
      geom_hline(yintercept = 0, color = "grey70") +
      geom_line(linewidth = 0.9) + geom_point(size = 1) +
      scale_color_manual(values = PARTY_COL) +
      labs(x = NULL, y = "mean out-party attack", color = NULL) + theme_pr()
    ggplotly(p, tooltip = "text")
  })
  output$at_brokers <- renderDT({
    datatable(dash$attack$brokers |>
      transmute(member = name, party, `attack score` = mean_attack, `targeted releases` = n),
      rownames = FALSE, options = list(pageLength = 10, dom = "tp"))
  })
  output$at_etitle <- renderText(sprintf("Tone toward '%s' by speaker party", input$at_entity))
  output$at_entity_plot <- renderPlotly({
    req(input$at_entity)
    d <- dash$attack$entity_ts |> filter(entity_id == input$at_entity, sp_party %in% c("D","R"))
    validate(need(nrow(d) > 0, "No data for this entity."))
    p <- ggplot(d, aes(year, mean, color = sp_party, group = sp_party,
        text = sprintf("%s speakers, %d: %.3f (n=%s)", sp_party, year, mean, format(n, big.mark = ",")))) +
      geom_hline(yintercept = 0, color = "grey70") +
      geom_line(linewidth = 0.9) + geom_point(size = 1) +
      scale_color_manual(values = PARTY_COL) +
      labs(x = NULL, y = "mean sentiment toward entity", color = "speaker") + theme_pr()
    ggplotly(p, tooltip = "text")
  })

  ## Power & Status (negativity flips + issue ownership) ----------------------
  if (!is.null(dash$power)) {
    updateSelectizeInput(session, "ps_attn_iss", choices = dash$power$attn_issues,
      selected = c("Economy & Jobs", "Health Care", "Immigration & Border",
                   "Defense & National Security"))
    fl <- dash$power$flip_issues
    updateSelectInput(session, "ps_flip_iss", choices = fl,
      selected = if ("Immigration & Border" %in% fl) "Immigration & Border" else fl[1])
  }

  output$ps_caption <- renderText({
    req(dash$power)
    if (input$ps_view == "neg") {
      c <- dash$power$attack_controlled
      if (is.null(c)) return("")
      sprintf("Controlled: out-party-targeting releases %.1f%% net-negative vs in-party %.1f%% — yet the raw D-vs-R net-negativity gap is tiny (%.1f%% vs %.1f%%). Opposition status, not party, drives negativity.",
              100 * c$outparty_netneg, 100 * c$inparty_netneg,
              100 * c$d_netneg_out, 100 * c$r_netneg_out)
    } else {
      sprintf("Ownership ranking is robust to label source (MNAR): all-labels vs office-tagged-only Spearman rho = %.2f.",
              dash$power$ownership_spearman)
    }
  })

  output$ps_body <- renderUI({
    if (is.null(dash$power))
      return(div(class = "alert alert-warning",
        "Power & Status layer not in this build (needs attack_scores + issue_labels; re-run prep_dashboard.R)."))
    if (input$ps_view == "neg") {
      if (input$ps_neg_sub == "share")
        card(card_header("Attacking the out-party is opposition behavior — and it flips with the White House"),
             plotlyOutput("ps_neg_share", height = 540),
             div(class = "small text-muted px-2 pb-2",
               "Share of each party's scored releases that name and direct sentiment at an out-party ",
               "figure (president, party, leaders), by year. Shaded bands = presidential term. ",
               "The Democratic and Republican lines cross at each transition."))
      else if (input$ps_neg_sub == "stance")
        card(card_header("The same politician is praised by allies and attacked by rivals"),
             plotlyOutput("ps_neg_stance", height = 560),
             div(class = "small text-muted px-2 pb-2",
               "Directed sentiment toward each named figure, split by the SPEAKER's party ",
               "(>= 200 targeted mentions). Negative = attacking. Presidents and the parties ",
               "themselves split hard by who's speaking — polarized perception, not a fixed valence."))
      else
        card(card_header("Most-attacked entities overall (lowest mean directed sentiment)"),
             plotlyOutput("ps_neg_attacked", height = 520),
             div(class = "small text-muted px-2 pb-2",
               "Pooled across both parties. Agencies (ICE), foreign adversaries (Iran, Russia), ",
               "and the sitting out-party president sit at the hostile end."))
    } else {
      if (input$ps_own_sub == "rank")
        card(card_header("Who owns each issue? Partisan skew in press-release attention"),
             plotlyOutput("ps_own_rank", height = 720),
             div(class = "small text-muted px-2 pb-2",
               tags$b("log2 ratio"), " of Republican-vs-Democratic attention rate per issue, ",
               "normalized for each party's total output. Right = Republican-owned, left = ",
               "Democrat-owned. ", tags$b("Caveat:"), " issue tags are missing-not-at-random by ",
               "office (label_source office vs predicted), but the ownership RANKING is robust ",
               "(office-only Spearman shown in the sidebar)."))
      else if (input$ps_own_sub == "attn")
        card(card_header("What Congress talks about over time (dominant-issue share)"),
             plotlyOutput("ps_own_attn", height = 540),
             div(class = "small text-muted px-2 pb-2",
               "Share of releases whose dominant (top) issue is each line, 2010-2025. ",
               "Economy & Jobs falls from ~28% (2010) to ~20% (2025); Health Care spikes in 2020 (COVID)."))
      else
        tagList(
          card(card_header(textOutput("ps_flip_title")),
               plotlyOutput("ps_own_flip", height = 460),
               div(class = "small text-muted px-2 pb-2",
                 "Republican share of the issue's combined D+R attention, by year. Above 0.5 = ",
                 "Republican-owned that year; below = Democrat-owned. Immigration & Border flips ",
                 "from Democrat-leaning (2017-2019) to Republican-owned (~0.58 in 2022, ~0.66 in 2024).")))
    }
  })

  output$ps_neg_share <- renderPlotly({
    req(dash$power)
    d <- dash$power$attack_outparty_year
    d$party_lab <- ifelse(d$party == "D", "Democrats", "Republicans")
    bands <- PREZ_TERMS[PREZ_TERMS$xmax <= max(d$year) + 0.5, ]
    p <- ggplot(d, aes(year, share_outparty)) +
      geom_rect(data = bands, inherit.aes = FALSE,
        aes(xmin = xmin, xmax = xmax, ymin = -Inf, ymax = Inf, fill = party),
        alpha = 0.12) +
      geom_line(aes(color = party, group = party,
        text = sprintf("%s %d: %.0f%% (%s of %s scored releases)", party_lab, year,
                       100 * share_outparty, format(n_outparty, big.mark = ","),
                       format(n_scored, big.mark = ","))), linewidth = 1) +
      geom_point(aes(color = party), size = 1.6) +
      scale_color_manual(values = PARTY_COL, labels = c(D = "Democrats", R = "Republicans"), name = NULL) +
      scale_fill_manual(values = PARTY_COL, guide = "none") +
      scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
      scale_x_continuous(breaks = seq(2010, 2024, 2)) +
      labs(x = NULL, y = "releases naming an out-party target") + theme_pr()
    ggplotly(p, tooltip = "text")
  })

  output$ps_neg_stance <- renderPlotly({
    req(dash$power)
    d <- dash$power$entity_stance_party
    # keep entities with both parties present; order by within-party spread
    both <- d |> group_by(entity_id) |> filter(n_distinct(sp_party) == 2) |> ungroup()
    spread <- both |> group_by(entity_id) |>
      summarise(rng = max(mean_sent) - min(mean_sent), .groups = "drop") |>
      slice_max(rng, n = 14)
    both <- both |> filter(entity_id %in% spread$entity_id)
    both$lab <- factor(ent_lab(both$entity_id),
      levels = ent_lab(spread$entity_id[order(spread$rng)]))
    p <- ggplot(both, aes(mean_sent, lab, color = sp_party, group = lab,
        text = sprintf("%s — %s speakers: %.3f (n=%s)", ent_lab(entity_id), sp_party,
                       mean_sent, format(n, big.mark = ",")))) +
      geom_line(aes(group = lab), color = "grey70", linewidth = 0.6) +
      geom_vline(xintercept = 0, color = "grey60") +
      geom_point(size = 2.6) +
      scale_color_manual(values = PARTY_COL, labels = c(D = "Democratic speakers", R = "Republican speakers"), name = NULL) +
      labs(x = "directed sentiment  (negative = attacking)", y = NULL) + theme_pr()
    ggplotly(p, tooltip = "text")
  })

  output$ps_neg_attacked <- renderPlotly({
    req(dash$power)
    d <- dash$power$entity_most_attacked
    d$lab <- factor(ent_lab(d$entity_id), levels = ent_lab(d$entity_id[order(-d$mean_sent)]))
    p <- ggplot(d, aes(mean_sent, lab, fill = mean_sent,
        text = sprintf("%s: %.3f (n=%s)", ent_lab(entity_id), mean_sent, format(n, big.mark = ",")))) +
      geom_col() + geom_vline(xintercept = 0, color = "grey60") +
      scale_fill_gradient(low = "#b2182b", high = "#f4a582", guide = "none") +
      labs(x = "mean directed sentiment (lower = more attacked)", y = NULL) + theme_pr()
    ggplotly(p, tooltip = "text")
  })

  output$ps_own_rank <- renderPlotly({
    req(dash$power)
    d <- dash$power$issue_ownership
    d$lean <- ifelse(d$log2_RD >= 0, "R", "D")
    d$issue <- factor(d$issue, levels = d$issue[order(d$log2_RD)])
    p <- ggplot(d, aes(log2_RD, issue, fill = lean,
        text = sprintf("%s\nlog2(R/D) = %+.2f  (%.1fx %s-owned, n=%s)", issue, log2_RD,
                       ifelse(log2_RD >= 0, ratio, 1 / ratio),
                       ifelse(log2_RD >= 0, "R", "D"), format(n_total, big.mark = ",")))) +
      geom_col() + geom_vline(xintercept = 0, color = "grey60") +
      scale_fill_manual(values = c(D = unname(PARTY_COL["D"]), R = unname(PARTY_COL["R"])), guide = "none") +
      labs(x = "<- Democrat-owned    log2(R / D attention rate)    Republican-owned ->",
           y = NULL) + theme_pr()
    ggplotly(p, tooltip = "text")
  })

  output$ps_own_attn <- renderPlotly({
    req(dash$power, length(input$ps_attn_iss) > 0)
    d <- dash$power$issue_attention_year |> filter(issue %in% input$ps_attn_iss)
    validate(need(nrow(d) > 0, "Pick at least one issue."))
    p <- ggplot(d, aes(year, share, color = issue, group = issue,
        text = sprintf("%s %d: %.1f%% (n=%s)", issue, year, 100 * share, format(n, big.mark = ",")))) +
      geom_line(linewidth = 0.9) + geom_point(size = 1) +
      scale_y_continuous(labels = scales::percent) +
      scale_x_continuous(breaks = seq(2010, 2024, 2)) +
      labs(x = NULL, y = "share of releases (dominant issue)", color = NULL) + theme_pr()
    ggplotly(p, tooltip = "text")
  })

  output$ps_flip_title <- renderText(sprintf("'%s' ownership over time", input$ps_flip_iss))
  output$ps_own_flip <- renderPlotly({
    req(dash$power, input$ps_flip_iss)
    d <- dash$power$issue_ownership_year |> filter(issue == input$ps_flip_iss)
    validate(need(nrow(d) > 0, "No data for this issue."))
    bands <- PREZ_TERMS[PREZ_TERMS$xmax <= max(d$year) + 0.5, ]
    p <- ggplot(d, aes(year, r_share)) +
      geom_rect(data = bands, inherit.aes = FALSE,
        aes(xmin = xmin, xmax = xmax, ymin = -Inf, ymax = Inf, fill = party), alpha = 0.12) +
      geom_hline(yintercept = 0.5, color = "grey50", linetype = "dashed") +
      geom_line(aes(group = 1,
        text = sprintf("%d: R share %.0f%% (log2 R/D %+.2f, n=%s)", year, 100 * r_share,
                       log2_RD, format(n, big.mark = ","))),
        color = "#6a51a3", linewidth = 1) +
      geom_point(color = "#6a51a3", size = 1.6) +
      scale_fill_manual(values = PARTY_COL, guide = "none") +
      scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
      scale_x_continuous(breaks = seq(2010, 2024, 2)) +
      labs(x = NULL, y = "Republican share of the issue's attention") + theme_pr()
    ggplotly(p, tooltip = "text")
  })

  ## Member network
  output$net_caption <- renderText({
    req(NETW); s <- NETW$summary
    sprintf("%s members · %s ties · %s communities. Modularity %.2f; party homophily %.2f; ideological homophily %.2f; %.0f%% of ties cross party.",
      s$n_nodes, format(s$n_edges, big.mark = ","), s$n_communities,
      s$modularity, s$assort_party, s$assort_nominate, s$pct_edges_crossparty)
  })
  output$net <- renderVisNetwork({
    req(NETW)
    e <- NETW$edges[NETW$edges$weight >= input$net_minw, , drop = FALSE]
    if (isTRUE(input$net_crossonly)) e <- e[e$cross_party, , drop = FALSE]
    validate(need(nrow(e) > 0, "No ties at this strength."))
    ids <- unique(c(e$a, e$b))
    nd <- NETW$nodes[NETW$nodes$name %in% ids, , drop = FALSE]
    vn <- data.frame(id = nd$name, label = nd$name, value = nd$betweenness + 1,
      title = sprintf("<b>%s</b> (%s, %s)<br>community %s<br>cross-party share %.0f%%<br>DW-NOMINATE %s",
        nd$name, nd$party, nd$chamber, nd$community, 100 * nd$cross_party_share,
        ifelse(is.na(nd$nominate), "n/a", sprintf("%.2f", nd$nominate))),
      color = net_node_color(nd, input$net_color), stringsAsFactors = FALSE)
    ve <- data.frame(from = e$a, to = e$b, value = e$weight,
      color = ifelse(e$cross_party, "rgba(70,70,70,0.55)", "rgba(180,180,180,0.30)"),
      stringsAsFactors = FALSE)
    visNetwork(vn, ve) |>
      visIgraphLayout(layout = "layout_with_fr", smooth = FALSE) |>
      visNodes(scaling = list(min = 8, max = 40)) |>
      visEdges(scaling = list(min = 0.5, max = 6)) |>
      visOptions(highlightNearest = list(enabled = TRUE, degree = 1, hover = TRUE),
                 nodesIdSelection = TRUE) |>
      visPhysics(enabled = FALSE)
  })
  output$net_brokers <- renderDT({
    req(NETW)
    datatable(NETW$brokers |>
      transmute(member = name, party, chamber, betweenness,
                `xparty wt` = cross_party_strength, `xparty %` = round(100 * cross_party_share),
                NOMINATE = round(nominate, 2)),
      rownames = FALSE, options = list(pageLength = 8, dom = "tp"))
  })
  output$net_ts <- renderPlotly({
    req(NETW)
    d <- NETW$ts
    p <- ggplot(d, aes(yr, xparty_share,
        text = sprintf("%d: %.0f%% cross-party (%d of %d coordinating families)",
                       yr, 100 * xparty_share, n_xparty, n_coord))) +
      geom_line(color = "#6a51a3", linewidth = 0.8) +
      geom_point(aes(size = n_coord), color = "#6a51a3") +
      scale_y_continuous(labels = scales::percent) +
      scale_size_area(max_size = 7, guide = "none") +
      labs(x = NULL, y = "cross-party share of coordinating families") + theme_pr()
    ggplotly(p, tooltip = "text")
  })
  output$net_xpchamber <- renderText({
    req(NETW$xparty_chamber)
    paste0("Cross-party rate by chamber scope — ",
      paste(sprintf("%s %.0f%%", NETW$xparty_chamber$scope, NETW$xparty_chamber$xparty_rate), collapse = " · "),
      ". Point size = coordinating families that year; early years are small-n and noisy.")
  })
  output$net_xpissue <- renderPlotly({
    req(NETW$xparty_issue)
    d <- NETW$xparty_issue
    d$issue <- factor(d$issue, levels = d$issue[order(d$xparty_rate)])
    p <- ggplot(d, aes(xparty_rate, issue, fill = xparty_rate,
        text = sprintf("%s: %.0f%% cross-party (%d of %d coordinating families)",
                       issue, xparty_rate, n_xparty, n_coord))) +
      geom_col() + scale_fill_gradient(low = "#cccccc", high = "#1a9850", guide = "none") +
      labs(x = "% of coordinating families that are cross-party", y = NULL) + theme_pr()
    ggplotly(p, tooltip = "text")
  })

  ## Explore (live query)
  ex_query <- reactive({
    where <- c("r.usable"); params <- list()
    if (nzchar(input$ex_q)) { where <- c(where, "(r.title ILIKE ? OR r.body ILIKE ?)")
      params <- c(params, paste0("%", input$ex_q, "%"), paste0("%", input$ex_q, "%")) }
    if (input$ex_chamber != "Both") { where <- c(where, "r.chamber = ?"); params <- c(params, tolower(input$ex_chamber)) }
    if (input$ex_party != "Both")   { where <- c(where, "r.party = ?"); params <- c(params, input$ex_party) }
    if (input$ex_source != "All")   { where <- c(where, "r.source = ?")
      params <- c(params, names(SOURCE_LABEL)[match(input$ex_source, SOURCE_LABEL)]) }
    where <- c(where, "r.year BETWEEN ? AND ?"); params <- c(params, input$ex_years[1], input$ex_years[2])
    if (length(input$ex_member)) { where <- c(where, sprintf("r.name IN (%s)", paste(rep("?", length(input$ex_member)), collapse=","))); params <- c(params, as.list(input$ex_member)) }
    iss_join <- ""
    if (length(input$ex_issue)) {
      iss_join <- "JOIN issue_labels il USING(url)"
      where <- c(where, "COALESCE(il.office_issues,il.predicted_issues) ILIKE ?")
      params <- c(params, paste0("%", input$ex_issue[1], "%"))
    }
    sent_sel  <- if (HAS_SENT) "ROUND(s.sentiment,3) sentiment," else "NULL sentiment,"
    sent_join <- if (HAS_SENT) "LEFT JOIN sentiment s USING(url)" else ""
    sql <- sprintf("SELECT r.date, r.name, r.party, r.chamber, r.source, il2.top_issue, %s r.title, r.url
      FROM releases r LEFT JOIN issue_labels il2 USING(url) %s %s
      WHERE %s ORDER BY r.date DESC LIMIT 500", sent_sel, sent_join, iss_join, paste(where, collapse = " AND "))
    list(sql = sql, params = params)
  })
  ex_res <- eventReactive(input$ex_go, { q <- ex_query(); qd(q$sql, params = q$params) })
  output$ex_table <- renderDT({
    d <- ex_res(); validate(need(nrow(d) > 0, "No matches (or press Search)."))
    datatable(d |> transmute(date, member = name, party, src = source,
                issue = top_issue, sentiment, title),
              selection = "single", rownames = FALSE, options = list(pageLength = 15))
  })
  output$ex_title <- renderText({ req(input$ex_table_rows_selected); "Release" })
  output$ex_body <- renderUI({
    req(input$ex_table_rows_selected); u <- ex_res()$url[input$ex_table_rows_selected]
    r <- qd("SELECT title, name, date, source, body FROM releases WHERE url = ?", params = list(u))
    tagList(tags$h6(r$title),
            tags$p(class="text-muted small", sprintf("%s · %s · %s", r$name, r$date, SOURCE_LABEL[r$source])),
            if (grepl("^https?://", u)) tags$a(href = u, target = "_blank", "open original") else NULL,
            tags$hr(),
            tags$div(style = "max-height:420px;overflow:auto;white-space:pre-wrap;font-size:0.9em",
                     substr(r$body %||% "(no body)", 1, 6000)))
  })
  output$dl_explore <- downloadHandler(
    filename = function() "pressR_explore_results.csv",
    content = function(file) write.csv(ex_res(), file, row.names = FALSE))

  ## Data & Methods
  output$dm_sources <- renderDT({
    d <- dash$sources |> transmute(
      source = SOURCE_LABEL[source], releases = n, usable,
      span = paste(substr(dmin,1,4), substr(dmax,1,4), sep = "-"),
      `% with body` = pct_body, `% office-tagged` = pct_tagged)
    datatable(d, rownames = FALSE, options = list(dom = "t"))
  })
  output$dm_methods <- renderUI({
    tags$div(lapply(CITES, function(x)
      tags$div(class = "mb-3",
        tags$b(x$t), tags$div(class = "small text-muted", x$w),
        tags$div(class = "small", style = "font-style:italic", x$c,
          if (!is.null(x$u)) tagList(" ", tags$a(href = x$u, target = "_blank", x$u)) else NULL))))
  })
}

shinyApp(ui, server)
