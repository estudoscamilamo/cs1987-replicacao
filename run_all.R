# Replicação de Campbell e Shiller (1987), "Cointegration and Tests of
# Present Value Models", JPE 95(5), p. 1062-1088.
# EAD6034 Econometria de Séries Temporais, FEA-USP, 2026
#
# Roda tudo: dados, tabelas 1 a 3, figuras e a extensão até o último ano.


install.packages(c("readxl"))

rm(list = ls())
options(stringsAsFactors = FALSE, scipen = 999, warn = 1)

SEMENTE <- 1987
B_BOOT  <- 1000
PMAX_ANUAL  <- 8    # p máximo testado no AIC, ações (anual)
PMAX_MENSAL <- 12   # p máximo testado no AIC, juros (mensal)

pkgs <- c("readxl", "urca", "vars")
falta <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(falta)) {
  stop("Pacotes ausentes. Rode antes:\n  install.packages(c(",
       paste0('"', falta, '"', collapse = ", "), "))", call. = FALSE)
}

source("R/funcoes.R", encoding = "UTF-8")
source("R/dados.R", encoding = "UTF-8")
source("R/valores_artigo.R", encoding = "UTF-8")

dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)
MD <- "output/resultados.md"
cat("# Resultados da replicação de Campbell e Shiller (1987)\n",
    "\nGerado por `run_all.R` em ", format(Sys.time(), "%Y-%m-%d %H:%M"), "\n",
    file = MD, sep = "")

# ---- Dados ----
message("\n[0] Dados")
dados <- carregar_dados()
anual <- dados$anual
juros <- dados$juros
message("  ações: ", min(anual$year), "-", max(anual$year),
        " | juros: ", format(min(juros$date)), " a ", format(max(juros$date)))

# monta as variáveis da seção III para um dado theta
prep_acoes <- function(a, theta) {
  delta <- theta / (1 + theta)                 # pois theta = delta/(1-delta)
  Y <- a$Y; y <- a$y
  w  <- c(NA, NA, head(diff(y), -1))           # w_t = Dy_{t-1}
  SL <- c(NA, Y[-1] - theta * head(y, -1))     # SL_t = Y_t - theta*y_{t-1}
  xi <- SL - lagv(SL, 1) / delta + (theta / delta) * w   # retorno em excesso
  list(year = a$year, Y = Y, y = y, dY = c(NA, diff(Y)), dy = c(NA, diff(y)),
       w = w, SL = SL, xi = xi, theta = theta, delta = delta)
}

# Tabela 2: as três estimativas de theta e os testes de Engle-Granger
tabela2 <- function(a) {
  Y <- a$Y; y <- a$y
  f1 <- ols(Y, cbind(1, y))
  dy <- c(NA, diff(y)); dY <- c(NA, diff(Y))
  D <- data.frame(dy = dy, dy1 = lagv(dy, 1), dY = dY, y1 = lagv(y, 1), Y = Y)
  D <- D[complete.cases(D), ]
  f2 <- ols(D$dy, cbind(1, D$dy1, D$dY, D$y1, D$Y))
  ret <- (c(Y[-1], NA) + y) / Y - 1            # (P_{t+1} + D_t)/P_t - 1
  rbar <- mean(ret, na.rm = TRUE)
  th <- c(f1$coef[2], -f2$coef[4] / f2$coef[5], 1 / rbar)
  tab <- data.frame(
    metodo = c("1. Regressão de cointegração (Y_t em y_t)",
               "2. Regressão de correção de erros (Dy_t)",
               "3. Retorno médio da amostra"),
    equacao = c(sprintf("Y = %.3f + %.3f y", f1$coef[1], f1$coef[2]),
                sprintf("Dy = %.3f + %.3f Dy(-1) + %.3f DY - %.3f y(-1) + %.4f Y",
                        f2$coef[1], f2$coef[2], f2$coef[3], -f2$coef[4], f2$coef[5]),
                sprintf("retorno médio = %.2f%%", 100 * rbar)),
    R2 = round(c(f1$r2, f2$r2, NA), 3),
    theta = round(unname(th), 3),
    taxa_desconto = round(1 / unname(th), 4))
  list(tab = tab, eg = eg_tests(f1$resid), theta_coint = unname(th[1]),
       theta_media = unname(th[3]), resid = f1$resid)
}

serie_tab1_acoes <- function(a, thetas) {
  s <- prep_acoes(a, thetas[1])
  out <- list(y_t = s$y, Y_t = s$Y, Dy_t = s$dy, DY_t = s$dY)
  for (th in thetas) {
    s <- prep_acoes(a, th)
    out[[sprintf("SL_t (theta=%.3f)", th)]] <- s$SL
    out[[sprintf("xi_t (theta=%.3f)", th)]] <- s$xi
  }
  out
}

# se p = NULL, usa o p escolhido pelo AIC
roda_acoes <- function(a, theta, p = NULL, pmax = PMAX_ANUAL, B = B_BOOT) {
  s <- prep_acoes(a, theta)
  aic <- select_p_aic(s$w, s$SL, pmax)
  if (is.null(p)) p <- aic$p
  r <- cs_analysis(s$w, s$SL, p, theta, s$delta, lambda = 1, B_boot = B, seed = SEMENTE)
  r$p_aic <- aic$p
  r$ano <- s$year[r$serie$t]
  r$expost <- ex_post(s$w, s$SL, theta, s$delta, lambda = 1)
  r
}

# ---- Parte 1: ações 1871-1986 (mesma amostra do artigo) ----
message("\n[1] Replicação: ações 1871-1986")
a86 <- anual[anual$year >= 1871 & anual$year <= 1986, ]
cat("\n# Parte 1: mercado de ações, 1871-1986\n", file = MD, append = TRUE)

# Tabela 2
t2 <- tabela2(a86)
salvar_tabela(merge(t2$tab, orig_tab2, by = "metodo", sort = FALSE), "tabela2_theta",
              "Tabela 2: estimação de theta (replicação x artigo)", MD)
eg <- data.frame(teste = c("xi2 (DF no resíduo)", "xi3 (ADF(4) no resíduo)"),
                 replicacao = round(t2$eg, 2), original = orig_eg,
                 cv_10 = c(-3.03, -2.84), cv_5 = c(-3.37, -3.17), cv_1 = c(-4.07, -3.77))
salvar_tabela(eg, "tabela2_engle_granger",
              "Tabela 2 (nota): testes de Engle-Granger para não cointegração", MD)

# Tabela 1-B, primeiro com os theta do artigo e depois com os estimados aqui
t1b <- tabela_raiz(serie_tab1_acoes(a86, c(31.092, 12.195)))
t1b <- merge(t1b, orig_tab1B, by = "variavel", sort = FALSE)
salvar_tabela(t1b, "tabela1B_raiz_unitaria_acoes",
              "Tabela 1-B: Phillips-Perron Z(t_alpha), l = 4, theta do artigo", MD)
t1b_est <- tabela_raiz(serie_tab1_acoes(a86, c(t2$theta_coint, t2$theta_media)))
salvar_tabela(t1b_est, "tabela1B_raiz_unitaria_acoes_theta_estimado",
              "Tabela 1-B com os theta estimados nesta replicação", MD)

# Tabela 3-B e figuras 2 e 3
r12_pa <- roda_acoes(a86, 12.195, p = 4)      # theta e p do artigo
r12    <- roda_acoes(a86, 12.195)             # theta do artigo, p pelo AIC
r31_pa <- roda_acoes(a86, 31.092, p = 2)
r31    <- roda_acoes(a86, 31.092)
r_med  <- roda_acoes(a86, t2$theta_media)
r_coi  <- roda_acoes(a86, t2$theta_coint)

c12 <- comparar_tab3("Ações theta=12.195",
                     `theta e p do artigo` = r12_pa, `p pelo AIC` = r12,
                     `theta estimado (ret. médio)` = r_med)
salvar_tabela(c12, "tabela3B_theta12", "Tabela 3-B: theta = 12.195 (8,2%), artigo x replicação", MD)
c31 <- comparar_tab3("Ações theta=31.092",
                     `theta e p do artigo` = r31_pa, `p pelo AIC` = r31,
                     `theta estimado (cointegração)` = r_coi)
salvar_tabela(c31, "tabela3B_theta31", "Tabela 3-B: theta = 31.092 (3,2%), artigo x replicação", MD)

se_tab <- do.call(rbind, lapply(list(
  list("Ações theta=12.195", r12_pa), list("Ações theta=31.092", r31_pa)), function(z) {
    data.frame(caso = z[[1]], estatistica = c("var(S)/var(S')", "corr(S,S')", "var(xi)/var(xi')"),
               ep_original = orig_tab3_se[[z[[1]]]], ep_delta = round(z[[2]]$se_delta, 3),
               ep_bootstrap = round(z[[2]]$se_boot, 3))
  }))
salvar_tabela(se_tab, "tabela3B_erros_padrao", "Tabela 3-B: erros-padrão (artigo, método delta e bootstrap)", MD)

ep <- do.call(rbind, lapply(list(list("Ações theta=12.195", r12_pa), list("Ações theta=31.092", r31_pa)),
                            function(z) data.frame(caso = z[[1]], estatistica = names(orig_expost[[z[[1]]]]),
                                                   original = orig_expost[[z[[1]]]], replicacao = round(z[[2]]$expost, 3))))
salvar_tabela(ep, "expost_scott_acoes", "Spread ex post SL* e regressão de Scott (p. 1082-1083)", MD)

plot_spread(r12_pa$ano, r12_pa, "fig2_acoes_theta12.png",
            "Figura 2: SL e SL' (theta = 12.195, VAR(4)), 1871-1986", c("SL", "SL'"))
plot_spread(r31_pa$ano, r31_pa, "fig3_acoes_theta31.png",
            "Figura 3: SL e SL' (theta = 31.092, VAR(2)), 1871-1986", c("SL", "SL'"))

# ---- Parte 2: estrutura a termo 1959-1983 ----
# os dados não são os mesmos do artigo (ver dados.R)
message("\n[2] Replicação: juros 1959-1983")
cat("\n# Parte 2: estrutura a termo (dados substitutos)\n",
    file = MD, append = TRUE)

DELTA_J <- 1 / (1 + 0.0587 / 12)     # nota 18 do artigo
juros$dr <- c(NA, diff(juros$r))
juros$dR <- c(NA, diff(juros$R))
juros$S  <- juros$R - juros$r
juros$xi <- juros$S - lagv(juros$S, 1) / DELTA_J + juros$dr   # theta = 1 e lambda = delta

amostras <- list("1959-78" = c("1959-01-01", "1978-08-01"),
                 "1959-83" = c("1959-01-01", "1983-10-01"))
t1a <- list(); res_j <- list()
for (nm in names(amostras)) {
  s <- juros[juros$date >= as.Date(amostras[[nm]][1]) & juros$date <= as.Date(amostras[[nm]][2]), ]
  tt <- tabela_raiz(list(y_t = s$r, Y_t = s$R, Dy_t = s$dr, DY_t = s$dR, S_t = s$S, xi_t = s$xi))
  t1a[[nm]] <- cbind(amostra = nm, tt)
  aic <- select_p_aic(s$dr, s$S, PMAX_MENSAL)
  p_art <- if (nm == "1959-78") 11 else 6
  r_art <- cs_analysis(s$dr, s$S, p_art, 1, DELTA_J, lambda = DELTA_J, B_boot = B_BOOT, seed = SEMENTE)
  r_aic <- cs_analysis(s$dr, s$S, aic$p, 1, DELTA_J, lambda = DELTA_J, B_boot = B_BOOT, seed = SEMENTE)
  r_art$data <- s$date[r_art$serie$t]
  r_art$expost <- ex_post(s$dr, s$S, 1, DELTA_J, DELTA_J)
  r_art$p_aic <- aic$p
  res_j[[nm]] <- r_art
  cmp <- comparar_tab3(paste("Juros", nm), `p do artigo` = r_art, `p pelo AIC` = r_aic)
  cmp <- cmp[!grepl("com restrição", cmp$estatistica) & !(cmp$estatistica == "  p-valor" & is.na(cmp$original)), ]
  salvar_tabela(cmp, paste0("tabela3A_juros_", gsub("-", "_", nm)),
                paste0("Tabela 3-A: juros ", nm, " (AIC escolheu p = ", aic$p, ")"), MD)
}
t1a <- merge(do.call(rbind, t1a), orig_tab1A, by = c("amostra", "variavel"), sort = FALSE)
salvar_tabela(t1a, "tabela1A_raiz_unitaria_juros", "Tabela 1-A: Phillips-Perron Z(t_alpha), juros", MD)

ep_j <- data.frame(estatistica = names(orig_expost[["Juros 1959-78"]]),
                   original = orig_expost[["Juros 1959-78"]],
                   replicacao = round(res_j[["1959-78"]]$expost, 3))
salvar_tabela(ep_j, "expost_scott_juros", "Spread ex post S* e regressão de Scott, juros 1959-78", MD)

plot_spread(res_j[["1959-78"]]$data, res_j[["1959-78"]], "fig1_juros_1959_78.png",
            "Figura 1: S e S' (juros, VAR(11)), 1959-1978", c("S", "S'"))

# ---- Parte 3: extensão das ações até o último ano da planilha ----
ano_fim <- max(anual$year)
message("\n[3] Extensão: ações 1871-", ano_fim)
cat("\n# Parte 3: extensão, S&P 1871-", ano_fim, "\n", file = MD, append = TRUE, sep = "")

t2x <- tabela2(anual)
salvar_tabela(t2x$tab, "ext_tabela2_theta", paste0("Extensão: Tabela 2 (1871-", ano_fim, ")"), MD)
egx <- data.frame(teste = c("xi2 (DF no resíduo)", "xi3 (ADF(4) no resíduo)"),
                  estatistica = round(t2x$eg, 2), cv_10 = c(-3.03, -2.84), cv_5 = c(-3.37, -3.17))
salvar_tabela(egx, "ext_engle_granger", "Extensão: Engle-Granger", MD)

# Johansen, para checar a cointegração sem fixar o vetor
jo <- urca::ca.jo(data.frame(Y = anual$Y, y = anual$y), type = "trace", ecdet = "const", K = 2)
jo_tab <- data.frame(H0 = c("r <= 1", "r = 0"), traco = round(jo@teststat, 2),
                     cv_10 = jo@cval[, 1], cv_5 = jo@cval[, 2], cv_1 = jo@cval[, 3])
salvar_tabela(jo_tab, "ext_johansen", "Extensão: Johansen (traço), Y e y, K = 2, constante no vetor", MD)

t1x <- tabela_raiz(serie_tab1_acoes(anual, c(t2x$theta_coint, t2x$theta_media)))
salvar_tabela(t1x, "ext_tabela1_raiz_unitaria", "Extensão: raiz unitária (PP, l = 4)", MD)

rx_med <- roda_acoes(anual, t2x$theta_media)
rx_coi <- roda_acoes(anual, t2x$theta_coint)
rx_12  <- roda_acoes(anual, 12.195)
rx_31  <- roda_acoes(anual, 31.092)
tab3x <- data.frame(estatistica = rotulos_tab3,
                    `theta ret. médio` = signif(chaves_tab3(rx_med), 4),
                    `theta cointegração` = signif(chaves_tab3(rx_coi), 4),
                    `theta=12.195` = signif(chaves_tab3(rx_12), 4),
                    `theta=31.092` = signif(chaves_tab3(rx_31), 4), check.names = FALSE)
salvar_tabela(tab3x, "ext_tabela3", paste0("Extensão: Tabela 3 (1871-", ano_fim,
                                           "); theta ret. médio = ", round(t2x$theta_media, 2),
                                           ", theta cointegração = ", round(t2x$theta_coint, 2)), MD)

plot_spread(rx_med$ano, rx_med, "ext_fig_theta_ret_medio.png",
            sprintf("Extensão: SL e SL' (theta = %.2f, VAR(%d)), 1871-%d", t2x$theta_media, rx_med$p, ano_fim),
            c("SL", "SL'"))
plot_spread(rx_coi$ano, rx_coi, "ext_fig_theta_cointegracao.png",
            sprintf("Extensão: SL e SL' (theta = %.2f, VAR(%d)), 1871-%d", t2x$theta_coint, rx_coi$p, ano_fim),
            c("SL", "SL'"))

# diagnósticos do VAR (checklist da aula 2)
diag_var <- function(a, theta, p, rotulo) {
  s <- prep_acoes(a, theta)
  dv <- data.frame(w = s$w, SL = s$SL)
  dv <- dv[complete.cases(dv), ]
  v <- vars::VAR(dv, p = p, type = "const")
  data.frame(caso = rotulo, p = p,
             portmanteau_p = vars::serial.test(v, lags.pt = p + 10, type = "PT.asymptotic")$serial$p.value,
             arch_p = vars::arch.test(v, lags.multi = 5)$arch.mul$p.value,
             jarque_bera_p = vars::normality.test(v)$jb.mul$JB$p.value,
             max_raiz = max(vars::roots(v)))
}
dg <- rbind(diag_var(anual, t2x$theta_media, rx_med$p, "theta ret. médio"),
            diag_var(anual, t2x$theta_coint, rx_coi$p, "theta cointegração"))
dg[, -(1:2)] <- round(dg[, -(1:2)], 3)
salvar_tabela(dg, "ext_diagnosticos_var",
              "Extensão: diagnósticos (autocorrelação, ARCH, normalidade, estabilidade)", MD)

# robustez: p de 1 a 4, dividendo de dezembro x média do ano
rob <- list()
amed <- dados$anual_media
for (div in c("dez", "media")) {
  base <- if (div == "dez") anual else amed
  tb <- tabela2(base)
  for (th_nm in c("ret. médio", "cointegração")) {
    th <- if (th_nm == "ret. médio") tb$theta_media else tb$theta_coint
    for (p in 1:4) {
      r <- roda_acoes(base, th, p = p, B = 0)
      rob[[length(rob) + 1]] <- data.frame(
        dividendo = div, theta = paste0(th_nm, " (", round(th, 2), ")"), p = p,
        p_wald_sem_media = round(r$pv_sem_media["p"], 4),
        p_wald_com_media = round(r$pv_com_media["p"], 4),
        var_ratio = round(r$stats["var_ratio"], 2), corr = round(r$stats["corr"], 3),
        innov_ratio = round(r$stats["innov_ratio"], 2))
    }
  }
}
rob <- do.call(rbind, rob); rownames(rob) <- NULL
salvar_tabela(rob, "ext_robustez", "Extensão: robustez (p = 1 a 4; dividendo de dezembro x média anual)", MD)

# subamostra pós-guerra
pos <- anual[anual$year >= 1946, ]
tbp <- tabela2(pos)
rp <- roda_acoes(pos, tbp$theta_media, B = 0)
sub <- data.frame(amostra = paste0("1946-", ano_fim), theta = round(tbp$theta_media, 2), p = rp$p,
                  p_wald_sem_media = round(rp$pv_sem_media["p"], 4),
                  var_ratio = round(rp$stats["var_ratio"], 2), corr = round(rp$stats["corr"], 3),
                  innov_ratio = round(rp$stats["innov_ratio"], 2))
salvar_tabela(sub, "ext_subamostra_posguerra", "Extensão: subamostra pós-guerra (theta do retorno médio)", MD)

writeLines(capture.output(sessionInfo()), "output/sessionInfo.txt")
message("\nFim. Resultados em output/resultados.md")