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
- `NFeReader.pas`: interpretação e serialização CSV.
- `MainForm.pas`: seleção, processamento assíncrono, pesquisa, grid e exportação.
- `EditNFeForm.pas`: edição de um documento carregado.
- `XmlViewerForm.pas`: visualização local e formatada do XML.
- `tests/NFeReaderTests.pas`: testes automatizados do leitor e do CSV.

## 🚀 Como executar

1. Abra `NFeExplorer.dpr` no Delphi.
2. Selecione a plataforma **Win32** ou **Win64**.
3. Compile e execute pelo IDE.
4. No aplicativo, selecione uma pasta contendo XMLs e clique em **Ler XMLs**.

> A edição instalada do Delphi neste ambiente bloqueia compilação pelo `dcc32`; use o IDE.

## 🧪 Testes automatizados

Abra `tests/NFeReaderTests.dpr` no Delphi e execute o projeto de console. A suíte
DUnitX cobre leitura com namespace, data de emissão legada, XML malformado,
campos obrigatórios ausentes, bloqueio de DTD, edição do XML, proteção do CSV e
compactação do XML exportado.

## 🧪 Cenários recomendados de teste

- XML autorizado e completo.
- Documento com namespace diferente.
- XML corrompido ou arquivo que não seja uma NFe.
- Campos de emitente ou total ausentes.
- Pasta vazia e pasta com centenas de documentos.
- CSV aberto no Excel, conferindo acentos e valores.
- Pasta grande, conferindo progresso e cancelamento.

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
