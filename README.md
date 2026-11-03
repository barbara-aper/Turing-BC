# Turing dApp

dApp de votação com o token **Turing**, executado em uma blockchain local (Hardhat) e acessado pelo navegador com a MetaMask.

> Todas as contas e endereços abaixo são de teste da rede local, sem valor real.

## Pré-requisitos

- [Node.js](https://nodejs.org) (versão LTS)
- Extensão [MetaMask](https://metamask.io) no navegador

Confira a instalação do Node:

```
node -v
npm -v
```

## Estrutura

```
contracts/Turing.sol     contrato do token e da votação
scripts/deploy.js        publica o contrato e gera frontend/public/config.js
frontend/public/
  index.html             interface do dApp
  config.js              gerado pelo deploy (endereço do contrato)
```

## 1. Preparar o projeto (uma vez)

Na pasta raiz do projeto (onde está o `hardhat.config.js`):

```
npm install
```

## 2. Rodar o projeto (toda vez)

**Terminal 1** – ligar a blockchain local. Deixe aberto; ele lista 20 contas de teste com as chaves privadas.

```
npx hardhat node
```

**Terminal 2** – publicar o contrato. O deploy cria o arquivo `frontend/public/config.js` com o endereço do contrato.

```
npx hardhat run scripts/deploy.js --network localhost
```

**Terminal 2** – servir o frontend:

```
npx http-server frontend/public -p 3000 -c-1
```

Abra **http://localhost:3000** no navegador (não abra o arquivo com `file://`).

## 3. Configurar a MetaMask

### 3.1 Adicionar a rede Hardhat Local

A página tenta adicionar e trocar de rede sozinha ao conectar. Para fazer manualmente:
MetaMask > seletor de redes > Adicionar rede > Adicionar manualmente.

| Campo | Valor |
|---|---|
| Nome da rede | Hardhat Local |
| URL do RPC | `http://127.0.0.1:8545` |
| ID da cadeia (Chain ID) | `31337` |
| Símbolo da moeda | ETH |

### 3.2 Importar as contas de teste

No terminal do `hardhat node`, copie a chave privada de cada conta. Na MetaMask: menu de contas > Adicionar conta ou carteira de hardware > Importar conta > colar a chave privada.

| Conta do Hardhat | Codinome | Para que serve |
|---|---|---|
| #0 (`0xf39F...2266`) | (sem codinome) | Dona do contrato: superusuária. Emite Turings e liga/desliga a votação. Não vota. |
| #1 (`0x7099...79C8`) | nome1 | Aluno: vota e recebe votos |
| #2 (`0x3C44...93BC`) | nome2 | Aluno |
| #3 (`0x90F7...b906`) | nome3 | Aluno |
| #4 (`0x15d3...6A65`) | nome4 | Aluno |
| #5 (`0x9965...A4dc`) | nome5 | Aluno |

### 3.3 Limpar a atividade quando a MetaMask reclamar de nonce

Depois de reiniciar o `hardhat node`: MetaMask > Configurações > Avançado > **Limpar dados da aba de atividade** (com a conta selecionada).

### 3.4 Conectar na página

Clique em **Conectar carteira** e aprove na MetaMask. Se estiver em outra rede, aceite a troca para Hardhat Local. Ao trocar de conta na MetaMask, a página recarrega sozinha.

## 4. Teste rápido do fluxo

| Passo | O que fazer | Resultado esperado |
|---|---|---|
| 1 | Conecte com a conta #0 e emita 5 Turings para nome1 | Ranking mostra nome1 com 5 |
| 2 | Troque para a conta #1 (nome1) e vote 2 Turings em nome2 | nome2 sobe para 2; aparece na atividade recente |
| 3 | Tente votar em nome2 de novo | Botão desabilitado: você já votou nesse colega |
| 4 | Na conta #0, clique em Desligar votação e tente votar | Votação pausada; voto bloqueado |

## 5. Problemas comuns

| Mensagem ou sintoma | Causa e solução |
|---|---|
| Não há contrato em `0x...` ou `config.js` não encontrado | O node foi reiniciado ou o deploy não rodou. A blockchain zera a cada reinício: execute o deploy de novo e limpe a atividade na MetaMask (seção 3.3). |
| `config.js` não carrega (404) | O `config.js` precisa estar na mesma pasta do `index.html` e o servidor deve apontar para ela (`frontend/public`). Use `Ctrl + F5` para limpar o cache. |
| MetaMask não encontrada | Abra por `http://localhost:3000`, não por `file://`, e confirme que a extensão está ativa. |
| Transação travada ou erro de nonce | Limpe os dados da aba de atividade (seção 3.3). |
| `usuario nao autorizado` | A conta não está na tabela de usuários. Use as contas #1 a #5 para votar. |
| `votacao nao esta ativa` | Na conta #0, clique em **Ligar votação**. |
| Painel da professora não aparece | Só a conta #0 (dona) ou o endereço da professora vê esse painel. |
| `node` não é reconhecido (Windows) | Instale o Node.js LTS, feche e abra o PowerShell de novo. Se persistir, confira se `C:\Program Files\nodejs\` está no PATH. |
| Porta 3000 ou 8545 em uso (Windows) | `netstat -ano \| findstr :8545` e depois `taskkill /PID <numero> /F`. |

## Regras da votação

- Cada voto vale 1 ou 2 Turings para o colega escolhido.
- Não é possível votar em si mesmo, e só se vota uma vez em cada colega.
- A cada 10 votos dados, o votante recebe 1 Turing.
- Só usuários pré-autorizados podem votar; apenas o owner ou a professora emitem Turings e controlam a votação.