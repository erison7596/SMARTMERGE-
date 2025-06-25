# 🔀 smartmerge.sh

> **Autor:** Erison Cavalcante Alves  
> **Projeto de TCC – Curso de Engenharia de Software**  
> **Tema:** _SMARTMERGE++: uma ferramenta multilíngue para merge semântico automatizado de códigos-fonte com suporte a ambientes Unix e Git Bash_

---

## 📌 Visão Geral

`smartmerge.sh` é um script Bash desenvolvido para realizar merges textuais conscientes da linguagem de programação utilizada, com suporte específico para **C#** e **Go**.

Ele combina três versões de um mesmo arquivo-fonte (`BASE`, `LEFT`, `RIGHT`) utilizando `diff3`, mas com pré e pós-processamento que evita conflitos de sintaxe, preserva comentários, e aplica **formatação automática com indentação padronizada**.

Este script foi desenvolvido como parte do meu **Trabalho de Conclusão de Curso (TCC)**, com o objetivo de demonstrar como técnicas simples de pré-processamento e reconstrução sintática podem melhorar significativamente a qualidade do merge de código-fonte.

---

## 🚀 Funcionalidades

- ✅ Suporte a **C#** (`.cs`) e **Go** (`.go`)
- ✅ Merge com `diff3` (sem conflitos sintáticos em maioria dos casos)
- ✅ Remoção de marcadores internos e linhas em branco duplicadas
- ✅ Comentários de linha preservados (`//`)
- ✅ Reconstrução de instruções completas em linha única
- ✅ Indentação de **4 espaços** por nível de bloco (`{}`)

---

## 🛠️ Requisitos

- `bash` 4+
- `diff3` (GNU diffutils)
- `awk`, `sed`, `mktemp`

---

## 📦 Instalação

Clone o repositório diretamente do GitHub:

```bash
git clone https://github.com/erison7596/SMARTMERGE-.git
cd SMARTMERGE-
chmod +x smartmerge.sh
```

---

## 💡 Como Usar

Execute o script com a linguagem desejada (`--csharp` ou `--go`) e os três arquivos:

```bash
./smartmerge.sh --csharp BASE.cs LEFT.cs RIGHT.cs > MERGED.cs
```

ou

```bash
./smartmerge.sh --go BASE.go LEFT.go RIGHT.go > MERGED.go
```

> 📝 **Nota:** Os arquivos `BASE`, `LEFT`, e `RIGHT` devem ser versões distintas do mesmo arquivo original.

---

## 📊 Exemplo

### Entrada:

- `BASE.cs`
```csharp
public class ExampleOne
{
    public string ProcessValue(int value){
        string result = "Default";
        if (value > 10) { result = "High"; }
        return result;
    }
}
```

- `LEFT.cs`
```csharp
public class ExampleOne{
    public string ProcessValue(int value){
        string result = "Default";
        if (value > 5) { result = "High"; }
        return result;
    }
}
```

- `RIGHT.cs`
```csharp
public class ExampleOne
{
    public string ProcessValue(int value)
    {
        string result = "Default";
        if (value > 10) { result = "Critical"; }
        return result;
    }
}
```

### Comando:
```bash
./smartmerge.sh --csharp BASE.cs LEFT.cs RIGHT.cs > MERGED.cs
```

### Saída (MERGED.cs):
```csharp
public class ExampleOne {
    public string ProcessValue( int value) {
        string result = "Default";
        if( value > 5) {
            result = "Critical";
        }
        return result;
    }
}

```

---

## 📖 Sobre o Autor

> <h3>Erison Cavalcante Alves</h3>
> 
> Este projeto é parte do TCC intitulado:
> 
> **“SMARTMERGE++: uma ferramenta multilíngue para merge semântico automatizado de códigos-fonte com suporte a ambientes Unix e Git Bash”**
> 
> O trabalho propõe uma abordagem prática e automatizada para fusões semânticas de código-fonte, minimizando conflitos comuns em merges tradicionais de ferramentas como Git, com suporte a múltiplas linguagens de programação.
---

## 📜 Licença

Este projeto é de livre uso acadêmico e experimental. Caso deseje utilizá-lo em projetos comerciais, entre em contato.
