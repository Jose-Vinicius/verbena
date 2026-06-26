# Verbena — Documentação do Sistema

O **Verbena** é uma plataforma educacional interativa de geração de simulados e questionários baseada em Inteligência Artificial, projetada para otimizar o estudo e a repetição espaçada por meio de testes dinâmicos e colaborativos.

---

## 🏗 Stack Tecnológico

*   **Backend:** Ruby on Rails 8
*   **Frontend:** Hotwire (Turbo Drive, Turbo Frames, Turbo Streams), Stimulus.js, Tailwind CSS
*   **Banco de Dados:** SQLite (Dev/Test) / PostgreSQL (Produção)
*   **Jobs/Background:** Solid Queue & Solid Cache
*   **Autenticação:** Devise (Sessões via Cookies)

---

## 🚀 Funcionalidades e Módulos Principais

### 1. Gestão de Resumos e Geração de Questões via IA
*   **Fluxo de Criação:** O usuário envia um texto (resumo) na plataforma vinculando-o a uma matéria (Subject).
*   **Background Jobs:** O `GenerateQuestionsService` delega a leitura do texto para uma Inteligência Artificial via Background Job (`GenerateQuestionsJob`), que processa o texto e extrai perguntas de múltipla escolha.
*   **Feedback em Tempo Real:** Uma UI com progress bar (via Turbo Streams e Stimulus) avisa o usuário do andamento da geração de questões em background sem precisar recarregar a página.

### 2. Banco de Questões Inteligente
*   **Gestão (CRUD):** Visualização em formato de acordeão, com opções de edição de enunciados, alternativas e explicação. 
*   **Regra de Imutabilidade Parcial:** É estritamente proibido alterar o número de opções de uma pergunta para garantir a integridade de simulados passados.
*   **Soft Delete:** Exclusões apenas marcam `deleted_at`. As questões deletadas deixam de aparecer em novos sorteios, mas continuam existindo para manter o histórico de simulados antigos intacto.
*   **Métricas de Desempenho:** Cada questão rastreia quantas vezes foi respondida (`times_answered`) e o timestamp da última vez (`last_answered_at`).

### 3. Simulados Individuais (Exams)
*   **Geração Inteligente:** O sistema escolhe X perguntas baseado nas métricas da questão. Ele atua como um sistema de repetição espaçada, priorizando **questões nunca respondidas** ou **respondidas há muito tempo**.
*   **Experiência de Resolução:** Interface focada, limpa, mostrando uma questão por vez.
*   **Resultados e Revisão:** Ao finalizar, o usuário tem acesso a um card de resultado (Percentual de acertos, Total Corretas/Incorretas) e uma lista detalhada mostrando o que ele respondeu e a explicação do gabarito em caso de erro.

### 4. Salas de Quiz em Grupo (Group Quizzes)
*   **Criação Rápida:** Um usuário logado cria a sala, definindo matéria e número de questões. 
*   **Link Público e Seguro:** É gerado um link público (`/quiz/TOKEN`) que não requer cadastro (sem login de usuário, sem Devise). Participantes entram apenas com o Nome e são rastreados via cookies assinados.
*   **Ciclo de Vida Controlado:**
    *   **Expiração:** Links expiram e trancam automaticamente após 90 minutos de criação.
    *   **Trancamento Manual:** O criador pode trancar a sala a qualquer momento, bloqueando novos entrantes.
*   **Sincronização em Tempo Real (Polling):** A tela do criador da sala possui Auto-refresh sem cintilação (`polling_controller.js`) que mostra quem entrou na sala e a pontuação ao vivo.
*   **Lobby de Espera:** Participantes mais rápidos entram em uma tela de "Aguarde os outros" até que todos terminem, e são automaticamente redirecionados (Turbo.visit via Polling) para a tela de Ranking Final quando o último colega termina.

---

## 📜 Regras de Arquitetura e Código

O sistema possui regras claras de desenvolvimento definidas nos guias base (`DESIGN.md`, `code-style-guide-backend.md`, `code-style-guide-frontend.md`).

### Backend (Rails)
1.  **Controllers Finos:** Responsabilidade única de receber requisições, delegar e responder. Nunca possuem regras de negócio.
2.  **Services Objects (`app/services`):** Toda lógica de negócio mora aqui (Ex: `CreateGroupQuizService`). Devem ter interface `.call` retornando objetos de sucesso/falha, evitando controle de fluxo por Exceptions.
3.  **Jobs (`app/jobs`):** Idempotentes, tratam apenas de chamar Services. Retry blocks com atualizações de status explícitas.
4.  **Models Limpos:** Somente validações, callbacks simples relacionados ao lifecycle e relacionamentos.
5.  **Queries:** Usar escopos e nunca fazer interpolação de strings em `#where`.
6.  **Timezone:** Todo o sistema opera com `America/Sao_Paulo` (GMT-3).
7.  **Autenticação:** Baseada em Cookies/Sessions, sem JWT.

### Frontend (Hotwire + Tailwind)
1.  **Turbo Drive / Frames / Streams:** 
    *   Turbo Drive ativado por padrão.
    *   Turbo Frames para pedaços de tela isolados (evitar frames aninhados em demasia).
    *   Turbo Streams apenas para broadcast de alterações visuais — jamais enviar lógica de negócios via Streams.
2.  **Stimulus.js:** Complementa o Turbo. Apenas comportamento de UI. Usar eventos customizados para comunicação inter-controllers; usar Values/Targets; NUNCA usar `document.querySelector` dentro do controller.
3.  **Estilização (Tailwind CSS):** 
    *   Não inventar CSS customizado sem necessidade extrema.
    *   Seguir o `DESIGN.md` como fonte da verdade absoluta (Cores Dark, Aspecto Premium Glassmorphism, Micro-animações).
    *   Partials com ID padrão Rails (ex: `dom_id(@question)`).
4.  **Formulários:** Usam form helpers do Rails. A resposta de erro `422 Unprocessable Entity` ativa automaticamente o re-render com as mensagens de erro padrão do Rails.
