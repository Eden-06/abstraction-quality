# Abstraction Quality -- aquality

Command line tool to determining an abstractions generality and appropriateness
by computing the laconicity, lucidity, completeness and soundness of an 
abstraction wrt. to tools and mappings. 

# Systemrequirements

* Ruby Version 2.5.0 (or higher) [\[get here\]](https://www.ruby-lang.org/de/downloads/)

# Synopsis

```bash
ruby aquality.rb [OPTIONS] MODEL [TOOL MAPPING]+
ruby aquality.rb -h
ruby aquality.rb -V
```

# Description

`aquality` is a simple commandline tool which enables the user to determine the 
appropriateness and generality of an abstraction, by computing the laconicity, 
lucidity, completeness and soundness of the abstraction with respect to a given
set of tools and mapping of concepts of the abstractions to constructs in the 
tool. It will compute the generalized metrics, if multiple tools and mappings
are provided (one mapping per tool).

# Commandline Options

| Argument           | Function                                                |
|:------------------:|---------------------------------------------------------|
|-h                  | show this document.
|-t                  | creates output of metrics in the CSV format with #concept, #construct, #laconic, #lucid, #complete, #sound.
|-v                  | produces verbose output.
|-V                  | shows the version number.

# Input File Formates

* **MODEL** is a text file whereas each (nonempty) line contains a model's concept.
* **TOOL** is a text file whereas each (nonempty) line contains a tool's construct.
* **MAPPING** is a text file whereas each (nonempty) line contains one concept and one mapped construct separated by a colon [:].

# Usage

The following command will compute the laconicity, lucidity, completeness and soundness of the given `model.txt` with respect to the `tool.txt` and the corresponding `mapping.txt`

```bash
 ruby aquality.rb model.txt tool.txt mapping.txt
```

# PIBA

**Problem**: Difficult to evaluate _generality_ and _appropriateness_ of abstractions

**Idea**: Quantify _generality_ and _appropriateness_ by computing fractions of abstraction covered by models in tools and vice versa

**Benefit**:
 
* Evaluate _generality_ and _appropriateness_ of abstractions
* Prevent over generalization and over specialization of abstractions

**Approach**:

* Metrics for abstractions based on properties by [Guizzardi et al. 2005](https://doi.org/10.1007/11557432_51) and [Ananieva et al. 2020](https://doi.org/10.1145/3382025.3414955)
* Specify mapping between concepts and relations
* Compute metrics wrt.\ mappings

Additional information can be found in the slides.
