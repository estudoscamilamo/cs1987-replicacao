# Replicação — Campbell & Shiller (1987), *Cointegration and Tests of Present Value Models*

EAD6034 – Econometria de Séries Temporais (FEA-USP, 2026) · Trabalho final, entrega 2 (código reprodutível)
Aluna: Camila Maria de Oliveira

Campbell, J. Y.; Shiller, R. J. (1987). Cointegration and tests of present value models. *Journal of Political Economy*, 95(5), 1062–1088. https://doi.org/10.1086/261502

## Como rodar

```r
install.packages(c("readxl", "urca", "vars"))   # uma vez
```

```bash
Rscript run_all.R        # na raiz do repositório
```

Um único script regera **todas** as tabelas (`output/tables/*.csv`), as figuras (`output/figures/*.png`), um resumo navegável (`output/resultados.md`) e as versões dos pacotes (`output/sessionInfo.txt`). A semente do bootstrap está fixada em `SEMENTE <- 1987` (topo do `run_all.R`).

## Estrutura

```
run_all.R              pipeline completo (parte 1: ações; parte 2: juros; parte 3: extensão)
R/dados.R              download e montagem das séries (anual e mensal)
R/funcoes.R            Phillips–Perron, Engle–Granger, VAR, AIC, teste de Wald, spread teórico,
                       razões de variância, erros-padrão (delta e bootstrap), spread ex post
R/valores_artigo.R     números publicados no artigo, para as tabelas lado a lado
data/raw/              arquivos brutos (versionados: as fontes são revisadas ao longo do tempo)
data/processed/        séries montadas pelo script
output/                tabelas, figuras, resultados.md, sessionInfo.txt
tests/espelho_python.py  validação do método em dados simulados (ver abaixo)
```

## O que é replicado

| Artigo | Arquivo gerado | Observação |
|---|---|---|
| Tabela 1-B (raiz unitária, ações) | `tabela1B_raiz_unitaria_acoes.csv` | PP Z(t_α), l = 4, com e sem tendência; coluna `urca` como conferência |
| Tabela 2 (θ e Engle–Granger) | `tabela2_theta.csv`, `tabela2_engle_granger.csv` | três estimativas de θ |
| Tabela 3-B (teste do modelo de valor presente, ações) | `tabela3B_theta12.csv`, `tabela3B_theta31.csv`, `tabela3B_erros_padrao.csv` | θ e p do artigo; p pelo AIC; θ estimado |
| Figuras 2 e 3 | `fig2_acoes_theta12.png`, `fig3_acoes_theta31.png` | SL e SL′ em desvio da média |
| Texto p. 1082–1083 (S\* e regressão de Scott) | `expost_scott_acoes.csv`, `expost_scott_juros.csv` | |
| Tabela 1-A, Tabela 3-A, Figura 1 (juros) | `tabela1A_*.csv`, `tabela3A_*.csv`, `fig1_juros_1959_78.png` | com dados substitutos |
| **Extensão** S&P 1871–último ano | `ext_*.csv`, `ext_fig_*.png` | Tabelas 1–3, Johansen, diagnósticos do VAR, robustez |

## Dados

| Série | Fonte | Uso |
|---|---|---|
| S&P Composite (P), dividendos (D), CPI — mensal desde 1871 | Robert Shiller, `ie_data.xls` | ações |
| Treasury 20 anos (GS20), mensal | FRED | juros, taxa longa |
| T-bill 1 mês (RF), mensal | Ken French Data Library | juros, taxa curta (×12, % a.a.) |

O script tenta baixar os três arquivos para `data/raw/`. Se o download falhar (o site do Shiller mudou de endereço e hoje fica em shillerdata.com), baixe manualmente e salve com estes nomes exatos:

- `data/raw/ie_data.xls`
- `data/raw/GS20.csv` (FRED → GS20 → Download CSV)
- `data/raw/F-F_Research_Data_Factors_CSV.zip`

Depois do primeiro download, **faça commit de `data/raw/`**: é a safra que reproduz exatamente os números do repositório.

**Construção anual (p. 1074 do artigo):** Y_t = preço de janeiro ÷ índice de preços de janeiro; y_t = dividendo do ano t (total de 4 trimestres, o D de dezembro na planilha) ÷ índice médio do ano t; índice rebaseado em 1967 = 100.

## Método, em uma página

Modelo de valor presente: Y_t = θ(1−δ) Σ δ^i E_t y_{t+i} + c. Para ações, θ = δ/(1−δ).

- **Spread.** S_t = Y_t − θ y_t é estacionário se o modelo vale (y e Y são CI(1,1)). Para ações, o artigo usa SL_t = Y_t − θ y_{t−1}, porque o dividendo do ano t só é conhecido no início de t+1 (p. 1074).
- **VAR.** Em z_t = (Δy, S) com p defasagens escolhidas pelo AIC no formato da nota 26: mínimo de (−ln L + nº de parâmetros), todos os p comparados na mesma amostra.
- **Restrições (eq. 8).** Equivalem a dizer que o retorno em excesso ξ_{t+1} é imprevisível. O teste de Wald é feito como regressão de ξ_{t+1} em z_t, com covariância de White (HC0); o artigo mostra que é numericamente idêntico ao Wald da eq. (8).
  - Juros: ξ_{t+1} = S_{t+1} − S_t/δ + Δy_{t+1}
  - Ações (timing ajustado): ξ_{t+1} = SL_{t+1} − SL_t/δ + (θ/δ)Δy_t
- **Spread teórico (eq. 9).** S′_t = θλ·h′A(I − δA)⁻¹z_t, com A a matriz companheira. λ = δ para juros e λ = 1 para ações (efeito do ajuste de timing).
- **Volatilidade.** var(S)/var(S′), corr(S, S′) e var(ξ)/var(ξ′), em que ξ′ é a inovação do spread teórico (eq. 12). Os erros-padrão saem de duas formas:
  1. método delta com incerteza só nos coeficientes, como o artigo (nota 11);
  2. bootstrap recursivo dos resíduos (B = 1000, semente 1987), que também incorpora a incerteza em Σ.

## Diferenças esperadas em relação ao original (documentar na apresentação)

1. **Deflator:** o artigo usa o PPI (1967 = 100); a planilha do Shiller traz o CPI. Isso muda o nível de y e Y e, portanto, E(SL), sd(SL) e θ.
2. **Safra dos dados:** os dividendos pré-1926 de Cowles e a série do S&P foram revisados desde 1987 (ver também a nota 21 do artigo).
3. **Juros:** Salomon Brothers (20 anos) e Treasury Bulletin/WSJ (1 mês) não são públicos. O GS20 é a média mensal de taxas de vencimento constante. O RF de French é o retorno mensal da T-bill, anualizado ×12.
4. **E(S′):** aqui é calculado como θλ·E(Δy)/(1−δ), a média implícita do valor presente. Para ações, isso reproduz os números do artigo (2,56 e 16,7). Para juros, o artigo reporta E(S′) = E(Δy), uma convenção não explicada no texto.
5. **Tamanho do teste:** com T ≈ 115 e HC0, o Wald sobre-rejeita (≈ 12% a 5% na simulação abaixo). Vale lembrar ao interpretar os p-valores das ações.

## Validação do código em dados simulados

`tests/espelho_python.py` reimplementa as mesmas fórmulas em numpy e as aplica a um modelo de valor presente **verdadeiro por construção**. Nesse modelo, o mercado observa uma variável q_t que o econometrista não vê.

| Teste | Resultado |
|---|---|
| H0, ações (λ = 1), T → 10⁶ | var(S)/var(S′) = 1,004; var(ξ)/var(ξ′) = 1,003; corr = 1,000 |
| H0, juros (λ = δ), T → 10⁶ | var(S)/var(S′) = 1,004; var(ξ)/var(ξ′) = 1,006; corr = 1,000 |
| Tamanho do Wald, T = 115, 2000 réplicas | rejeição de 11,6% a 5% |
| H1 (ruído persistente no preço) | Wald p ≈ 10⁻⁸², razões > 1 |
| Phillips–Perron | passeio aleatório não rejeita; AR(0,5) rejeita |

## Extensão e robustez

- Mesmo procedimento no S&P de 1871 até o último ano com dividendo de dezembro disponível. Pergunta: a relação preço–dividendo ainda vale com a queda do payout e o aumento das recompras?
- Diagnósticos do VAR: Portmanteau, ARCH multivariado, Jarque–Bera e raízes da companheira.
- Johansen (traço) como teste de cointegração sem impor o vetor.
- Robustez:
  - p = 1…4;
  - dividendo de dezembro versus média anual;
  - θ do retorno médio versus θ da regressão de cointegração;
  - subamostra pós-guerra (1946 em diante).
