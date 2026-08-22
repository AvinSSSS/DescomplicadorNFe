# 🧾 Descomplicador de NFe

[![Delphi](https://img.shields.io/badge/Delphi-VCL-EE1F35)](https://www.embarcadero.com/products/delphi)
[![Platform](https://img.shields.io/badge/plataforma-Windows-0078D6?logo=windows)](#)

Aplicativo Windows que transforma uma pasta de XMLs de Nota Fiscal Eletrônica em uma visão simples e exportável. O processamento é totalmente local: nenhum documento fiscal sai do computador.

## ✨ Funcionalidades

- Seleção de uma pasta com arquivos XML.
- Leitura em lote de documentos com ou sem namespace XML.
- Extração de fornecedor, CNPJ, data de emissão, número e valor total.
- Exibição em grid redimensionável.
- Identificação de XML inválido ou com campos essenciais ausentes.
- Exportação de relatório CSV em UTF-8, compatível com Excel.

## 🛠️ Tecnologias e arquitetura

- Delphi 13 e VCL para a interface Windows.
- `Xml.XMLDoc` e `Xml.XMLIntf` para leitura dos documentos.
- `NFeReader.pas`: interpretação e serialização CSV.
- `MainForm.pas`: seleção de pasta, grid e exportação.

## 🚀 Como executar

1. Abra `NFeExplorer.dpr` no Delphi.
2. Selecione a plataforma **Win32** ou **Win64**.
3. Compile e execute pelo IDE.
4. No aplicativo, selecione uma pasta contendo XMLs e clique em **Ler XMLs**.

> A edição instalada do Delphi neste ambiente bloqueia compilação pelo `dcc32`; use o IDE.

## 🧪 Cenários recomendados de teste

- XML autorizado e completo.
- Documento com namespace diferente.
- XML corrompido ou arquivo que não seja uma NFe.
- Campos de emitente ou total ausentes.
- Pasta vazia e pasta com centenas de documentos.
- CSV aberto no Excel, conferindo acentos e valores.

## 🔐 Privacidade e limitações

O aplicativo não possui rede, telemetria ou armazenamento externo. Utilize XMLs fictícios nos testes e nunca versione documentos reais de clientes. O MVP apresenta os dados principais; filtros avançados e releases assinadas permanecem no roadmap.

---

## 🇬🇧 English

Local-only Delphi VCL application that reads NFe XML files, displays key supplier and invoice fields, reports malformed documents and exports a UTF-8 CSV file.
