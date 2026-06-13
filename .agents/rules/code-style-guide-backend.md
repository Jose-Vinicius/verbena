---
trigger: always_on
---

# Code Rules — Backend Ruby on Rails 8

## Estrutura geral

Seguir a convenção REST do Rails sem sobrescrever sem motivo. Controllers finos, regras de negócio fora deles. Cada classe com uma responsabilidade clara.

---

## Controllers

Responsabilidade única: receber a requisição, delegar e responder. Sem lógica de negócio, sem queries diretas, sem manipulação de dados.

Usar `before_action` para autenticação e carregamento de recursos. Respostas sempre explícitas com status HTTP correto. Parâmetros sempre sanitizados via `strong parameters`.

---

## Services

Toda lógica de negócio vive em service objects dentro de `app/services`. Um service faz uma coisa só. O nome descreve a ação: `GenerateQuestionsService`, `CreateExamService`, `CalculateExamResultService`.

A interface padrão é um método `.call`. O retorno é sempre um objeto de resultado com sucesso/falha e os dados ou erros — evita o uso de exceções para controle de fluxo.

---

## Jobs

Ficam em `app/jobs`. Não contêm lógica — apenas chamam o service correspondente. Idempotentes sempre que possível. Configurar `retry` com limite explícito e tratar o caso de falha atualizando o status do summary para `error`.

---

## Models

Apenas validações, associações, escopos e callbacks simples. Sem lógica de negócio. Escopos nomeados para as queries mais usadas: `Question.by_subject`, `Exam.in_progress`, `Summary.pending`.

Callbacks somente para operações diretamente ligadas ao ciclo de vida do modelo — sem side effects como enviar e-mail ou chamar API dentro de callback.

---

## Queries

Sem queries soltas em controllers ou services. Queries complexas encapsuladas em escopos no model ou em query objects em `app/queries`. Nunca usar `where` com interpolação de string — sempre placeholders ou hash syntax para evitar SQL injection.

---

## Serializers

Usar serializers em `app/serializers` apenas quando necessário formatar dados para respostas Turbo Stream ou para contexts específicos. Para renderização convencional de views, usar helpers e presenters em `app/presenters`.

---

## Autenticação

Usar Devise com a gem `devise`. Como o front é acoplado via Hotwire, a autenticação é baseada em sessão com cookies — sem necessidade de JWT.

O model `User` gerado pelo Devise habilitando apenas os módulos necessários: `:database_authenticatable`, `:registerable`, `:validatable`, `:rememberable` e `:recoverable`.

O Devise funciona nativamente com Hotwire. Sobrescrever os controllers apenas quando houver necessidade real de customizar o comportamento padrão.

Usar o `before_action :authenticate_user!` nos controllers protegidos. O usuário autenticado fica disponível via `current_user` normalmente.

---

## Erros e respostas

Erros tratados de forma padronizada em todo o sistema. Criar um `concern` `Flashable` ou usar o flash nativo do Rails para mensagens de erro e sucesso exibidas via Hotwire.

Tratar explicitamente: recurso não encontrado (404), não autorizado (401), parâmetro inválido (422), erro interno (500).

---

## Testes

Usar RSpec. Testar services e jobs de forma isolada com mocks para chamadas externas (API da IA). Controllers testados via request specs. Models com unit specs cobrindo validações e escopos. Factories com FactoryBot, nunca fixtures.

---

## Organização de pastas

```
app/
  controllers/
  services/
  jobs/
  queries/
  presenters/
  models/
  views/
```

---

## Outras práticas

- Variáveis de ambiente via `credentials.yml.enc` do Rails, nunca hardcoded
- Rubocop configurado com as regras do `rubocop-rails` e `rubocop-rspec` rodando no CI
- Nenhum `puts` ou `p` no código — usar `Rails.logger` com o nível adequado (info, warn, error)