# Setup e Autenticação

**Resumo do Escopo:** Setup base do Ruby on Rails 8, com foco primordial na configuração imediata do RSpec para TDD. Na sequência, setup do Tailwind CSS e autenticação com Devise (usando padrão cookie/session para Hotwire). Inclui as telas iniciais.

## 1 — TDD Setup & Instalação do RSpec

**Tipo:** Teste / Setup
**Depende de:** nenhuma
**Estimativa:** Alta

**O que fazer:**
Instalar e configurar completamente o RSpec e FactoryBot no projeto Rails recém-criado, garantindo que a suíte de testes seja a base do desenvolvimento (TDD).

**Detalhes técnicos:**
- Adicionar `rspec-rails` e `factory_bot_rails` no Gemfile (grupo :development, :test).
- Rodar o gerador do RSpec (`rails generate rspec:install`).
- Configurar o FactoryBot no `rails_helper.rb`.
- Garantir que as regras do backend (Rubocop com rubocop-rspec) já estejam configuradas e cubram os testes.

**Critério de conclusão:**
Comando `rspec` roda sem erros. Ao gerar um model via Rails generators, os arquivos de spec correspondentes são criados automaticamente.

## 2 — Configuração do Tailwind CSS e UI Base

**Tipo:** Setup / View
**Depende de:** 1
**Estimativa:** Média

**O que fazer:**
Configurar o Tailwind CSS para o Rails 8, seguindo o padrão de utility classes e o design system definido no projeto.

**Detalhes técnicos:**
- Instalar gem `tailwindcss-rails`.
- Importar as fontes `Geist` (Modern sans-serif) e configurar as cores base do sistema (Near-black, Violet #a78bfa) no `tailwind.config.js` referenciando as diretrizes do arquivo `/verbena/.agents/design/DESIGN.md`.
- Adicionar suporte a Dark Mode "Precision in Darkness".

**Critério de conclusão:**
Classes utilitárias do Tailwind e estilos customizados configurados no `.agents/design/DESIGN.md` refletem corretamente na tela ao renderizar uma view simples.

## 3 — User Model e Devise (TDD)

**Tipo:** Teste / Model / Setup
**Depende de:** 1, 2
**Estimativa:** Média

**O que fazer:**
Utilizando TDD, escrever os testes base para o User model e depois gerar e configurar a autenticação com Devise.

**Detalhes técnicos:**
- **Teste Primeiro:** Criar `spec/models/user_spec.rb` testando validações de email e senha antes do model existir (verificar falha).
- Gerar o Devise (gem `devise`).
- Criar o model `User` apenas com módulos necessários: `:database_authenticatable`, `:registerable`, `:validatable`, `:rememberable` e `:recoverable`.
- Sem JWT, utilizando session/cookies nativamente para funcionar bem com Hotwire.

**Critério de conclusão:**
Specs do User model passando. Comando `rails db:migrate` roda com sucesso. Rotas `/users/sign_in` e `/users/sign_up` disponíveis.

## 4 — TDD das Rotas e Login View

**Tipo:** Teste / View / Rota
**Depende de:** 3
**Estimativa:** Média

**O que fazer:**
Escrever Request Specs garantindo os acessos protegidos, e em seguida implementar a view de Login/Signup customizada.

**Detalhes técnicos:**
- **Teste Primeiro:** Request Spec para acessar a rota raiz não autenticado, esperando redirecionamento para o login.
- Implementar as views do Devise baseadas no HTML de referência `/verbena/.agents/design/login/`.
- Uso exclusivo do Tailwind e design minimalista sem distrações.
- Tratamento de mensagens flash (Erros 401, 422) amigáveis ao Turbo.

**Critério de conclusão:**
Usuário consegue se cadastrar, fazer login e lidar com validações de erro diretamente na view estilizada via Turbo. Specs verdes.

## 5 — TDD do Dashboard (Layout Base)

**Tipo:** Teste / Controller / View
**Depende de:** 4
**Estimativa:** Média

**O que fazer:**
Escrever Request Specs para o Dashboard autenticado e implementar o layout base da aplicação (side-bar).

**Detalhes técnicos:**
- **Teste Primeiro:** Escrever `spec/requests/dashboard_spec.rb` para garantir que o usuário autenticado acessa o Dashboard com sucesso (200).
- Controller `DashboardController#index`.
- Implementar o `application.html.erb` com o side-bar e estrutura principal seguindo `/verbena/.agents/design/dashboard/`.
- Proteger controller com `before_action :authenticate_user!`.

**Critério de conclusão:**
Usuário faz login e é redirecionado para o Dashboard com a interface completa do side-bar e visual dark responsivo. Testes rodando com sucesso.
