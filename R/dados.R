# Leitura e montagem dos dados
#   ações: planilha ie_data.xls do Shiller (mensal, desde 1871)
#   juros: GS20 do FRED (Treasury de 20 anos) e RF do Ken French (T-bill de 1 mês)

URL_SHILLER <- "http://www.econ.yale.edu/~shiller/data/ie_data.xls"
URL_GS20    <- "https://fred.stlouisfed.org/graph/fredgraph.csv?id=GS20"
URL_FF      <- "https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/F-F_Research_Data_Factors_CSV.zip"

# só baixa se o arquivo ainda não existir em data/raw
baixar <- function(url, dest) {
  if (!file.exists(dest)) {
    message("Baixando ", url)
    ok <- tryCatch({
      utils::download.file(url, dest, mode = "wb", quiet = TRUE)
      TRUE
    }, error = function(e) FALSE)
    if (!ok || !file.exists(dest) || file.size(dest) < 1000) {
      if (file.exists(dest)) file.remove(dest)
      stop("Não consegui baixar ", url, ".\nBaixe o arquivo manualmente e salve em ", dest,
           " (ver README, seção Dados).", call. = FALSE)
    }
  }
  dest
}

# aba "Data", colunas A a E: data (1871.01, ...; outubro vem como 1871.1),
# P nominal, D anualizado, E e CPI
ler_shiller_mensal <- function(path) {
  raw <- readxl::read_excel(path, sheet = "Data", col_names = FALSE, col_types = "text",
                            .name_repair = "minimal")
  num <- function(x) suppressWarnings(as.numeric(x))
  d <- data.frame(date = num(raw[[1]]), P = num(raw[[2]]), D = num(raw[[3]]),
                  E = num(raw[[4]]), CPI = num(raw[[5]]))
  d <- d[!is.na(d$date) & d$date >= 1871 & d$date < 2100, ]
  d$year <- floor(d$date + 1e-9)
  d$month <- round((d$date - d$year) * 100)   # 1871.1 vira 10
  d
}

# Série anual como na p. 1074 do artigo:
#   Y_t = preço de janeiro deflacionado pelo índice de janeiro
#   y_t = dividendo do ano t (4 trimestres) deflacionado pelo índice médio do ano
# Índice com média de 1967 = 100. O artigo deflaciona pelo PPI; aqui só tem CPI.
# div = "dez" usa o D de dezembro (padrão); div = "media" usa a média dos 12 meses.
montar_anual <- function(m, div = c("dez", "media")) {
  div <- match.arg(div)
  yrs <- sort(unique(m$year))
  a <- do.call(rbind, lapply(yrs, function(yr) {
    s <- m[m$year == yr, ]
    jan <- s[s$month == 1, ]
    completo <- nrow(s) == 12 && all(!is.na(s$CPI))
    dd <- if (div == "dez") s$D[s$month == 12] else if (completo && all(!is.na(s$D))) mean(s$D) else NA
    if (length(dd) == 0) dd <- NA
    data.frame(year = yr,
               P_jan = if (nrow(jan)) jan$P[1] else NA,
               CPI_jan = if (nrow(jan)) jan$CPI[1] else NA,
               D = dd,
               CPI_med = if (completo) mean(s$CPI) else NA)
  }))
  base <- a$CPI_med[a$year == 1967]
  a$Y <- a$P_jan * base / a$CPI_jan
  a$y <- a$D * base / a$CPI_med
  a[!is.na(a$Y) & !is.na(a$y), c("year", "P_jan", "D", "CPI_jan", "CPI_med", "Y", "y")]
}

ler_gs20 <- function(path) {
  g <- utils::read.csv(path, stringsAsFactors = FALSE)
  names(g)[1:2] <- c("date", "R")
  g$date <- as.Date(g$date)
  g$R <- suppressWarnings(as.numeric(g$R))
  g[!is.na(g$R), ]
}

ler_ff_rf <- function(zipfile) {
  f <- utils::unzip(zipfile, exdir = file.path(tempdir(), "ff"))
  L <- readLines(f[1], warn = FALSE)
  L <- L[grepl("^\\s*[0-9]{6}\\s*,", L)]          # fica só com as linhas mensais (AAAAMM)
  parts <- strsplit(L, ",")
  ym <- trimws(vapply(parts, `[`, "", 1))
  rf <- as.numeric(trimws(vapply(parts, `[`, "", 5)))
  data.frame(date = as.Date(paste0(substr(ym, 1, 4), "-", substr(ym, 5, 6), "-01")),
             RF = rf)
}

# r_t = 12 x retorno mensal da T-bill (% a.a.) e R_t = GS20 (% a.a.)
montar_juros <- function(gs20, ff) {
  j <- merge(gs20, ff, by = "date")
  j$r <- 12 * j$RF
  j <- j[order(j$date), c("date", "R", "r")]
  j
}

carregar_dados <- function() {
  dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)
  dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
  
  f_sh <- baixar(URL_SHILLER, "data/raw/ie_data.xls")
  f_gs <- baixar(URL_GS20, "data/raw/GS20.csv")
  f_ff <- baixar(URL_FF, "data/raw/F-F_Research_Data_Factors_CSV.zip")
  
  mens <- ler_shiller_mensal(f_sh)
  anual <- montar_anual(mens, "dez")
  anual_media <- montar_anual(mens, "media")
  juros <- montar_juros(ler_gs20(f_gs), ler_ff_rf(f_ff))
  
  write.csv(anual, "data/processed/acoes_anual.csv", row.names = FALSE)
  write.csv(anual_media, "data/processed/acoes_anual_div_media.csv", row.names = FALSE)
  write.csv(juros, "data/processed/juros_mensal.csv", row.names = FALSE)
  
  list(anual = anual, anual_media = anual_media, juros = juros)
}