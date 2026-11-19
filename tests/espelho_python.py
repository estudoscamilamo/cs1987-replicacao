"""
Espelho em Python (numpy) das funções de R/funcoes.R, usado só para validar a
matemática do método em dados simulados nos quais o modelo de valor presente
vale por construção. Não faz parte do pipeline de R.

Resultado esperado sob H0:
  var(S)/var(S') ~ 1, corr(S,S') ~ 1, var(xi)/var(xi') ~ 1,
  e o teste de Wald rejeita ~5% das vezes a 5%.
"""
import numpy as np
from scipy import stats

def lagv(x, k):
    return x if k == 0 else np.r_[np.full(k, np.nan), x[:-k]]

def ols(y, X):
    XtXi = np.linalg.inv(X.T @ X); b = XtXi @ X.T @ y; e = y - X @ b
    return dict(coef=b, resid=e, XtXi=XtXi, X=X)

def vcov_hc0(f):
    Xe = f["X"] * f["resid"][:, None]
    return f["XtXi"] @ (Xe.T @ Xe) @ f["XtXi"]

def wald(b, V, idx):
    bb = b[idx]; st = bb @ np.linalg.solve(V[np.ix_(idx, idx)], bb)
    return st, len(idx), stats.chi2.sf(st, len(idx))

def pp_ztau(x, trend=False, l=4):
    x = x[~np.isnan(x)]; dx = np.diff(x); xl = x[:-1]; n = len(dx)
    cols = [np.ones(n)] + ([np.arange(1, n + 1)] if trend else []) + [xl]
    X = np.column_stack(cols); f = ols(dx, X); u = f["resid"]; k = X.shape[1]
    s2 = u @ u / (n - k); se = np.sqrt(s2 * f["XtXi"][k-1, k-1]); t = f["coef"][k-1] / se
    g0 = u @ u / n; lam2 = g0
    for j in range(1, l + 1):
        lam2 += 2 * (1 - j / (l + 1)) * (u[j:] @ u[:-j]) / n
    return np.sqrt(g0 / lam2) * t - 0.5 * (lam2 - g0) / np.sqrt(lam2) * n * se / np.sqrt(s2)

def fit_var(w, S, p):
    Z = np.column_stack([lagv(w, k) for k in range(p)] + [lagv(S, k) for k in range(p)])
    w1 = np.r_[w[1:], np.nan]; S1 = np.r_[S[1:], np.nan]
    ok = ~np.isnan(Z).any(1) & ~np.isnan(w1) & ~np.isnan(S1)
    Z = Z[ok]; X = np.column_stack([np.ones(len(Z)), Z]); Y = np.column_stack([w1[ok], S1[ok]])
    XtXi = np.linalg.inv(X.T @ X); B = XtXi @ X.T @ Y; E = Y - X @ B
    return dict(B=B, E=E, X=X, Y=Y, Z=Z, XtXi=XtXi, n=len(Z), Sigma=E.T @ E / len(Z))

def companion(B, p):
    m = 2 * p; A = np.zeros((m, m)); A[0] = B[1:, 0]; A[p] = B[1:, 1]
    for i in range(1, p):
        A[i, i-1] = 1; A[p+i, p+i-1] = 1
    return A

def cs_stats(A, Sigma, Zc, Sact, p, theta, delta, lam):
    m = 2 * p; h = np.zeros(m); h[0] = 1
    k = theta * lam * h @ A @ np.linalg.inv(np.eye(m) - delta * A)
    Sp = Zc @ k; cw = theta * lam / delta
    ma = np.array([cw, 1.0]); mt = np.array([k[0] + cw, k[p]])
    return np.var(Sact, ddof=1) / np.var(Sp, ddof=1), np.corrcoef(Sact, Sp)[0, 1], \
           (ma @ Sigma @ ma) / (mt @ Sigma @ mt), k

def cs_analysis(w, S, p, theta, delta, lam):
    f = fit_var(w, S, p); K = f["X"].shape[1]
    cw = theta * lam / delta
    xi1 = f["Y"][:, 1] - f["Z"][:, p] / delta + cw * f["Y"][:, 0]
    fx = ols(xi1, f["X"]); Vx = vcov_hc0(fx)
    A = companion(f["B"], p); Zc = f["Z"] - f["Z"].mean(0)
    vr, cr, ir, k = cs_stats(A, f["Sigma"], Zc, f["Z"][:, p], p, theta, delta, lam)
    return dict(wald_com=wald(fx["coef"], Vx, list(range(K))),
                wald_sem=wald(fx["coef"], Vx, list(range(1, K))),
                vr=vr, cr=cr, ir=ir, A=A, k=k)

# ---------------- simulação de um modelo de valor presente verdadeiro --------
def simula(T, theta, delta, lam, phi=0.3, rho=0.8, mu=0.02, seed=0, burn=200):
    """w_{t+1} = mu + phi (w_t-mu) + q_t + e;  q_{t+1} = rho q_t + eta.
    O mercado observa q_t (informação que o econometrista não vê).
    S_t = theta*lam * sum_j delta^{j-1} E_t w_{t+j}  (+ média)."""
    rng = np.random.default_rng(seed)
    M = np.array([[phi, 1.0], [0.0, rho]])
    a = theta * lam * np.array([1.0, 0.0]) @ M @ np.linalg.inv(np.eye(2) - delta * M)
    n = T + burn; w = np.zeros(n); q = np.zeros(n); w[0] = mu
    for t in range(n - 1):
        w[t+1] = mu + phi * (w[t] - mu) + q[t] + 0.1 * rng.standard_normal()
        q[t+1] = rho * q[t] + 0.05 * rng.standard_normal()
    S = theta * lam * mu / (1 - delta) + a @ np.vstack([w - mu, q])
    return w[burn:], S[burn:]

if __name__ == "__main__":
    print("== Teste 1: uma amostra grande, ações (lambda=1), theta=12.195 ==")
    th = 12.195; d = th / (1 + th)
    w, S = simula(20000, th, d, 1.0, seed=1)
    r = cs_analysis(w, S, 1, th, d, 1.0)
    print(f"var ratio {r['vr']:.4f}  corr {r['cr']:.4f}  innov {r['ir']:.4f}  "
          f"Wald sem média p={r['wald_sem'][2]:.3f}  com média p={r['wald_com'][2]:.3f}")

    print("== Teste 2: juros (lambda=delta), theta=1, delta=1/(1+.0587/12) ==")
    d = 1 / (1 + 0.0587 / 12)
    w, S = simula(20000, 1.0, d, d, phi=0.2, rho=0.95, mu=0.0, seed=2)
    r = cs_analysis(w, S, 2, 1.0, d, d)
    print(f"var ratio {r['vr']:.4f}  corr {r['cr']:.4f}  innov {r['ir']:.4f}  "
          f"Wald sem média p={r['wald_sem'][2]:.3f}")

    print("== Teste 3: tamanho do teste de Wald (T=115, p=2, 2000 réplicas) ==")
    th = 12.195; d = th / (1 + th); rej_s = rej_c = 0; R = 2000
    for s in range(R):
        w, S = simula(115, th, d, 1.0, seed=100 + s)
        r = cs_analysis(w, S, 2, th, d, 1.0)
        rej_s += r["wald_sem"][2] < 0.05; rej_c += r["wald_com"][2] < 0.05
    print(f"rejeição a 5%: sem média {rej_s/R:.3f}  com média {rej_c/R:.3f} "
          "(HC0 em amostra pequena tende a sobre-rejeitar um pouco)")

    print("== Teste 4: H1 — preço com ruído persistente (excesso de volatilidade) ==")
    rng = np.random.default_rng(9)
    w, S = simula(20000, th, d, 1.0, seed=3)
    u = np.zeros_like(S)
    for t in range(1, len(S)):
        u[t] = 0.9 * u[t-1] + 2 * rng.standard_normal()
    r = cs_analysis(w, S + u, 2, th, d, 1.0)
    print(f"var ratio {r['vr']:.2f}  corr {r['cr']:.3f}  innov {r['ir']:.2f}  "
          f"Wald p={r['wald_sem'][2]:.2e}  (deve rejeitar, razões > 1)")

    print("== Teste 5: PP Z(t) ==")
    rng = np.random.default_rng(5)
    rw = np.cumsum(rng.standard_normal(500)); ar = np.zeros(500)
    for t in range(1, 500):
        ar[t] = 0.5 * ar[t-1] + rng.standard_normal()
    print(f"passeio aleatório: {pp_ztau(rw):.2f} / {pp_ztau(rw, True):.2f} (não rejeitar)")
    print(f"AR(0.5):          {pp_ztau(ar):.2f} / {pp_ztau(ar, True):.2f} (rejeitar)")
