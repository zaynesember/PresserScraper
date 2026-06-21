# pressR dashboard — precompute-then-serve over the DuckDB store.
# Loads the small precomputed aggregates (dashboard.rds) at startup; queries the
# 436k `releases` table live ONLY for the Explore tab + drill-downs.
suppressMessages({
  library(shiny); library(bslib); library(DT); library(plotly)
  library(ggplot2); library(dplyr); library(DBI); library(duckdb)
})

NLP  <- file.path(dirname(tools::R_user_dir("pressR", "data")), "pressR_nlp")
DB   <- file.path(NLP, "press.duckdb")
dash <- readRDS(file.path(NLP, "dashboard", "dashboard.rds"))
ov   <- dash$overview
PARTY_COL <- c(D = "#2166ac", R = "#b2182b")

# short-lived read_only query (never holds the connection open)
qd <- function(sql, params = NULL) {
  con <- dbConnect(duckdb::duckdb(), DB, read_only = TRUE)
  on.exit(dbDisconnect(con, shutdown = TRUE))
  if (is.null(params)) dbGetQuery(con, sql) else dbGetQuery(con, sql, params = params)
}
fmt <- function(x) format(x, big.mark = ",")

theme_pr <- function() theme_minimal(base_size = 13) +
  theme(legend.position = "top", panel.grid.minor = element_blank())

ui <- page_navbar(
  title = "pressR · Congressional Press Releases",
  theme = bs_theme(version = 5, bootswatch = "cosmo", primary = "#2c3e50"),
  nav_panel(
    "Overview", icon = icon("chart-line"),
    layout_columns(
      fill = FALSE,
      value_box("Releases", fmt(ov$n_total), showcase = icon("file-lines"),
                p(sprintf("%s–%s · %s%% with body text", substr(ov$dmin,1,4), substr(ov$dmax,1,4), ov$pct_body))),
      value_box("Issue-labeled", paste0(ov$pct_labeled, "%"), theme = "info",
                showcase = icon("tags"), p(sprintf("%s%% office-tagged, rest predicted", ov$pct_office_tagged))),
      value_box("Reuse text", paste0(ov$pct_reused, "%"), theme = "warning",
                showcase = icon("copy"), p(sprintf("%s reused families", fmt(ov$n_reused_fam)))),
      value_box("Cross-party messages", fmt(ov$n_xparty), theme = "secondary",
                showcase = icon("handshake"), p(sprintf("%s cross-chamber", fmt(ov$n_xchamber))))
    ),
    layout_columns(
      card(card_header("Top issues across the corpus"), plotlyOutput("ov_issues", height = 420)),
      card(card_header("House vs Senate"),
           value_box("House", fmt(ov$n_house), theme = "light"),
           value_box("Senate", fmt(ov$n_senate), theme = "light")),
      col_widths = c(8, 4)
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
        helpText("Share = % of a party's labeled releases that quarter touching the issue. ",
                 "2010 (sparse) and 2026 (partial) are caveated endpoints.")
      ),
      plotlyOutput("it_plot", height = 560)
    )
  ),
  nav_panel(
    "Topics (STM)", icon = icon("layer-group"),
    layout_columns(
      card(card_header("40 discovered topics — click a row"),
           DTOutput("tp_table")),
      card(card_header(textOutput("tp_title")),
           plotlyOutput("tp_plot", height = 300), uiOutput("tp_examples")),
      col_widths = c(6, 6)
    )
  ),
  nav_panel(
    "Coordinated Messaging", icon = icon("share-nodes"),
    layout_sidebar(
      sidebar = sidebar(
        checkboxInput("cm_xparty", "Cross-party only", FALSE),
        checkboxInput("cm_xchamber", "Cross-chamber only", FALSE),
        sliderInput("cm_min", "Min members", 2, 45, 3),
        helpText("Families of releases sharing the same / near-same body — joint statements, ",
                 "delegation letters, reused talking points.")
      ),
      layout_columns(
        card(card_header("Message families — click a row"), DTOutput("cm_table")),
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
        sliderInput("ex_years", "Years", min(dash$years), max(dash$years),
                    c(min(dash$years), max(dash$years)), sep = ""),
        actionButton("ex_go", "Search", class = "btn-primary")
      ),
      layout_columns(
        card(card_header("Results (max 500)"), DTOutput("ex_table")),
        card(card_header(textOutput("ex_title")), uiOutput("ex_body")),
        col_widths = c(7, 5)
      )
    )
  ),
  nav_spacer(),
  nav_item(tags$span(class = "navbar-text small", sprintf("DuckDB · built %s", substr(dash$built_at,1,16))))
)

server <- function(input, output, session) {
  updateSelectizeInput(session, "ex_member", choices = dash$members$name, server = TRUE)

  ## Overview: top issues bar
  output$ov_issues <- renderPlotly({
    tot <- dash$issue_trends_all |> group_by(issue) |>
      summarise(n = sum(n_issue), .groups = "drop") |> slice_max(n, n = 15)
    p <- ggplot(tot, aes(reorder(issue, n), n)) +
      geom_col(fill = "#2c3e50") + coord_flip() +
      labs(x = NULL, y = "releases (issue mentions)") + theme_pr()
    ggplotly(p, tooltip = c("y"))
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

  ## Coordinated messaging
  cm_data <- reactive({
    d <- dash$fam_top |> filter(n_members >= input$cm_min)
    if (input$cm_xparty)   d <- d |> filter(cross_party)
    if (input$cm_xchamber) d <- d |> filter(cross_chamber)
    d
  })
  output$cm_table <- renderDT({
    datatable(cm_data() |> transmute(members = n_members, copies = n_docs, parties,
                span_days, message = substr(rep_title, 1, 70)),
              selection = "single", rownames = FALSE,
              options = list(pageLength = 12, order = list(list(0, "desc"))))
  })
  cm_fam <- reactive({ s <- input$cm_table_rows_selected; req(length(s)); cm_data()$family_id[s] })
  output$cm_title <- renderText({ req(input$cm_table_rows_selected); "Who shared this message" })
  output$cm_detail <- renderUI({
    req(input$cm_table_rows_selected)
    fid <- cm_fam()
    d <- qd("SELECT r.name, r.party, r.chamber, r.date, r.title, r.url
             FROM release_family rf JOIN releases r USING(url)
             WHERE rf.family_id = ? ORDER BY r.date", params = list(fid))
    body <- qd("SELECT body FROM release_family rf JOIN releases r USING(url)
                WHERE rf.family_id = ? AND r.body IS NOT NULL LIMIT 1", params = list(fid))$body
    tagList(
      tags$p(tags$b(sprintf("%d releases by %d members", nrow(d), length(unique(d$name))))),
      tags$table(class = "table table-sm",
        tags$thead(tags$tr(tags$th("Member"), tags$th("Party"), tags$th("Date"))),
        tags$tbody(lapply(seq_len(nrow(d)), function(i)
          tags$tr(tags$td(tags$a(href = d$url[i], target="_blank", d$name[i])),
                  tags$td(d$party[i]), tags$td(as.character(d$date[i])))))),
      tags$hr(), tags$b("Shared text (excerpt):"),
      tags$div(style = "max-height:240px;overflow:auto;font-size:0.85em;white-space:pre-wrap",
               substr(body %||% "(none)", 1, 1500)))
  })

  ## Explore (live query)
  ex_res <- eventReactive(input$ex_go, {
    where <- c("r.usable"); params <- list()
    if (nzchar(input$ex_q)) { where <- c(where, "(r.title ILIKE ? OR r.body ILIKE ?)")
      params <- c(params, paste0("%", input$ex_q, "%"), paste0("%", input$ex_q, "%")) }
    if (input$ex_chamber != "Both") { where <- c(where, "r.chamber = ?"); params <- c(params, tolower(input$ex_chamber)) }
    if (input$ex_party != "Both")   { where <- c(where, "r.party = ?"); params <- c(params, input$ex_party) }
    where <- c(where, "r.year BETWEEN ? AND ?"); params <- c(params, input$ex_years[1], input$ex_years[2])
    if (length(input$ex_member)) { where <- c(where, sprintf("r.name IN (%s)", paste(rep("?", length(input$ex_member)), collapse=","))); params <- c(params, as.list(input$ex_member)) }
    iss_join <- ""
    if (length(input$ex_issue)) {
      iss_join <- "JOIN issue_labels il USING(url)"
      where <- c(where, sprintf("(%s)", paste(sprintf("COALESCE(il.office_issues,il.predicted_issues) ILIKE ?"), collapse=" OR ")))
      params <- c(params, paste0("%", input$ex_issue[1], "%"))
    }
    sql <- sprintf("SELECT r.date, r.name, r.party, r.chamber, il2.top_issue, r.title, r.url
      FROM releases r LEFT JOIN issue_labels il2 USING(url) %s
      WHERE %s ORDER BY r.date DESC LIMIT 500", iss_join, paste(where, collapse = " AND "))
    qd(sql, params = params)
  })
  output$ex_table <- renderDT({
    d <- ex_res(); validate(need(nrow(d) > 0, "No matches (or press Search)."))
    datatable(d |> transmute(date, member = name, party, chamber, issue = top_issue, title),
              selection = "single", rownames = FALSE, options = list(pageLength = 15))
  })
  output$ex_title <- renderText({ req(input$ex_table_rows_selected); "Release" })
  output$ex_body <- renderUI({
    req(input$ex_table_rows_selected); u <- ex_res()$url[input$ex_table_rows_selected]
    r <- qd("SELECT title, name, date, body FROM releases WHERE url = ?", params = list(u))
    tagList(tags$h6(r$title), tags$p(class="text-muted small", sprintf("%s · %s", r$name, r$date)),
            tags$a(href = u, target = "_blank", "open original"), tags$hr(),
            tags$div(style = "max-height:420px;overflow:auto;white-space:pre-wrap;font-size:0.9em",
                     substr(r$body %||% "(no body)", 1, 6000)))
  })
}

shinyApp(ui, server)
