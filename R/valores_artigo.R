# Valores reportados no artigo (Campbell e Shiller, 1987, p. 1075-1078),
# usados para comparar com a replicação

# Tabela 1-A: raiz unitária dos juros nas duas amostras
orig_tab1A <- data.frame(
  amostra = rep(c("1959-78", "1959-83"), each = 6),
  variavel = rep(c("y_t", "Y_t", "Dy_t", "DY_t", "S_t", "xi_t"), 2),
  Z_tendencia_orig     = c(-2.78, -2.76, -17.40, -15.30, -3.15, -15.22,
                           -3.83, -2.51, -17.05, -15.27, -4.77, -15.18),
  Z_sem_tendencia_orig = c(-1.72, -0.46, -17.44, -15.32, -3.08, -15.25,
                           -2.32, -0.50, -17.08, -15.29, -4.67, -15.19)
)

# Tabela 1-B: raiz unitária das ações, 1871-1986, para os dois theta
orig_tab1B <- data.frame(
  variavel = c("y_t", "Y_t", "Dy_t", "DY_t",
               "SL_t (theta=31.092)", "xi_t (theta=31.092)",
               "SL_t (theta=12.195)", "xi_t (theta=12.195)"),
  Z_tendencia_orig     = c(-2.88, -2.19, -8.40, -9.91, -4.35, -9.93, -2.68, -9.76),
  Z_sem_tendencia_orig = c(-1.28, -1.53, -8.44, -9.96, -4.31, -9.99, -2.15, -9.69)
)

# Tabela 2: theta por cointegração, correção de erros e retorno médio
orig_tab2 <- data.frame(
  metodo = c("1. Regressão de cointegração (Y_t em y_t)",
             "2. Regressão de correção de erros (Dy_t)",
             "3. Retorno médio da amostra"),
  R2_orig = c(0.842, 0.373, NA),
  theta_orig = c(31.092, 37.021, 12.195),
  taxa_desconto_orig = c(0.032, 0.027, 0.082)
)
orig_eg <- c(xi2_DF = -3.58, xi3_ADF4 = -2.64)

# Tabela 3, os quatro casos
# nos juros o artigo não reporta o Wald com restrição de média, por isso fica NA
orig_tab3 <- list(
  "Juros 1959-78" = c(p = 11, R2_w = .216, R2_S = .877, gc_S_w = .0001, gc_w_S = .003,
                      wald_sem = 83.02, p_sem = .00005, wald_com = NA, p_com = NA,
                      E_w = .016, E_S = 1.144, E_Sp = .016, sd_w = .442, sd_S = 1.060,
                      var_ratio = .987, corr = .978, innov_ratio = 1.160),
  "Juros 1959-83" = c(p = 6, R2_w = .171, R2_S = .772, gc_S_w = .003, gc_w_S = .013,
                      wald_sem = 35.63, p_sem = .0003, wald_com = NA, p_com = NA,
                      E_w = .021, E_S = 1.138, E_Sp = .021, sd_w = .793, sd_S = 1.320,
                      var_ratio = 3.394, corr = .956, innov_ratio = .502),
  "Ações theta=12.195" = c(p = 4, R2_w = .400, R2_S = .837, gc_S_w = .00001, gc_w_S = .633,
                           wald_sem = 15.72, p_sem = .047, wald_com = 15.74, p_com = .072,
                           E_w = .017, E_S = 16.07, E_Sp = 2.563, sd_w = .168, sd_S = 15.51,
                           var_ratio = 67.22, corr = -.459, innov_ratio = 11.27),
  "Ações theta=31.092" = c(p = 2, R2_w = .378, R2_S = .516, gc_S_w = .00001, gc_w_S = .018,
                           wald_sem = 5.75, p_sem = .218, wald_com = 14.90, p_com = .011,
                           E_w = .017, E_S = -12.52, E_Sp = 16.66, sd_w = .167, sd_S = 9.937,
                           var_ratio = 4.786, corr = .911, innov_ratio = 1.414)
)

# erros-padrão da Tabela 3
orig_tab3_se <- list(
  "Juros 1959-78"      = c(var_ratio = .360,  corr = .011, innov_ratio = 1.146),
  "Juros 1959-83"      = c(var_ratio = 3.948, corr = .098, innov_ratio = .506),
  "Ações theta=12.195" = c(var_ratio = 86.04, corr = .801, innov_ratio = 4.49),
  "Ações theta=31.092" = c(var_ratio = 5.380, corr = .207, innov_ratio = .441)
)

# spread ex post: sd(S*), sd(S) e coeficiente de Scott
orig_expost <- list(
  "Juros 1959-78"      = c(sd_Sstar = 1.217, sd_S = 1.060,  coef_scott = 0.81),
  "Ações theta=12.195" = c(sd_Sstar = 7.928, sd_S = 15.506, coef_scott = 0.16),
  "Ações theta=31.092" = c(sd_Sstar = 12.888, sd_S = 9.937, coef_scott = 0.02)
)

# nomes das linhas nas tabelas de saída
rotulos_tab3 <- c(
  p = "p (AIC no artigo)", R2_w = "R2 eq. Dy", R2_S = "R2 eq. S",
  gc_S_w = "p-valor: S Granger-causa Dy", gc_w_S = "p-valor: Dy Granger-causa S",
  wald_sem = "Wald VP sem restrição de média", p_sem = "  p-valor",
  wald_com = "Wald VP com restrição de média", p_com = "  p-valor",
  E_w = "E(Dy)", E_S = "E(S)", E_Sp = "E(S')", sd_w = "sd(Dy)", sd_S = "sd(S)",
  var_ratio = "var(S)/var(S')", corr = "corr(S,S')", innov_ratio = "var(xi)/var(xi')"
)

# tira do resultado de cs_analysis os números na ordem da Tabela 3
chaves_tab3 <- function(r) {
  c(p = r$p, R2_w = r$R2_w, R2_S = r$R2_S,
    gc_S_w = unname(r$gc_S_w["p"]), gc_w_S = unname(r$gc_w_S["p"]),
    wald_sem = unname(r$pv_sem_media["stat"]), p_sem = unname(r$pv_sem_media["p"]),
    wald_com = unname(r$pv_com_media["stat"]), p_com = unname(r$pv_com_media["p"]),
    E_w = r$E_w, E_S = r$E_S, E_Sp = r$E_Sp, sd_w = r$sd_w, sd_S = r$sd_S,
    var_ratio = unname(r$stats["var_ratio"]), corr = unname(r$stats["corr"]),
    innov_ratio = unname(r$stats["innov_ratio"]))
}

# coloca a Tabela 3 do artigo ao lado de uma ou mais replicações
comparar_tab3 <- function(caso, ...) {
  reps <- list(...)
  o <- orig_tab3[[caso]]
  df <- data.frame(estatistica = rotulos_tab3[names(o)], original = signif(o, 4))
  for (nm in names(reps)) df[[nm]] <- signif(chaves_tab3(reps[[nm]])[names(o)], 4)
  rownames(df) <- NULL
  df
}