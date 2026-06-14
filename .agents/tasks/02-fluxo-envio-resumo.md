# Fluxo de Envio de Resumo

**Resumo do Escopo:** Recebimento de notas e resumos textuais (até 10.000 caracteres), armazenamento em banco (Models Subject e Summary), integração da estrutura de fila com Solid Queue e polling de progresso visual (Turbo Streams).

## 1 — Subject & Summary Models (TDD)

**Tipo:** Teste / Model / Migration
**Depende de:** 01-setup-e-autenticacao.md (Task 5)
**Estimativa:** Média

**O que fazer:**
Criar specs para validar associações e campos e em seguida gerar os models de `Subject` e `Summary`.

**Detalhes técnicos:**
- **Teste Primeiro:** Escrever `subject_spec.rb` e `summary_spec.rb`.
- `Subject`: pertence ao User, tem name e validação de presença.
- `Summary`: pertence ao User e Subject, possui `content` (limite 10.000 chars), `questions_requested` (10, 20 ou 30), e `status` (pending, processing, done, error).
- Criar scope `Summary.pending` e `Summary.processing` (evitar lógica nos controllers).

**Critério de conclusão:**
Migrations rodadas, models criados com validações estritas, todos os unit specs passando.

## 2 — TDD do SummariesController

**Tipo:** Teste / Controller / Rota
**Depende de:** 1
**Estimativa:** Média

**O que fazer:**
Escrever testes de request e implementar o controller para criação e listagem básica de Summaries.

**Detalhes técnicos:**
- **Teste Primeiro:** `summaries_request_spec.rb` testando POST para criar summary, lidando com respostas HTTP apropriadas e validações (422 Unprocessable Entity).
- Usar _strong parameters_.
- Delegar o processamento (background) após a criação (sem salvar a lógica complexa no controller).

**Critério de conclusão:**
Rotas configuradas, controller responde corretamente aos requests e specs estão verdes.

## 3 — View de Envio de Resumo

**Tipo:** View / Stimulus
**Depende de:** 2
**Estimativa:** Média

**O que fazer:**
Construir o formulário de envio e integração com Turbo Streams para tratamento de erros.

**Detalhes técnicos:**
- Implementar a tela referenciando `/verbena/.agents/design/enviar_resumo/`.
- O formulário usa helper nativo `form_with`.
- Exibir mensagens de validação via Turbo Streams para falhas de formulário (422) ou render clássico.
- Criar controller Stimulus `character_count_controller.js` simples apenas para limitar e mostrar os 10.000 caracteres (pois Turbo não resolve feedback interativo de digitação em tempo real).

**Critério de conclusão:**
Usuário acessa a página, consegue colar seu texto, escolhe a quantidade de questões e a matéria, e ao submeter vê as validações corretamente ou prossegue.

## 4 — Job e Service de Geração (TDD)

**Tipo:** Teste / Job / Service
**Depende de:** 2
**Estimativa:** Alta

**O que fazer:**
Escrever testes de unidade para os services/jobs e implementar a chamada ao Solid Queue para gerar questões.

**Detalhes técnicos:**
- **Teste Primeiro:** `generate_questions_service_spec.rb` com mocks simulando resposta ou demora da API externa.
- Configurar o framework Solid Queue.
- Criar `GenerateQuestionsJob` (idempotente) que apenas chama o `GenerateQuestionsService`.
- O `GenerateQuestionsService` deve atualizar o `status` do Summary para `processing`, e depois para `done` ou `error`. (Neste estágio, o service pode ser apenas um esqueleto ou mock que salva questões fakes no banco).

**Critério de conclusão:**
Job entra na fila do Solid Queue, processa a chamada e atualiza o status do banco de dados corretamente. Cobertura de teste passando sem gargalos.

## 5 — Polling UI & Turbo Streams (TDD)

**Tipo:** Teste / View / Stream
**Depende de:** 3, 4
**Estimativa:** Alta

**O que fazer:**
Adicionar System Specs simulando o comportamento de polling e implementar a tela de processamento visual.

**Detalhes técnicos:**
- **Teste Primeiro:** Configurar system specs com Capybara para validar a mudança de estado na tela.
- Implementar a view de "Gerando Questões" referenciando `/verbena/.agents/design/gerando_quest_es/`.
- Utilizar Turbo Streams (ActionCable/broadcasts) para atualizar a tela assim que o Job do background finalizar, ou frame reloading.
- Exibir log de geração referenciando o visual de terminal do Design System.

**Critério de conclusão:**
Após submeter o resumo, a interface altera de "Processando" para "Concluído" no frontend sozinho (sem refresh manual) e testes do sistema validam essa experiência.
