# 🧾 Descomplicador de NFe

[![Delphi](https://img.shields.io/badge/Delphi-VCL-EE1F35)](https://www.embarcadero.com/products/delphi)
[![Platform](https://img.shields.io/badge/plataforma-Windows-0078D6?logo=windows)](#)

Aplicativo Windows para consultar, pesquisar, revisar e exportar lotes de XMLs de
Nota Fiscal Eletrônica. Todo o processamento acontece localmente: nenhum
documento fiscal sai do computador.

## ✨ Funcionalidades

- Seleção de uma pasta com arquivos XML.
- Leitura em lote de documentos com ou sem namespace XML.
- Extração de fornecedor, CNPJ, data de emissão, número e valor total.
- Leitura em segundo plano com progresso e cancelamento.
- Pesquisa instantânea por arquivo, fornecedor, CNPJ, data, número, valor ou status.
- Grid redimensionável e ordenável pelo cabeçalho, com ações de visualizar, editar e excluir.
- Totalizadores dos documentos visíveis: quantidade, válidos, erros e valor total.
- Visualização local e formatada do XML, sem envio para serviços externos.
- Edição dos principais campos com sincronização do XML mantido em memória.
- Identificação de XML inválido ou com campos essenciais ausentes.
- Exportação CSV em UTF-8 com proteção contra fórmulas e XML completo compactado.

## 🛠️ Tecnologias e arquitetura

- Delphi 13 e VCL para a interface Windows.
- `Xml.XMLDoc` e `Xml.XMLIntf` para leitura dos documentos.
- `src/NFeReader.pas`: interpretação e serialização CSV.
- `src/forms/MainForm.pas`: seleção, processamento assíncrono, pesquisa, grid e exportação.
- `src/forms/EditNFeForm.pas`: edição de um documento carregado.
- `src/forms/XmlViewerForm.pas`: visualização local e formatada do XML.
- `tests/NFeReaderTests.pas`: testes automatizados do leitor e do CSV.

## 🗂️ Estrutura do projeto

```text
DescomplicadorNFe/
├── NFeExplorer.dpr          # Entrada da aplicação
├── NFeExplorer.dproj        # Configuração do projeto Delphi
├── src/
│   ├── NFeReader.pas        # Leitura, validação e exportação
│   └── forms/
│       ├── MainForm.*       # Tela principal
│       ├── EditNFeForm.*    # Edição de registros
│       └── XmlViewerForm.*  # Visualização local do XML
├── tests/                   # Projeto e suíte DUnitX
└── README.md
```

## 🚀 Como executar

Diretório de trabalho: raiz do repositório (`D:/Fontes/Projetos/DescomplicadorNFe`
no checkout principal, ou a raiz da worktree isolada).

Pré-requisitos: Windows e Delphi 13 com VCL e compilador para a plataforma
selecionada. Não há instalação npm/pip nem arquivo `.env` da aplicação.
O [projeto Delphi](NFeExplorer.dproj) usa as macros `BDS` e `BDSCOMMONDIR`
para localizar arquivos da instalação, incluindo estilos VCL; mantenha essas
referências disponíveis no ambiente do IDE. `Platform` e `Config` selecionam
plataforma e configuração, e as saídas ficam em `./<Platform>/<Config>`.

1. Abra [NFeExplorer.dpr](NFeExplorer.dpr) no Delphi.
2. Selecione a plataforma **Win32** ou **Win64**.
3. Compile e execute pelo IDE.
4. No aplicativo, selecione uma pasta contendo XMLs e clique em **Ler XMLs**.

> A edição instalada do Delphi neste ambiente bloqueia compilação pelo `dcc32`; use o IDE.

## 🧪 Testes automatizados

Abra `tests/NFeReaderTests.dpr` no Delphi e execute o projeto de console. A suíte
DUnitX cobre leitura com namespace, data de emissão legada, XML malformado,
campos obrigatórios ausentes, bloqueio de DTD, edição do XML, proteção do CSV e
compactação do XML exportado.

O projeto de testes depende das units `DUnitX.TestFramework`,
`DUnitX.TestRunner` e `DUnitX.Loggers.Console`; elas devem estar disponíveis
no caminho de busca do Delphi. O repositório não inclui as fontes do DUnitX
nem um `.dproj` de testes. Abra o `.dpr` a partir de `tests/`, mantendo sua
referência relativa a `../src/NFeReader.pas`. O runner define código de saída
1 se algum teste falhar ou ocorrer uma exceção.

Os oito testes em [NFeReaderTests.pas](tests/NFeReaderTests.pas) exercitam o
leitor e a serialização, sem abrir formulários. Os XMLs são strings fictícias
da própria suíte: `CreateXmlFile` grava arquivos temporários em UTF-8 e cada
teste que os utiliza os remove em `finally`. Não é preciso obter XMLs de clientes.
Para um teste manual, copie o XML da constante `Xml` em `ReadsNamespacedNFe`
para um arquivo `.xml` numa pasta temporária separada e selecione essa pasta
no aplicativo.

A suíte não cobre a interface, progresso/cancelamento, ordenação, exportação
pela tela ou abertura do CSV no Excel. Esses cenários precisam de verificação
manual. A leitura dos fontes e a conferência dos links abaixo não substituem
compilação nem execução dos testes no IDE.

## 🧪 Cenários recomendados de teste

- XML autorizado e completo.
- Documento com namespace diferente.
- XML corrompido ou arquivo que não seja uma NFe.
- Campos de emitente ou total ausentes.
- Pasta vazia e pasta com centenas de documentos.
- CSV aberto no Excel, conferindo acentos e valores.
- Pasta grande, conferindo progresso e cancelamento.
- Exportação após pesquisa/ordenação: atualmente `btnExportClick` em
  [MainForm.pas](src/forms/MainForm.pas) percorre todos os registros carregados
  (`FData`), na ordem de carregamento, mesmo quando a grade está filtrada ou
  ordenada. A exportação da visão atual está pendente na
  [issue #2](https://github.com/AvinSSSS/DescomplicadorNFe/issues/2).

## 🔐 Privacidade e limitações

O aplicativo não possui rede, telemetria ou armazenamento externo. XMLs maiores
que 10 MB são recusados, assim como documentos com DTD ou entidades externas.
Utilize XMLs fictícios nos testes e nunca versione documentos reais de clientes.

As alterações realizadas na tela atualizam somente os dados mantidos em memória
e exportados no CSV. O arquivo XML original no disco nunca é sobrescrito. A ação
de excluir também remove apenas o registro da lista atual.

---

## 🇬🇧 English

Local-only Delphi VCL application for browsing, searching, reviewing and sorting
Brazilian NFe XML batches. It provides background processing, per-record actions,
filtered totals, formatted XML viewing and protected UTF-8 CSV export without
sending fiscal data to external services.
