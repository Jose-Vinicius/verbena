---
trigger: always_on
---

# Code Rules — Frontend com Hotwire + Tailwind

## Visão geral

O Hotwire é composto por três partes: **Turbo Drive**, **Turbo Frames** e **Turbo Streams**. Cada uma tem seu papel e não devem ser usadas indiscriminadamente — escolher a abordagem certa para cada situação é a regra principal.

---

## Turbo Drive

Responsável pela navegação sem reload completo da página. Funciona automaticamente para links e formulários — não é necessário nenhuma configuração extra.

Desabilitar o Turbo Drive apenas em casos específicos e justificados com `data-turbo="false"`. Nunca desabilitar globalmente.

---

## Turbo Frames

Usar para atualizar regiões isoladas da página sem afetar o restante. Cada frame é independente e tem seu próprio ciclo de navegação.

O `id` do frame deve ser semântico e refletir o conteúdo: `turbo-frame id="question_42"`, não `turbo-frame id="frame1"`. Frames aninhados são permitidos mas devem ser usados com parcimônia — dificultam o rastreamento do fluxo.

Formulários dentro de um frame respondem apenas dentro daquele frame por padrão. Usar `data-turbo-frame="_top"` apenas quando a resposta precisar afetar a página inteira.

---

## Turbo Streams

Usar para atualizações que afetam múltiplas regiões da página ao mesmo tempo, ou quando a resposta de um formulário precisa atualizar algo fora do frame atual.

As actions disponíveis são `append`, `prepend`, `replace`, `update`, `remove`, `before` e `after`. Escolher a mais específica para o caso — evitar `replace` quando `update` já resolve.

Streams são retornados pelo controller com `format.turbo_stream`. Manter os templates de stream em `app/views` seguindo a convenção `action.turbo_stream.erb`.

Nunca usar Turbo Streams para lógica de negócio — apenas para atualização de UI.

---

## Stimulus

Usar para comportamentos JavaScript pontuais que o Turbo não resolve sozinho: toggles, validações client-side, máscaras de input, interações visuais.

Cada controller Stimulus tem uma responsabilidade única e um nome que descreve o comportamento: `dropdown_controller.js`, `progress_controller.js`, `character_count_controller.js`.

Não replicar lógica de negócio no Stimulus — ele lida apenas com comportamento de UI. Comunicação entre controllers via `events` customizados ou via `Outlet`, nunca acessando diretamente o DOM de outro controller.

Usar `values` para passar dados do servidor para o controller e `targets` para referenciar elementos do DOM — nunca usar `querySelector` dentro de um controller Stimulus.

---

## Stimulus e Turbo juntos

O Stimulus complementa o Turbo, não compete com ele. Antes de escrever um controller Stimulus, verificar se o Turbo já resolve. A ordem de preferência é: Turbo Drive → Turbo Frames → Turbo Streams → Stimulus.

---

## Views e partials

Partials pequenas e com responsabilidade única. O nome da partial descreve o que ela renderiza, não onde ela é usada. Evitar lógica condicional complexa nas views — mover para helpers ou presenters.

Cada partial que pode ser atualizada via Turbo Stream deve ter um `id` estável e previsível no elemento raiz, seguindo o padrão do Rails: `dom_id(@question)`.

---

## Formulários

Sempre usar os helpers do Rails (`form_with`). Formulários respondem a Turbo automaticamente — não adicionar `remote: true` (legado do Rails UJS).

Exibir erros de validação via Turbo Stream na resposta do controller em caso de `422 Unprocessable Entity` — padrão esperado pelo Turbo para re-renderizar o formulário com erros.

---

## Tailwind

Usar apenas classes utilitárias do Tailwind — sem CSS customizado salvo em casos que o Tailwind não resolve.

Extrair combinações de classes repetidas para partials ou components de view, não para classes CSS customizadas. Evitar o uso de `@apply` exceto em casos muito específicos como estilização de elementos gerados por terceiros.

Seguir uma ordem consistente de classes: layout → espaçamento → tipografia → cores → bordas → estados (`hover`, `focus`, `disabled`). Usar o plugin do Tailwind para ordenação automática (`prettier-plugin-tailwindcss`) se possível.

Variantes de estado sempre explícitas: `hover:bg-indigo-700`, `focus:ring-2`, `disabled:opacity-50`. Nunca sobrescrever estados via CSS customizado.

Breakpoints seguindo mobile-first: estilos base para mobile, prefixos `sm:`, `md:`, `lg:` para telas maiores.

---

## Organização de pastas

```
app/
  views/
    layouts/
    shared/
    components/
  javascript/
    controllers/   ← Stimulus controllers
```

---

## Design System

Todas as decisões visuais devem seguir obrigatoriamente o arquivo `/verbena/.agents/design/DESIGN.md` — cores, tipografia, espaçamentos, componentes e padrões definidos ali têm prioridade sobre qualquer preferência pontual.

Nunca inventar tokens visuais fora do design system. Se algo não estiver coberto pelo `DESIGN.md`, questionar antes de criar.

---

## Composição de telas

Cada tela do sistema possui um HTML de referência em `/verbena/.agents/design/<nome-da-tela>/`. Ao implementar uma tela, o HTML correspondente deve ser usado como inspiração para estrutura, hierarquia de elementos e comportamento visual.

As pastas disponíveis são:

- `login`
- `dashboard`
- `enviar_resumo`
- `gerando_quest_es`
- `banco_de_quest_es`
- `configurar_simulado`
- `simulado_em_andamento`
- `resultado_do_simulado`
- `hist_rico_de_simulados`

O HTML de referência não deve ser copiado diretamente — serve como guia de composição. A implementação final usa ERB, helpers do Rails e classes do Tailwind alinhadas ao `DESIGN.md`.