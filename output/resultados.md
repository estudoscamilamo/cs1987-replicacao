# Resultados da replicação de Campbell e Shiller (1987)

Gerado por `run_all.R` em 2026-11-19 13:21

# Parte 1: mercado de ações, 1871-1986

## Tabela 2: estimação de theta (replicação x artigo)

| metodo | equacao | R2 | theta | taxa_desconto | R2_orig | theta_orig | taxa_desconto_orig |
|---|---|---|---|---|---|---|---|
| 1. Regressão de cointegração (Y_t em y_t) | Y = -14.681 + 31.647 y | 0.833 | 31.65 | 0.0316 | 0.842 | 31.09 | 0.032 |
| 2. Regressão de correção de erros (Dy_t) | Dy = 0.126 + 0.154 Dy(-1) + 0.009 DY - 0.183 y(-1) + 0.0049 Y | 0.376 | 37.74 | 0.0265 | 0.373 | 37.02 | 0.027 |
| 3. Retorno médio da amostra | retorno médio = 8.00% |  |  12.5 |  0.08 |  |  12.2 | 0.082 |


## Tabela 2 (nota): testes de Engle-Granger para não cointegração

| teste | replicacao | original | cv_10 | cv_5 | cv_1 |
|---|---|---|---|---|---|
| xi2 (DF no resíduo) | -3.79 | -3.58 | -3.03 | -3.37 | -4.07 |
| xi3 (ADF(4) no resíduo) | -3.19 | -2.64 | -2.84 | -3.17 | -3.77 |


## Tabela 1-B: Phillips-Perron Z(t_alpha), l = 4, theta do artigo

| variavel | n | Z_tendencia | sig_tendencia | Z_sem_tendencia | sig_sem_tendencia | urca_tendencia | urca_sem_tendencia | Z_tendencia_orig | Z_sem_tendencia_orig |
|---|---|---|---|---|---|---|---|---|---|
| y_t |   116 | -3.02 |  | -1.41 |  | -3.02 | -1.41 | -2.88 | -1.28 |
| Y_t |   116 | -2.44 |  | -1.52 |  | -2.44 | -1.52 | -2.19 | -1.53 |
| Dy_t |   115 |  -8.8 | 1% | -8.85 | 1% |  -8.8 | -8.85 |  -8.4 | -8.44 |
| DY_t |   115 | -10.48 | 1% | -10.53 | 1% | -10.48 | -10.54 | -9.91 | -9.96 |
| SL_t (theta=31.092) |   115 | -4.69 | 1% |  -4.7 | 1% | -4.69 |  -4.7 | -4.35 | -4.31 |
| xi_t (theta=31.092) |   114 | -10.46 | 1% | -10.52 | 1% | -10.47 | -10.52 | -9.93 | -9.99 |
| SL_t (theta=12.195) |   115 | -2.94 |  | -2.13 |  | -2.94 | -2.14 | -2.68 | -2.15 |
| xi_t (theta=12.195) |   114 | -10.26 | 1% | -10.21 | 1% | -10.27 | -10.21 | -9.76 | -9.69 |


## Tabela 1-B com os theta estimados nesta replicação

| variavel | n | Z_tendencia | sig_tendencia | Z_sem_tendencia | sig_sem_tendencia | urca_tendencia | urca_sem_tendencia |
|---|---|---|---|---|---|---|---|
| y_t |   116 | -3.02 |  | -1.41 |  | -3.02 | -1.41 |
| Y_t |   116 | -2.44 |  | -1.52 |  | -2.44 | -1.52 |
| Dy_t |   115 |  -8.8 | 1% | -8.85 | 1% |  -8.8 | -8.85 |
| DY_t |   115 | -10.48 | 1% | -10.53 | 1% | -10.48 | -10.54 |
| SL_t (theta=31.647) |   115 | -4.74 | 1% | -4.74 | 1% | -4.74 | -4.74 |
| xi_t (theta=31.647) |   114 | -10.46 | 1% | -10.52 | 1% | -10.47 | -10.52 |
| SL_t (theta=12.504) |   115 | -2.96 |  | -2.16 |  | -2.96 | -2.16 |
| xi_t (theta=12.504) |   114 | -10.27 | 1% | -10.23 | 1% | -10.28 | -10.23 |


## Tabela 3-B: theta = 12.195 (8,2%), artigo x replicação

| estatistica | original | theta e p do artigo | p pelo AIC | theta estimado (ret. médio) |
|---|---|---|---|---|
| p (AIC no artigo) |     4 |     4 |     3 |     3 |
| R2 eq. Dy |   0.4 | 0.3774 | 0.3453 | 0.3455 |
| R2 eq. S | 0.837 | 0.8314 | 0.8296 | 0.8262 |
| p-valor: S Granger-causa Dy | 1e-05 | 3.607e-07 | 9.436e-07 | 9.156e-07 |
| p-valor: Dy Granger-causa S | 0.633 | 0.5013 | 0.5521 | 0.5563 |
| Wald VP sem restrição de média | 15.72 |  18.1 | 17.32 | 17.14 |
|   p-valor | 0.047 | 0.02049 | 0.008162 | 0.008796 |
| Wald VP com restrição de média | 15.74 | 18.26 | 17.35 | 17.14 |
|   p-valor | 0.072 | 0.03222 | 0.01528 | 0.01653 |
| E(Dy) | 0.017 | 0.0136 | 0.01396 | 0.01396 |
| E(S) | 16.07 | 17.11 | 16.97 | 16.47 |
| E(S') | 2.563 | 2.189 | 2.247 | 2.358 |
| sd(Dy) | 0.168 | 0.1742 | 0.1735 | 0.1735 |
| sd(S) | 15.51 | 15.53 | 15.53 | 15.39 |
| var(S)/var(S') | 67.22 | 104.2 | 172.7 | 159.4 |
| corr(S,S') | -0.459 | -0.2097 | 0.3888 | 0.4107 |
| var(xi)/var(xi') | 11.27 |  11.9 | 10.81 | 10.32 |


## Tabela 3-B: theta = 31.092 (3,2%), artigo x replicação

| estatistica | original | theta e p do artigo | p pelo AIC | theta estimado (cointegração) |
|---|---|---|---|---|
| p (AIC no artigo) |     2 |     2 |     2 |     2 |
| R2 eq. Dy | 0.378 | 0.3769 | 0.3769 | 0.3785 |
| R2 eq. S | 0.516 | 0.5099 | 0.5099 | 0.5062 |
| p-valor: S Granger-causa Dy | 1e-05 | 2.429e-08 | 2.429e-08 | 2.293e-08 |
| p-valor: Dy Granger-causa S | 0.018 | 0.01068 | 0.01068 | 0.01066 |
| Wald VP sem restrição de média |  5.75 | 6.655 | 6.655 |  6.63 |
|   p-valor | 0.218 | 0.1553 | 0.1553 | 0.1568 |
| Wald VP com restrição de média |  14.9 | 13.63 | 13.63 | 13.66 |
|   p-valor | 0.011 | 0.01814 | 0.01814 | 0.01791 |
| E(Dy) | 0.017 | 0.01468 | 0.01468 | 0.01468 |
| E(S) | -12.52 | -13.4 | -13.4 | -14.29 |
| E(S') | 16.66 | 14.64 | 14.64 | 15.16 |
| sd(Dy) | 0.167 | 0.1728 | 0.1728 | 0.1728 |
| sd(S) | 9.937 | 10.33 | 10.33 | 10.33 |
| var(S)/var(S') | 4.786 | 4.356 | 4.356 | 4.102 |
| corr(S,S') | 0.911 | 0.9601 | 0.9601 | 0.9636 |
| var(xi)/var(xi') | 1.414 | 1.712 | 1.712 | 1.672 |


## Tabela 3-B: erros-padrão (artigo, método delta e bootstrap)

| caso | estatistica | ep_original | ep_delta | ep_bootstrap |
|---|---|---|---|---|
| Ações theta=12.195 | var(S)/var(S') | 86.04 | 88.22 | 40.61 |
| Ações theta=12.195 | corr(S,S') | 0.801 | 1.031 | 0.493 |
| Ações theta=12.195 | var(xi)/var(xi') |  4.49 | 3.765 | 4.769 |
| Ações theta=31.092 | var(S)/var(S') |  5.38 |  4.12 | 3.503 |
| Ações theta=31.092 | corr(S,S') | 0.207 | 0.088 | 0.187 |
| Ações theta=31.092 | var(xi)/var(xi') | 0.441 | 0.512 | 0.538 |


## Spread ex post SL* e regressão de Scott (p. 1082-1083)

| caso | estatistica | original | replicacao |
|---|---|---|---|
| Ações theta=12.195 | sd_Sstar | 7.928 | 7.216 |
| Ações theta=12.195 | sd_S | 15.51 | 15.49 |
| Ações theta=12.195 | coef_scott |  0.16 | 0.132 |
| Ações theta=31.092 | sd_Sstar | 12.89 | 12.97 |
| Ações theta=31.092 | sd_S | 9.937 |  10.2 |
| Ações theta=31.092 | coef_scott |  0.02 | 0.052 |


# Parte 2: estrutura a termo (dados substitutos)

## Tabela 3-A: juros 1959-78 (AIC escolheu p = 9)

| estatistica | original | p do artigo | p pelo AIC |
|---|---|---|---|
| p (AIC no artigo) |    11 |    11 |     9 |
| R2 eq. Dy | 0.216 | 0.4673 | 0.4487 |
| R2 eq. S | 0.877 | 0.7771 | 0.7717 |
| p-valor: S Granger-causa Dy | 0.0001 | 1.101e-07 | 3.027e-06 |
| p-valor: Dy Granger-causa S | 0.003 | 0.002467 | 0.0002612 |
| Wald VP sem restrição de média | 83.02 | 69.89 | 67.08 |
|   p-valor | 5e-05 | 6.879e-07 | 1.398e-07 |
| E(Dy) | 0.016 | 0.01387 | 0.01956 |
| E(S) | 1.144 | 1.211 | 1.206 |
| E(S') | 0.016 | 2.835 | 3.999 |
| sd(Dy) | 0.442 | 0.6885 | 0.692 |
| sd(S) |  1.06 | 1.075 | 1.072 |
| var(S)/var(S') | 0.987 | 1.048 | 1.204 |
| corr(S,S') | 0.978 | 0.9838 | 0.9904 |
| var(xi)/var(xi') |  1.16 | 0.7698 | 0.5242 |


## Tabela 3-A: juros 1959-83 (AIC escolheu p = 6)

| estatistica | original | p do artigo | p pelo AIC |
|---|---|---|---|
| p (AIC no artigo) |     6 |     6 |     6 |
| R2 eq. Dy | 0.171 | 0.3701 | 0.3701 |
| R2 eq. S | 0.772 | 0.6673 | 0.6673 |
| p-valor: S Granger-causa Dy | 0.003 | 2.181e-09 | 2.181e-09 |
| p-valor: Dy Granger-causa S | 0.013 | 0.001146 | 0.001146 |
| Wald VP sem restrição de média | 35.63 | 45.47 | 45.47 |
|   p-valor | 0.0003 | 8.572e-06 | 8.572e-06 |
| E(Dy) | 0.021 | 0.02219 | 0.02219 |
| E(S) | 1.138 | 1.166 | 1.166 |
| E(S') | 0.021 | 4.537 | 4.537 |
| sd(Dy) | 0.793 | 0.9556 | 0.9556 |
| sd(S) |  1.32 | 1.326 | 1.326 |
| var(S)/var(S') | 3.394 |  2.96 |  2.96 |
| corr(S,S') | 0.956 | 0.8755 | 0.8755 |
| var(xi)/var(xi') | 0.502 | 0.3046 | 0.3046 |


## Tabela 1-A: Phillips-Perron Z(t_alpha), juros

| amostra | variavel | n | Z_tendencia | sig_tendencia | Z_sem_tendencia | sig_sem_tendencia | urca_tendencia | urca_sem_tendencia | Z_tendencia_orig | Z_sem_tendencia_orig |
|---|---|---|---|---|---|---|---|---|---|---|
| 1959-78 | y_t |   236 |  -4.3 | 1% | -2.59 | 10% |  -4.3 | -2.59 | -2.78 | -1.72 |
| 1959-78 | Y_t |   236 | -2.62 |  | -0.25 |  | -2.62 | -0.25 | -2.76 | -0.46 |
| 1959-78 | Dy_t |   236 | -23.81 | 1% | -23.87 | 1% | -23.81 | -23.87 | -17.4 | -17.44 |
| 1959-78 | DY_t |   236 | -12.54 | 1% | -12.55 | 1% | -12.55 | -12.56 | -15.3 | -15.32 |
| 1959-78 | S_t |   236 | -5.05 | 1% | -4.64 | 1% | -5.05 | -4.64 | -3.15 | -3.08 |
| 1959-78 | xi_t |   236 | -12.51 | 1% | -12.53 | 1% | -12.51 | -12.53 | -15.22 | -15.25 |
| 1959-83 | y_t |   298 | -4.24 | 1% |  -2.3 |  | -4.24 |  -2.3 | -3.83 | -2.32 |
| 1959-83 | Y_t |   298 | -2.51 |  | -0.43 |  | -2.51 | -0.43 | -2.51 |  -0.5 |
| 1959-83 | Dy_t |   298 | -19.61 | 1% | -19.65 | 1% | -19.61 | -19.65 | -17.05 | -17.08 |
| 1959-83 | DY_t |   298 | -12.32 | 1% | -12.33 | 1% | -12.32 | -12.33 | -15.27 | -15.29 |
| 1959-83 | S_t |   298 | -6.25 | 1% | -6.13 | 1% | -6.25 | -6.13 | -4.77 | -4.67 |
| 1959-83 | xi_t |   298 | -12.28 | 1% | -12.3 | 1% | -12.28 | -12.3 | -15.18 | -15.19 |


## Spread ex post S* e regressão de Scott, juros 1959-78

| estatistica | original | replicacao |
|---|---|---|
| sd_Sstar | 1.217 | 1.183 |
| sd_S |  1.06 | 1.053 |
| coef_scott |  0.81 | 0.764 |


# Parte 3: extensão, S&P 1871-2025

## Extensão: Tabela 2 (1871-2025)

| metodo | equacao | R2 | theta | taxa_desconto |
|---|---|---|---|---|
| 1. Regressão de cointegração (Y_t em y_t) | Y = -64.091 + 64.516 y | 0.899 | 64.52 | 0.0155 |
| 2. Regressão de correção de erros (Dy_t) | Dy = 0.070 + 0.357 Dy(-1) + 0.002 DY - 0.053 y(-1) + 0.0008 Y | 0.268 | 62.79 | 0.0159 |
| 3. Retorno médio da amostra | retorno médio = 8.40% |  | 11.91 | 0.084 |


## Extensão: Engle-Granger

| teste | estatistica | cv_10 | cv_5 |
|---|---|---|---|
| xi2 (DF no resíduo) |  -2.6 | -3.03 | -3.37 |
| xi3 (ADF(4) no resíduo) |  -3.7 | -2.84 | -3.17 |


## Extensão: Johansen (traço), Y e y, K = 2, constante no vetor

| H0 | traco | cv_10 | cv_5 | cv_1 |
|---|---|---|---|---|
| r <= 1 |  4.94 |  7.52 |  9.24 | 12.97 |
| r = 0 | 31.27 | 17.85 | 19.96 |  24.6 |


## Extensão: raiz unitária (PP, l = 4)

| variavel | n | Z_tendencia | sig_tendencia | Z_sem_tendencia | sig_sem_tendencia | urca_tendencia | urca_sem_tendencia |
|---|---|---|---|---|---|---|---|
| y_t |   155 |  0.85 |  |   2.7 |  |  0.87 |  2.71 |
| Y_t |   155 |  3.26 |  |  4.95 |  |   3.2 |  4.91 |
| Dy_t |   154 |  -8.3 | 1% | -8.02 | 1% |  -8.3 | -8.02 |
| DY_t |   154 | -11.16 | 1% | -10.66 | 1% | -11.2 | -10.65 |
| SL_t (theta=64.516) |   154 |  -2.9 |  | -3.08 | 5% | -2.91 | -3.09 |
| xi_t (theta=64.516) |   153 | -11.18 | 1% | -10.65 | 1% | -11.22 | -10.65 |
| SL_t (theta=11.906) |   154 |  2.74 |  |   4.4 |  |  2.66 |  4.35 |
| xi_t (theta=11.906) |   153 | -12.41 | 1% | -12.47 | 1% | -12.48 | -12.54 |


## Extensão: Tabela 3 (1871-2025); theta ret. médio = 11.91, theta cointegração = 64.52

| estatistica | theta ret. médio | theta cointegração | theta=12.195 | theta=31.092 |
|---|---|---|---|---|
| p (AIC no artigo) |     8 |     8 |     8 |     8 |
| R2 eq. Dy | 0.3808 | 0.3522 | 0.3808 | 0.3817 |
| R2 eq. S | 0.968 | 0.7469 | 0.9677 | 0.9364 |
| p-valor: S Granger-causa Dy | 6.455e-07 | 0.0004913 | 6.514e-07 | 1.806e-06 |
| p-valor: Dy Granger-causa S | 0.1161 | 2.299e-06 | 0.1131 | 0.00159 |
| Wald VP sem restrição de média | 45.34 |  74.4 | 45.84 | 62.43 |
|   p-valor | 0.0001232 | 1.671e-09 | 0.0001031 | 2.027e-07 |
| Wald VP com restrição de média | 45.43 | 89.76 | 45.88 | 69.79 |
|   p-valor | 0.0002104 | 6.754e-12 | 0.0001801 | 2.343e-08 |
| E(Dy) | 0.04829 | 0.04829 | 0.04829 | 0.04829 |
| E(S) | 60.18 | -63.57 |  59.5 | 15.05 |
| E(S') |  7.42 | 204.1 |  7.77 | 48.18 |
| sd(Dy) | 0.2117 | 0.2117 | 0.2117 | 0.2117 |
| sd(S) | 90.45 | 34.71 | 90.03 | 63.84 |
| var(S)/var(S') | 7.518 | 0.6135 | 6.236 | 0.0304 |
| corr(S,S') | 0.989 | 0.1711 | 0.9888 | -0.9448 |
| var(xi)/var(xi') | 5.856 | 0.3276 | 4.999 | 0.04037 |


## Extensão: diagnósticos (autocorrelação, ARCH, normalidade, estabilidade)

| caso | p | portmanteau_p | arch_p | jarque_bera_p | max_raiz |
|---|---|---|---|---|---|
| theta ret. médio |     8 | 0.019 |     0 |     0 | 1.054 |
| theta cointegração |     8 | 0.065 |     0 |     0 | 1.014 |


## Extensão: robustez (p = 1 a 4; dividendo de dezembro x média anual)

| dividendo | theta | p | p_wald_sem_media | p_wald_com_media | var_ratio | corr | innov_ratio |
|---|---|---|---|---|---|---|---|
| dez | ret. médio (11.91) |     1 | 0.7873 | 0.8291 |  6.43 | 0.999 |  5.79 |
| dez | ret. médio (11.91) |     2 | 0.3327 | 0.2894 |  7.99 | 0.998 |  5.88 |
| dez | ret. médio (11.91) |     3 | 0.034 | 0.0368 |  5.23 | 0.997 |  6.64 |
| dez | ret. médio (11.91) |     4 | 0.0628 | 0.0665 |  3.22 | 0.995 |  5.24 |
| dez | cointegração (64.52) |     1 | 0.2587 | 0.0006 |  1.81 | 0.974 |  1.31 |
| dez | cointegração (64.52) |     2 | 0.0983 | 0.0005 |  4.79 | 0.814 |  1.18 |
| dez | cointegração (64.52) |     3 | 0.0827 | 0.0002 |  4.01 | 0.935 |  1.46 |
| dez | cointegração (64.52) |     4 | 0.0789 | 0.0001 |  3.59 |  0.91 |  1.22 |
| media | ret. médio (11.97) |     1 | 0.208 | 0.2486 |  8.03 |  0.99 |  6.32 |
| media | ret. médio (11.97) |     2 | 0.3828 | 0.4598 |  6.41 | 0.997 |  5.47 |
| media | ret. médio (11.97) |     3 |  0.02 | 0.0214 |  5.91 | 0.996 |  7.29 |
| media | ret. médio (11.97) |     4 | 0.0208 | 0.022 |  5.59 | 0.995 |  7.15 |
| media | cointegração (66.8) |     1 | 0.015 | 0.0003 |  0.81 | 0.918 |   0.7 |
| media | cointegração (66.8) |     2 | 0.0261 | 0.0001 |  5.78 | 0.797 |  1.77 |
| media | cointegração (66.8) |     3 | 0.0209 | 0.0001 |  3.06 | 0.872 |  1.23 |
| media | cointegração (66.8) |     4 | 0.0065 |     0 |  3.66 | 0.678 |     1 |


## Extensão: subamostra pós-guerra (theta do retorno médio)

| amostra | theta | p | p_wald_sem_media | var_ratio | corr | innov_ratio |
|---|---|---|---|---|---|---|
| 1946-2025 | 11.85 |     8 |     0 | 18.82 | 0.957 | 10.05 |

