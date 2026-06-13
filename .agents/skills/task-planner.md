---
name: task-planner
description: Analisa partes do sistema e gera tasks detalhadas de implementação prontas para uso. Use esta skill sempre que o usuário quiser planejar, decompor ou criar tasks de implementação para qualquer parte do sistema — seja uma feature, um model, um controller, uma tela, um job, uma integração ou qualquer outro componente. Também deve ser ativada quando o usuário mencionar palavras como "tasks", "tarefas", "implementar", "planejar implementação", "o que preciso fazer para", "por onde começo", "próximos passos" em contexto de desenvolvimento.
---

# Task Planner — Geração de Tasks de Implementação

Skill para analisar uma parte do sistema e gerar tasks claras, ordenadas e prontas para execução.

---

## Contexto do projeto

Leia o contexto no arquivo `/var/home/josevinicius/data/Projects/verbena/.agents/context.md`

Antes de gerar as tasks, ler os seguintes arquivos de referência quando disponíveis:

- `/verbena/.agents/design/DESIGN.md` — design system visual
- `docs/code-rules-backend.md` — regras do backend
- `docs/code-rules-frontend.md` — regras do frontend
- Schema do banco definido no projeto

---

## Processo

### 1. Entender o escopo

Identificar qual parte do sistema será implementada. Pode ser:

- Um **model** e suas migrações
- Um **fluxo completo** (ex: envio de resumo, geração de questões)
- Uma **tela** específica
- Um **job** de background
- Uma **integração** externa (ex: API da IA)
- Um **conjunto de rotas e controllers**

Se o escopo não estiver claro, fazer uma pergunta única e direta antes de prosseguir.

### 2. Analisar dependências

Antes de gerar as tasks, mapear:

- O que precisa existir antes desta parte funcionar
- Quais models, serviços ou jobs são pré-requisitos
- Se há telas que dependem de dados ainda não existentes

### 3. Gerar as tasks

Cada task deve seguir este formato:

```
## [NÚMERO] — [TÍTULO CURTO]

**Tipo:** Migration | Model | Controller | Service | Job | View | Stimulus | Rota | Teste
**Depende de:** [número das tasks anteriores ou "nenhuma"]

**O que fazer:**
Descrição clara e direta do que deve ser implementado. Sem ambiguidade.

**Detalhes técnicos:**
- Pontos específicos de implementação
- Campos, métodos, escopos ou validações relevantes
- Convenções a seguir das code rules

**Critério de conclusão:**
Como saber que esta task está pronta.
```

### 4. Ordenar corretamente

As tasks devem seguir a ordem de dependência real:

1. Migrações e models base
2. Associações e validações
3. Services e jobs
4. Controllers e rotas
5. Views e partials
6. Stimulus controllers (se necessário)

Nunca gerar uma task de view antes das tasks de model e controller correspondentes.

---

## Regras de geração

- Cada task deve ser **atômica** — uma coisa só, que pode ser feita e revisada de forma independente
- Tasks não devem ser genéricas demais ("implementar o model") nem granulares demais ("adicionar um campo")
- O título deve deixar claro o que será entregue: "Criar migration e model Question com campos e validações"
- Sempre referenciar as code rules quando relevante: "seguindo o padrão de service object definido nas code rules"
- Se a task envolve uma tela, referenciar o HTML de referência correspondente em `/verbena/.agents/design/<tela>/`
- Tasks de Stimulus só devem aparecer quando o Turbo não resolver sozinho

---

## Saída esperada

Entregar:

1. **Resumo do escopo** — o que será implementado e quais são as dependências externas
2. **Lista de tasks ordenadas** — no formato acima
3. **Estimativa de complexidade** por task: Baixa / Média / Alta

Após gerar as tasks, salvá-las obrigatoriamente em `.agents/tasks/` como um arquivo markdown. O nome do arquivo deve descrever o escopo: `fluxo-envio-resumo.md`, `model-question.md`, `tela-simulado.md`. Cada arquivo contém apenas as tasks referentes àquele escopo.

---

## Exemplo de uso

**Usuário:** "Preciso das tasks para implementar o fluxo de envio de resumo"

**Skill deve gerar tasks cobrindo:**
- Migration e model Summary
- Validações e associações (User, Subject)
- SummaryController com action create
- GenerateQuestionsJob
- GenerateQuestionsService (chamada à IA, salvar questões)
- Rota para criação
- View do formulário (referenciando `/verbena/.agents/design/enviar_resumo/`)
- View da barra de progresso (referenciando `/verbena/.agents/design/gerando_quest_es/`)
- Stimulus controller para polling de progresso