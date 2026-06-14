# Banco de Questões

**Resumo do Escopo:** Criação do repositório central de questões, onde os usuários visualizam o que foi gerado em agrupamentos por matéria (Subject).

## 1 — Question Model (TDD)

**Tipo:** Teste / Model / Migration
**Depende de:** 02-fluxo-envio-resumo.md (Task 1)
**Estimativa:** Média

**O que fazer:**
Testar o model `Question` com sua estrutura de dados complexa (jsonb) e gerar o arquivo de banco de dados e migração.

**Detalhes técnicos:**
- **Teste Primeiro:** Escrever `question_spec.rb` validando presença de statement, format do array jsonb em options, e bounds do `correct_index`.
- Campos: `summary_id`, `subject_id` (denormalizado para agilidade), `statement`, `options` (jsonb array 4 ou 5 posições), `correct_index` (int), e `explanation`.
- Criar o índice recomendado: `subject_id` em `questions`.
- Criar scope `Question.by_subject` nomeado.

**Critério de conclusão:**
Banco migrado, specs criados e passando com sucesso. Regras de modelo blindadas de salvar JSONB inválido.

## 2 — QuestionsController e Scopes (TDD)

**Tipo:** Teste / Controller / Rota
**Depende de:** 1
**Estimativa:** Baixa

**O que fazer:**
Desenvolver os testes de requisição e o controller de listagem do banco de questões.

**Detalhes técnicos:**
- **Teste Primeiro:** `questions_request_spec.rb` para a action `#index`.
- Operações restritas à leitura (index). O controller carrega as questões agrupadas pelo escopo `by_subject`.
- Nenhuma query manual `where` no controller. Tudo delegado para o modelo.

**Critério de conclusão:**
Acesso à rota `/questions` retorna sucesso (200) para o usuário autenticado e a variável de coleção correta no spec.

## 3 — View: Banco de Questões

**Tipo:** View
**Depende de:** 2
**Estimativa:** Média

**O que fazer:**
Criar a página HTML que consolida as questões categorizadas por matérias.

**Detalhes técnicos:**
- Utilizar como base o diretório `/verbena/.agents/design/banco_de_quest_es/`.
- Foco em tipografia Geist e layout limpo utilitário via Tailwind.
- A página exibe blocos (cards) com as perguntas disponíveis.

**Critério de conclusão:**
Interface gerada sendo fiel aos tokens do design system `DESIGN.md`.

## 4 — View: Modo de Revisão (Toggle de Respostas)

**Tipo:** View / Stimulus
**Depende de:** 3
**Estimativa:** Baixa

**O que fazer:**
Permitir expandir cada pergunta do banco para revelar as alternativas, a correta e a explicação, garantindo interatividade no cliente.

**Detalhes técnicos:**
- System Specs para verificar o comportamento de toggle (abrindo e fechando o conteúdo da explicação).
- O recomendado é testar `<details>` nativo do HTML ou construir um controlador Stimulus básico `toggle_controller.js` para adicionar/remover classes `.hidden`.
- O Turbo não deve ser usado aqui, pois a manipulação é puramente local e de interface.
- Destacar a alternativa correta na UI com a cor Accent (Violet #a78bfa).

**Critério de conclusão:**
Expand/collapse visual suave. Usuário clica na pergunta e consegue ver a explicação detalhada.
