# Histórico de Simulados

**Resumo do Escopo:** Visualização métrica das provas já finalizadas, focada no acompanhamento a longo prazo da performance do aluno.

## 1 — Queries de Histórico no Model Exam (TDD)

**Tipo:** Teste / Model / Query
**Depende de:** 04-fluxo-simulados.md (Task 5)
**Estimativa:** Baixa

**O que fazer:**
Preparar buscas no banco específicas para renderizar resumos de histórico e agregações.

**Detalhes técnicos:**
- **Teste Primeiro:** `exam_query_spec.rb` ou `exam_spec.rb` para as buscas do histórico (apenas provas `status: 'finished'`, ordenadas de forma decrescente).
- Utilizar a regra de negócio de manter queries fora de controllers: criar escopos expressivos no Model `Exam`.

**Critério de conclusão:**
Model `Exam` responde com coleção correta de histórico ordenado cronologicamente, validado 100% no teste de unidade.

## 2 — View: Histórico de Simulados (TDD)

**Tipo:** Teste / Controller / View
**Depende de:** 1
**Estimativa:** Média

**O que fazer:**
Criar a listagem histórica focada na análise de evolução do estudante.

**Detalhes técnicos:**
- **Teste Primeiro:** `history_request_spec.rb` simulando acesso com usuário logado para uma rota de `/history` (ou index de exams).
- Basear-se na tela `/verbena/.agents/design/hist_rico_de_simulados/`.
- Criar `HistoryController` para tratar essa listagem limpa (ou usar o index de ExamsController caso prefira a convenção RESTful padrão para visualizar o agrupamento das próprias provas).
- Mostrar scores globais, cartões das provas passadas e evolução. Nenhuma lógica pesada instanciada ou resolvida dentro do arquivo `.html.erb`.

**Critério de conclusão:**
A tela é renderizada fiel ao design system, com dados testados localmente e todas as rotas/controllers devidamente cobertas pelas specs.
