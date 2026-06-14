# Fluxo de Simulados

**Resumo do Escopo:** Criação do sistema de simulados (Exam). Configuração, validação de regras de negócio, carregamento contínuo via Turbo Frames (1 pergunta por vez) e finalização.

## 1 — Exam e ExamQuestion Models (TDD)

**Tipo:** Teste / Model / Migration
**Depende de:** 03-banco-de-questoes.md (Task 1)
**Estimativa:** Média

**O que fazer:**
Criar a modelagem base e validações para garantir o salvamento da prova do estudante.

**Detalhes técnicos:**
- **Teste Primeiro:** Escrever specs para relações 1:N com subject/user/questions.
- `Exam`: `user_id`, `subject_id`, `questions_count`, `correct_count`, `status` (in_progress, finished).
- `ExamQuestion`: `exam_id`, `question_id`, `chosen_index`, `is_correct`.
- Índices de performance: `exam_id` em `exam_questions`. `user_id + status` em `exams`.

**Critério de conclusão:**
Testes verdes provando que os models interagem corretamente.

## 2 — CreateExamService e ExamsController (TDD)

**Tipo:** Teste / Service / Controller
**Depende de:** 1
**Estimativa:** Alta

**O que fazer:**
Encapsular a regra complexa de geração do exame, sorteando questões válidas, via um Service Object.

**Detalhes técnicos:**
- **Teste Primeiro:** `create_exam_service_spec.rb`. Testar o contexto "Falha: subject sem perguntas suficientes" e "Sucesso: simulado instanciado com questions randomizadas".
- O Service `CreateExamService` realiza queries seguras com placeholders e não gera exceptions de controle de fluxo. Ele devolve um Result object.
- `ExamsController` aciona esse Service ao receber a request `create`.

**Critério de conclusão:**
Regras lógicas completamente isoladas no Service, validadas via RSpec, controller fino.

## 3 — View de Configurar Simulado

**Tipo:** View
**Depende de:** 2
**Estimativa:** Média

**O que fazer:**
Interface onde o usuário configura o exame (Matéria, Quantidade).

**Detalhes técnicos:**
- HTML de base em `/verbena/.agents/design/configurar_simulado/`.
- Uso de `form_with` normal apontando para `exams#create`.
- Caso falhe (poucas questões), Turbo exibe o alerta (Flashable nativo) amigável.

**Critério de conclusão:**
Visualização fidedigna que envia os dados corretamente para inicialização da prova.

## 4 — View: Simulado em Andamento (Turbo Frames)

**Tipo:** View / Frame
**Depende de:** 3
**Estimativa:** Alta

**O que fazer:**
Navegação entre questões da prova usando Turbo Frames estritos sem recarregar toda a página a cada clique.

**Detalhes técnicos:**
- **Teste Primeiro:** System Specs provando que `div#exam_frame` responde independentemente de reload global.
- HTML de base `/verbena/.agents/design/simulado_em_andamento/`.
- Cria-se um `<turbo-frame id="exam_question_frame">` em volta da questão.
- O clique de resposta atinge uma rota (ex: `ExamQuestionsController#update`) que responde com o mesmo frame contendo a reposta (Certo/Errado) em tempo real e habilitando a "Próxima".
- Quando o frame avança, ele substitui apenas a div principal.

**Critério de conclusão:**
A navegação ocorre com rapidez absurda por utilizar Turbo Frames nativamente, proporcionando foco e precisão.

## 5 — CalculateExamResultService e Resultado View (TDD)

**Tipo:** Teste / Service / View
**Depende de:** 4
**Estimativa:** Média

**O que fazer:**
Service Object para somar métricas e fechar o Exam, e a página finalística do exame.

**Detalhes técnicos:**
- **Teste Primeiro:** `calculate_exam_result_service_spec.rb` valida fechamento de prova e verificação se is_correct das filhas estão consolidados em correct_count.
- Ao clicar em "Finalizar/Última", o form instrui via Turbo Drive (ou `_top` se em frame) o redirecionamento final para `/exams/:id/result`.
- Implementar a view `/verbena/.agents/design/resultado_do_simulado/` mostrando os scores.

**Critério de conclusão:**
Service calcula nota real, altera status do DB para "finished" e exibe tela final sem distorções visuais.
