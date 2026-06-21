# pressR dashboard - precompute-then-serve over the DuckDB store.
# Loads the small precomputed aggregates (dashboard.rds) at startup; queries the
# ~894k `releases` table live ONLY for the Explore tab, drill-downs, and CSV
# downloads (short-lived read_only connections). Corpus = scraped pressR archive
# (2010-2026) + folded external datasets (Stout 114-117, Wang & Tucker 109-115).
suppressMessages({
  library(shiny); library(bslib); library(DT); library(plotly)
  library(ggplot2); library(dplyr); library(DBI); library(duckdb)
})

NLP  <- file.path(dirname(tools::R_user_dir("pressR", "data")), "pressR_nlp")
DB   <- file.path(NLP, "press.duckdb")
dash <- readRDS(file.path(NLP, "dashboard", "dashboard.rds"))
ov   <- dash$overview
PARTY_COL <- c(D = "#2166ac", R = "#b2182b")
SOURCE_LABEL <- c(scraped = "Scraped (pressR)", stout = "Stout 114-117",
                  wangtucker = "Wang & Tucker 109-115")

# short-lived read_only query (never holds the connection open)
qd <- function(sql, params = NULL) {
  con <- dbConnect(duckdb::duckdb(), DB, read_only = TRUE)
  on.exit(dbDisconnect(con, shutdown = TRUE))
  if (is.null(params)) dbGetQuery(con, sql) else dbGetQuery(con, sql, params = params)
}
fmt <- function(x) format(x, big.mark = ",")
HAS_SENT <- tryCatch({ qd("SELECT 1 FROM sentiment LIMIT 1"); TRUE }, error = function(e) FALSE)

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
  list(t = "Issue-tag completion (glmnet)", w = "Per-issue one-vs-rest ridge logistic regression on tf-idf, group-aware splits by family_id; test macro-F1 ~0.78.",
       c = "Friedman, J. H., Hastie, T., & Tibshirani, R. (2010). Regularization Paths for Generalized Linear Models via Coordinate Descent. Journal of Statistical Software, 33(1), 1-22.",
       u = "https://doi.org/10.18637/jss.v033.i01"),
  list(t = "Topic discovery (STM)", w = "Structural Topic Model, prevalence ~ party + chamber + s(year), fit on a family-deduped stratified sample.",
       c = "Roberts, M. E., Stewart, B. M., & Tingley, D. (2019). stm: An R Package for Structural Topic Models. Journal of Statistical Software, 91(2), 1-40.",
       u = "https://doi.org/10.18637/jss.v091.i02"),
  list(t = "Sentiment (sentimentr)", w = "Sentence-level polarity with valence shifters (negators/amplifiers). WEAK on congressional/promotional prose - read with caveats.",
       c = "Rinker, T. W. (2021). sentimentr: Calculate Text Polarity Sentiment. R package version 2.9.0. CRAN.",
       u = "https://CRAN.R-project.org/package=sentimentr"),
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
                showcase = icon("tags"), p(sprintf("%s%% office-tagged, rest predicted", ov$pct_office_tagged))),
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
        radioButtons("it_src", "Labels", c("Office + predicted" = "all", "Office-tagged only" = "office")),
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
        radioButtons("sent_unit", "View", c("Over time" = "time", "By issue" = "issue")),
        helpText(tags$b("Caveat:"), " off-the-shelf sentiment (sentimentr) is a weak, ",
                 "noisy measure on congressional / promotional prose: most releases skew ",
                 "mildly positive. Read differences as suggestive, not definitive; compare ",
                 "WITHIN an issue where possible.")
      ),
      uiOutput("tone_body")
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
      p("This dashboard analyzes congressional press releases from three sources, ",
        "merged into one store with a ", tags$code("source"), " provenance column. ",
        "Counts and date ranges:"),
      DTOutput("dm_sources"),
      h3("Methods & citations", class = "mt-4"),
      p(class = "text-muted small",
        "Classical-R NLP pipeline. Each layer is precomputed and served from a DuckDB store. ",
        "Citations verified against publisher / DOI / CRAN pages."),
      uiOutput("dm_methods"),
      p(class = "text-muted small mt-3",
        "Honest-caveat notes: issue-tag availability is missing-not-at-random by CMS ",
        "(some offices never tag), so predicted labels on never-tagged offices are ",
        "extrapolation; folded external datasets overlap the scraped corpus in time, so ",
        "some releases appear in more than one collection (flagged cross_source).")
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
    else
      card(card_header("Mean sentiment by issue (D vs R)"),
           plotlyOutput("tone_issue", height = 640))
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
