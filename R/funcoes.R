# Funções usadas na replicação de Campbell e Shiller (1987)
# urca e vars entram só para conferir alguns resultados

# defasa o vetor x em k períodos
lagv <- function(x, k) {
  if (k == 0) return(x)
  c(rep(NA, k), head(x, -k))
}

ols <- function(y, X) {
  X <- as.matrix(X)
  XtXi <- solve(crossprod(X))
  b <- drop(XtXi %*% crossprod(X, y))
  e <- drop(y - X %*% b)
  list(coef = b, resid = e, XtXi = XtXi, X = X, y = y,
       r2 = 1 - sum(e^2) / sum((y - mean(y))^2))
}

# covariância robusta de White (HC0), igual ao artigo
vcov_hc0 <- function(fit) {
  meat <- crossprod(fit$X * fit$resid)
  fit$XtXi %*% meat %*% fit$XtXi
}

# Wald para H0: b[idx] = 0
wald <- function(b, V, idx) {
  bb <- b[idx]
  VV <- V[idx, idx, drop = FALSE]
  stat <- drop(t(bb) %*% solve(VV, bb))
  c(stat = stat, df = length(idx),
    p = pchisq(stat, df = length(idx), lower.tail = FALSE))
}

# Phillips-Perron Z(t_alpha) da Tabela 1
# regressão: dx_t = mu (+ beta t) + alpha x_{t-1} + u_t
# variância de longo prazo por Newey-West com l = 4, como na nota da tabela
# (fórmula do Hamilton, 1994)
pp_ztau <- function(x, trend = FALSE, l = 4) {
  x <- as.numeric(na.omit(x))
  dx <- diff(x)
  xl <- head(x, -1)
  n <- length(dx)
  X <- cbind(1, if (trend) seq_len(n), xl)
  fit <- ols(dx, X)
  u <- fit$resid
  k <- ncol(X)
  s2 <- sum(u^2) / (n - k)
  se_a <- sqrt(s2 * fit$XtXi[k, k])
  t_a <- fit$coef[k] / se_a
  g0 <- sum(u^2) / n
  lam2 <- g0
  for (j in seq_len(l)) {
    gj <- sum(u[(j + 1):n] * u[1:(n - j)]) / n
    lam2 <- lam2 + 2 * (1 - j / (l + 1)) * gj
  }
  Z <- sqrt(g0 / lam2) * t_a - 0.5 * (lam2 - g0) / sqrt(lam2) * n * se_a / sqrt(s2)
  unname(Z)
}

# valores críticos do Fuller (nota da Tabela 1)
pp_sig <- function(Z, trend) {
  cv <- if (trend) c("1%" = -3.96, "2.5%" = -3.66, "5%" = -3.41, "10%" = -3.12) else c("1%" = -3.43, "2.5%" = -3.12, "5%" = -2.86, "10%" = -2.57)
  hit <- names(cv)[Z < cv]
  if (length(hit)) hit[1] else ""
}

# Tabela 1 para uma lista de séries; as colunas urca_* são só conferência
tabela_raiz <- function(series, l = 4) {
  out <- lapply(names(series), function(nm) {
    x <- series[[nm]]
    zt <- pp_ztau(x, trend = TRUE, l = l)
    zc <- pp_ztau(x, trend = FALSE, l = l)
    
    ur_t <- ur_c <- NA
    if (requireNamespace("urca", quietly = TRUE)) {
      xx <- as.numeric(na.omit(x))
      ur_t <- tryCatch(urca::ur.pp(xx, type = "Z-tau", model = "trend", use.lag = l)@teststat[1],
                       error = function(e) NA)
      ur_c <- tryCatch(urca::ur.pp(xx, type = "Z-tau", model = "constant", use.lag = l)@teststat[1],
                       error = function(e) NA)
    }
    data.frame(variavel = nm, n = sum(!is.na(x)),
               Z_tendencia = round(zt, 2), sig_tendencia = pp_sig(zt, TRUE),
               Z_sem_tendencia = round(zc, 2), sig_sem_tendencia = pp_sig(zc, FALSE),
               urca_tendencia = round(unname(ur_t), 2), urca_sem_tendencia = round(unname(ur_c), 2))
  })
  do.call(rbind, out)
}

# Engle-Granger (1987) no resíduo da regressão de cointegração (Tabela 2)
# xi2: DF sem constante; xi3: ADF com 4 defasagens
# o artigo reporta em módulo, aqui o sinal fica
eg_tests <- function(u, lags = 4) {
  u <- as.numeric(na.omit(u))
  du <- diff(u)
  ul <- head(u, -1)
  n <- length(du)
  f2 <- ols(du, cbind(ul))
  s2 <- sum(f2$resid^2) / (n - 1)
  t2 <- f2$coef[1] / sqrt(s2 * f2$XtXi[1, 1])
  D <- do.call(cbind, lapply(1:lags, function(j) lagv(du, j)))
  ok <- (lags + 1):n
  X <- cbind(ul[ok], D[ok, , drop = FALSE])
  f3 <- ols(du[ok], X)
  s3 <- sum(f3$resid^2) / (length(ok) - ncol(X))
  t3 <- f3$coef[1] / sqrt(s3 * f3$XtXi[1, 1])
  c(xi2_DF = unname(t2), xi3_ADF4 = unname(t3))
}

# VAR em w e S
#   w: Dy_t nos juros, Dy_{t-1} nas ações
#   S: spread S_t nos juros, SL_t = Y_t - theta*y_{t-1} nas ações
#   z_t = (w_t, ..., w_{t-p+1}, S_t, ..., S_{t-p+1}), eq. 6 do artigo
make_lags <- function(w, S, p) {
  Z <- cbind(do.call(cbind, lapply(0:(p - 1), function(k) lagv(w, k))),
             do.call(cbind, lapply(0:(p - 1), function(k) lagv(S, k))))
  colnames(Z) <- c(paste0("w_L", 0:(p - 1)), paste0("S_L", 0:(p - 1)))
  list(Z = Z, w1 = c(w[-1], NA), S1 = c(S[-1], NA))
}

# VAR(p) por MQO equação a equação; rows permite fixar a amostra
fit_var <- function(w, S, p, rows = NULL) {
  L <- make_lags(w, S, p)
  ok <- which(complete.cases(L$Z) & !is.na(L$w1) & !is.na(L$S1))
  if (!is.null(rows)) ok <- intersect(ok, rows)
  Z <- L$Z[ok, , drop = FALSE]
  X <- cbind(const = 1, Z)
  Y <- cbind(w = L$w1[ok], S = L$S1[ok])
  XtXi <- solve(crossprod(X))
  B <- XtXi %*% crossprod(X, Y)
  E <- Y - X %*% B
  n <- nrow(X)
  list(B = B, E = E, X = X, Y = Y, Z = Z, XtXi = XtXi, n = n, p = p,
       Sigma = crossprod(E) / n, idx = ok, w = w, S = S)
}

# matriz companheira A (2p x 2p), na mesma ordem de z_t
companion <- function(B, p) {
  m <- 2 * p
  A <- matrix(0, m, m)
  A[1, ] <- B[-1, 1]
  A[p + 1, ] <- B[-1, 2]
  if (p > 1) for (i in 2:p) {
    A[i, i - 1] <- 1
    A[p + i, p + i - 1] <- 1
  }
  A
}

# AIC da nota 26: minimiza -lnL + nº de parâmetros
# todos os p são estimados na mesma amostra (a do pmax)
select_p_aic <- function(w, S, pmax = 8) {
  L <- make_lags(w, S, pmax)
  rows <- which(complete.cases(L$Z) & !is.na(L$w1) & !is.na(L$S1))
  crit <- sapply(1:pmax, function(p) {
    f <- fit_var(w, S, p, rows = rows)
    ll <- -f$n / 2 * (2 * log(2 * pi) + log(det(f$Sigma)) + 2)
    -ll + 2 * (2 * p + 1)
  })
  list(p = which.min(crit), crit = crit)
}

# Estatísticas da Tabela 3. lambda muda o timing:
#   juros (seção I), lambda = delta: S_t = theta * soma_{i>=1} delta^i E_t w_{t+i}
#   ações (seção III), lambda = 1: SL_t = theta * soma_{j>=1} delta^(j-1) E_t w_{t+j}
# spread teórico (eq. 9): S'_t = theta*lambda*h'A(I - delta A)^-1 z_t
# retorno em excesso: xi_{t+1} = S_{t+1} - S_t/delta + (theta*lambda/delta) w_{t+1}
cs_stats <- function(A, Sigma, Zc, Sact, p, theta, delta, lambda) {
  m <- 2 * p
  h <- numeric(m); h[1] <- 1
  kvec <- theta * lambda * drop(h %*% A %*% solve(diag(m) - delta * A))
  Sp <- drop(Zc %*% kvec)
  cw <- theta * lambda / delta
  m_act <- c(cw, 1)                         # inovação de xi
  m_th <- c(kvec[1] + cw, kvec[p + 1])      # inovação de xi' (eq. 12)
  c(var_ratio = var(Sact) / var(Sp),
    corr = cor(Sact, Sp),
    innov_ratio = drop(t(m_act) %*% Sigma %*% m_act) / drop(t(m_th) %*% Sigma %*% m_th))
}

# HC0 dos coeficientes do VAR empilhados (vec B, equação de w primeiro)
vcov_var_hc0 <- function(fit) {
  K <- ncol(fit$X)
  meat <- matrix(0, 2 * K, 2 * K)
  for (t in seq_len(fit$n)) {
    meat <- meat + kronecker(tcrossprod(fit$E[t, ]), tcrossprod(fit$X[t, ]))
  }
  bread <- kronecker(diag(2), fit$XtXi)
  bread %*% meat %*% bread
}

# gera uma série artificial reamostrando os resíduos do VAR (bootstrap recursivo)
boot_series <- function(fit) {
  p <- fit$p; b <- fit$B; n <- fit$n
  t0 <- fit$idx[1]
  w <- fit$w[(t0 - p + 1):t0]
  S <- fit$S[(t0 - p + 1):t0]
  E <- fit$E[sample.int(n, n, replace = TRUE), , drop = FALSE]
  for (i in seq_len(n)) {
    L <- length(w)
    z <- c(1, w[L:(L - p + 1)], S[L:(L - p + 1)])
    w <- c(w, sum(z * b[, 1]) + E[i, 1])
    S <- c(S, sum(z * b[, 2]) + E[i, 2])
  }
  list(w = w, S = S)
}

# Tabela 3 inteira para um theta, delta, lambda e p
cs_analysis <- function(w, S, p, theta, delta, lambda, B_boot = 0, seed = 1987) {
  fit <- fit_var(w, S, p)
  K <- ncol(fit$X)
  idx_w <- 1 + 1:p
  idx_S <- 1 + p + 1:p
  
  # cada equação separada: R2 e Granger (Wald com HC0)
  fw <- ols(fit$Y[, "w"], fit$X); Vw <- vcov_hc0(fw)
  fS <- ols(fit$Y[, "S"], fit$X); VS <- vcov_hc0(fS)
  gc_S_w <- wald(fw$coef, Vw, idx_S)
  gc_w_S <- wald(fS$coef, VS, idx_w)
  
  # teste do modelo de valor presente (eq. 8): xi_{t+1} regredido em z_t
  cw <- theta * lambda / delta
  xi1 <- fit$Y[, "S"] - fit$Z[, p + 1] / delta + cw * fit$Y[, "w"]
  fx <- ols(xi1, fit$X); Vx <- vcov_hc0(fx)
  pv_com_media <- wald(fx$coef, Vx, 1:K)
  pv_sem_media <- wald(fx$coef, Vx, 2:K)
  
  # spread teórico
  A <- companion(fit$B, p)
  Zc <- scale(fit$Z, center = TRUE, scale = FALSE)
  Sact <- fit$Z[, p + 1]
  m <- 2 * p
  h <- numeric(m); h[1] <- 1
  kvec <- theta * lambda * drop(h %*% A %*% solve(diag(m) - delta * A))
  Sp <- drop(Zc %*% kvec)
  st <- cs_stats(A, fit$Sigma, Zc, Sact, p, theta, delta, lambda)
  Ew <- mean(fit$Z[, 1])
  
  # erro-padrão pelo método delta (só incerteza nos coeficientes; razões em nível)
  Vb <- vcov_var_hc0(fit)
  sl <- c(2:K, K + 2:K)
  b0 <- c(fit$B[-1, 1], fit$B[-1, 2])
  f_b <- function(b) {
    Bn <- fit$B
    Bn[-1, 1] <- b[1:(K - 1)]
    Bn[-1, 2] <- b[K:(2 * K - 2)]
    cs_stats(companion(Bn, p), fit$Sigma, Zc, Sact, p, theta, delta, lambda)
  }
  G <- sapply(seq_along(b0), function(j) {
    hstep <- 1e-6 * max(1, abs(b0[j]))
    bp <- b0; bm <- b0
    bp[j] <- bp[j] + hstep; bm[j] <- bm[j] - hstep
    (f_b(bp) - f_b(bm)) / (2 * hstep)
  })
  se_delta <- sqrt(pmax(diag(G %*% Vb[sl, sl] %*% t(G)), 0))
  
  # erro-padrão por bootstrap (aqui Sigma também varia)
  se_boot <- c(var_ratio = NA, corr = NA, innov_ratio = NA)
  if (B_boot > 0) {
    set.seed(seed)
    bs <- t(replicate(B_boot, tryCatch({
      sim <- boot_series(fit)
      fb <- fit_var(sim$w, sim$S, p)
      Ab <- companion(fb$B, p)
      if (max(Mod(eigen(Ab, only.values = TRUE)$values)) * delta >= 1) stop("instavel")
      cs_stats(Ab, fb$Sigma, scale(fb$Z, TRUE, FALSE), fb$Z[, p + 1], p, theta, delta, lambda)
    }, error = function(e) c(var_ratio = NA, corr = NA, innov_ratio = NA))))
    se_boot <- apply(bs, 2, sd, na.rm = TRUE)
  }
  
  list(
    p = p, n = fit$n, theta = theta, delta = delta,
    R2_w = fw$r2, R2_S = fS$r2,
    gc_S_w = gc_S_w, gc_w_S = gc_w_S,
    pv_com_media = pv_com_media, pv_sem_media = pv_sem_media,
    E_w = Ew, sd_w = sd(fit$Z[, 1]),
    E_S = mean(Sact), sd_S = sd(Sact),
    E_Sp = theta * lambda * Ew / (1 - delta),
    stats = st, se_delta = se_delta, se_boot = se_boot,
    max_raiz = max(Mod(eigen(A, only.values = TRUE)$values)),
    serie = data.frame(t = fit$idx, S = Sact, S_teorico = Sp),
    fit = fit
  )
}

# spread ex post e regressão de Scott (p. 1082-1083)
# S*_t = theta*lambda*w_{t+1} + delta*S*_{t+1}, com S*_T = S_T
ex_post <- function(w, S, theta, delta, lambda) {
  Tn <- max(which(!is.na(S)))
  Sstar <- rep(NA_real_, length(S))
  Sstar[Tn] <- S[Tn]
  for (t in (Tn - 1):1) Sstar[t] <- theta * lambda * w[t + 1] + delta * Sstar[t + 1]
  rows <- which(!is.na(S) & !is.na(Sstar))
  f <- ols(Sstar[rows], cbind(1, S[rows]))
  c(sd_Sstar = sd(Sstar[rows]), sd_S = sd(S[rows]), coef_scott = unname(f$coef[2]))
}

md_table <- function(df) {
  df[] <- lapply(df, function(x) {
    if (!is.numeric(x)) return(as.character(x))
    vapply(x, function(v) if (is.na(v)) "" else formatC(signif(v, 4), format = "g", digits = 4), "")
  })
  c(paste0("| ", paste(names(df), collapse = " | "), " |"),
    paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
    apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
}

# grava o csv e acrescenta a tabela no resultados.md
salvar_tabela <- function(df, nome, titulo, md_file) {
  write.csv(df, file.path("output", "tables", paste0(nome, ".csv")), row.names = FALSE)
  cat(c("", paste0("## ", titulo), "", md_table(df), ""), file = md_file, sep = "\n", append = TRUE)
  message("  salvo: output/tables/", nome, ".csv")
  invisible(df)
}

# figuras 1 a 3: S e S' como desvio da própria média
plot_spread <- function(tempo, r, arquivo, titulo, rotulos = c("S", "S'")) {
  png(file.path("output", "figures", arquivo), width = 1600, height = 900, res = 170)
  on.exit(dev.off())
  s <- r$serie$S - mean(r$serie$S)
  sp <- r$serie$S_teorico - mean(r$serie$S_teorico)
  rg <- range(c(s, sp))
  plot(tempo, s, type = "l", lwd = 2, col = "black", ylim = rg,
       xlab = "", ylab = "desvio em relação à média", main = titulo)
  lines(tempo, sp, lwd = 2, lty = 2, col = "firebrick")
  abline(h = 0, col = "grey60")
  legend("topleft", bty = "n", lwd = 2, lty = c(1, 2), col = c("black", "firebrick"),
         legend = c(paste(rotulos[1], "(observado)"), paste(rotulos[2], "(teórico, VAR)")))
  message("  salvo: output/figures/", arquivo)
}