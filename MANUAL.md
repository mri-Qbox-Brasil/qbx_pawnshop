# qbx_pawnshop — Manual

Loja de penhores: vende itens de valor por dinheiro e derrete joias/eletrônicos em matérias-primas após um tempo de espera.

---

## Sumário

1. [Dependências](#dependências)
2. [Instalação](#instalação)
3. [Configuração](#configuração)
4. [Fluxo de uso](#fluxo-de-uso)
5. [Itens necessários](#itens-necessários)
6. [Antiexploit](#antiexploit)
7. [Integrações](#integrações)
8. [Entrypoints para outros recursos](#entrypoints-para-outros-recursos)
9. [Localização](#localização)
10. [Estrutura de arquivos](#estrutura-de-arquivos)

---

## Dependências

| Recurso | Obrigatório | Observação |
|---|---|---|
| `qbx_core` | Sim | `GetPlayer`, `Notify`, sistema de locale (`Lang`), dinheiro e itens do jogador |
| `ox_lib` | Sim | Menus de contexto, `lib.inputDialog`, `lib.zones`, `lib.callback` |
| `oxmysql` | Sim | Usado apenas pelo antiexploit, que insere na tabela `bans` |
| `ox_inventory` | Sim | Labels dos itens (`Items()`) |
| `ox_target` | Não | Alternativa às zonas de contexto quando a convar `UseTarget` está em `true` |
| `qb-phone` | Não | Recebe o e-mail de "derretimento concluído" quando `sendMeltingEmail = true` |

---

## Instalação

1. Copie a pasta `qbx_pawnshop` para `resources/`.
2. Adicione ao `server.cfg`:
   ```
   ensure qbx_pawnshop
   ```
3. Cadastre no `ox_inventory` os itens de venda, os itens derretíveis e as recompensas (veja [Itens necessários](#itens-necessários)).
4. A tabela `bans` (padrão do QBox/QBCore) precisa existir — o antiexploit escreve nela.
5. **Conflitos** — o recurso registra os eventos com o prefixo `qb-pawnshop:`. Não rode junto com o `qb-pawnshop` original.

---

## Configuração

### `config/client.lua`

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `useTarget` | bool | Sim | Lido da convar `UseTarget`. `true` usa `ox_target`; `false` usa zona com menu de contexto do `ox_lib` |
| `useTimes` | bool | Sim | `true` limita o horário de funcionamento; `false` deixa a loja aberta 24h |
| `timeOpen` | number | Sim | Hora de abertura (relógio do jogo). Padrão: `7` |
| `timeClosed` | number | Sim | Hora de fechamento (relógio do jogo). Padrão: `17` |
| `sendMeltingEmail` | bool | Sim | `true` avisa o fim do derretimento por e-mail (`qb-phone`); `false` avisa por notificação |
| `pawnItems` | array | Sim | Itens que a loja compra. Cada entrada tem `item` (nome no ox_inventory) e `price` (preço por unidade) |
| `meltingItems` | array | Sim | Itens derretíveis. Cada entrada tem `item`, `rewards` (lista de `{ item, amount }`) e `meltTime` (minutos por unidade derretida) |

> Os preços padrão usam `math.random(50, 100)`, avaliado uma única vez no carregamento do recurso — o preço é fixo até o próximo restart, não muda a cada venda.

### `config/server.lua`

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `bankMoney` | bool | Sim | `true` deposita o valor da venda no banco; `false` (padrão) paga em dinheiro vivo |

### `config/shared.lua`

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `pawnLocation` | array | Sim | Locais da loja. Cada entrada tem `coords` (vec3), `size` (vector3 da caixa), `heading` (rotação), `debugPoly` (bool) e `distance` (alcance do target) |

Cada local da lista ganha um blip automático (sprite 431, cor 5).

---

## Fluxo de uso

1. O jogador entra na zona da loja (ou usa o target no local) e abre o menu.
2. **Vender itens** — lista apenas os itens de `pawnItems` que o jogador tem no inventário; ele informa a quantidade e recebe o valor na hora.
3. **Derreter itens** — lista os itens de `meltingItems` que o jogador tem; ao confirmar a quantidade, os itens saem do inventário e o cronômetro começa. O tempo total é `quantidade x meltTime` (em minutos).
4. Terminado o tempo, o jogador é avisado (e-mail ou notificação) e a opção **Pickup Melted Items** aparece no menu da loja para retirar as recompensas.

O cronômetro roda no cliente e só avança com o jogador logado; a opção de derreter fica indisponível enquanto houver um lote em andamento.

---

## Itens necessários

Todos precisam existir no `ox_inventory`.

| Papel | Itens (padrão do config) |
|---|---|
| Vendáveis | `goldchain`, `diamond_ring`, `rolex`, `10kgoldchain`, `tablet`, `iphone`, `samsungphone`, `laptop` |
| Derretíveis | `goldchain`, `diamond_ring`, `rolex`, `10kgoldchain` |
| Recompensas do derretimento | `goldbar`, `diamond`, `electronickit` |

---

## Antiexploit

Os eventos `qb-pawnshop:server:sellPawnItems` e `qb-pawnshop:server:pickupMelted` validam a distância do jogador até o local da loja. Se a distância for maior que 5 unidades, o jogador é **banido permanentemente**: uma linha é inserida na tabela `bans` (com `bannedby = 'qb-pawnshop'`), um log é enviado via `qb-log:server:CreateLog` e o jogador é desconectado.

---

## Integrações

### ox_target

Com a convar `UseTarget` em `true`, cada local de `pawnLocation` vira uma box zone do `ox_target` com a opção "PawnShop N". Caso contrário, o menu de contexto do `ox_lib` aparece automaticamente ao entrar na zona.

### qb-phone

Com `sendMeltingEmail = true`, o fim do derretimento dispara `qb-phone:server:sendNewMail` com o assunto e a mensagem definidos no locale. Sem o `qb-phone`, deixe a opção em `false` para receber uma notificação simples.

### qb-log

O banimento por exploit dispara `qb-log:server:CreateLog` na categoria `pawnshop`. Se o `qb-log` não estiver instalado, o evento simplesmente não é tratado.

---

## Entrypoints para outros recursos

### Abrir o menu da loja

```lua
-- cliente
TriggerEvent('qb-pawnshop:client:openMenu')
```

### Eventos internos

| Evento | Lado | Descrição |
|---|---|---|
| `qb-pawnshop:client:openPawn` | Cliente | Abre o submenu de venda |
| `qb-pawnshop:client:openMelt` | Cliente | Abre o submenu de derretimento |
| `qb-pawnshop:client:pawnitems` | Cliente | Diálogo de quantidade para venda |
| `qb-pawnshop:client:meltItems` | Cliente | Diálogo de quantidade para derretimento |
| `qb-pawnshop:client:startMelting` | Cliente | Inicia o cronômetro do lote |
| `qb-pawnshop:client:resetPickup` | Cliente | Limpa o lote já retirado |
| `qb-pawnshop:server:sellPawnItems` | Servidor | Remove os itens e paga o jogador |
| `qb-pawnshop:server:meltItemRemove` | Servidor | Remove os itens e calcula o tempo de derretimento |
| `qb-pawnshop:server:pickupMelted` | Servidor | Entrega as recompensas do lote |
| `qb-pawnshop:server:getInv` | Servidor (callback) | Retorna os itens do jogador para montar os menus |

---

## Localização

O recurso usa o sistema de locale do `qbx_core` (`Lang`), não o do `ox_lib`. Os arquivos ficam em `locales/` como Lua:

`en`, `es`, `pt-br`, `pt`, `fr`, `it`, `cs`, `fi`, `sv`, `tc`

Idioma ativo pela convar:

```
setr qb_locale "pt-br"
```

O `en.lua` é sempre carregado primeiro e serve de fallback.

---

## Estrutura de arquivos

```
qbx_pawnshop/
├── client/
│   └── main.lua          — blips, zonas/target, menus de venda e derretimento, cronômetro do lote
├── server/
│   └── main.lua          — venda, remoção e entrega de itens, callback de inventário, antiexploit
├── config/
│   ├── client.lua        — horário, itens vendáveis, itens derretíveis e recompensas
│   ├── server.lua        — bankMoney
│   └── shared.lua        — locais da loja (pawnLocation)
├── locales/
│   ├── en.lua            — carregado primeiro; serve de fallback
│   └── cs / es / fi / fr / it / pt / pt-br / sv / tc .lua
└── fxmanifest.lua
```
