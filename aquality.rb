#!/bin/ruby
# encoding : utf-8

require 'csv'

Version="0.2"
Documentation=<<EOS
NAME
 aquality - computes the laconicity, lucidity, completeness and soundness of an 
 abstraction wrt. to tools and mappings

SYNOPSIS
 ruby aquality.rb [OPTIONS] MODEL [TOOL MAPPING]+

DESCRIPTION
 Aquality is a simple commandline tool which enables the user to determine the 
 appropriateness and generality of an abstraction, by computing the laconicity, 
 lucidity, completeness and soundness of the abstraction with respect to a given
 set of tools and mapping of concepts of the abstractions to constructs in the 
 tool. It will compute the generalized metrics, if multiple tools and mappings
 are provided (one mapping per tool).

MODEL 
 is a text file whereas each (nonempty) line contains a model's concept.

TOOL 
 is a text file whereas each (nonempty) line contains a tool's construct.

MAPPING 
 is a text file whereas each (nonempty) line contains one concept and one mapped
 construct separated by a colon [:].

OPTIONS
 -h   show this document.
 -t   creates output of metrics in the CSV format with 
      #concept, #construct, #laconic, #lucid, #complete, #sound.
 -v   produces verbose output.
 -V   shows the version number.

USAGE
 ruby aquality.rb model.txt tool.txt mapping.txt
 ruby aquality.rb -h
 ruby aquality.rb -V
 
AUTHOR
 Thomas "Eden_06" Kuehn

VERSION
 %s
EOS

# method definitions

# 1 if \lvert \{m \mid (m,t) \in \mathbb{R}^M_T\} \rvert \leq 1
def laconic(mapping,construct)
  pred=mapping.select{|m,t| t==construct }.map{|m,t| m}.uniq
  if pred.size <= 1
    1
  else
    0
  end  
end

# 1 if \lvert \{t \mid (m,t) \in \mathbb{R}^M_T\} \rvert \leq 1
def lucid(mapping,concept) 
  succ=mapping.select{|m,t| m==concept }.map{|m,t| t}.uniq
  if succ.size <= 1
    1
  else
    0
  end  
end

# 1 if \lvert \{m \mid (m,t) \in \mathbb{R}^M_T\} \rvert \geq 1
def complete(mapping,construct)
  pred=mapping.select{|m,t| t==construct }.map{|m,t| m}.uniq
  if pred.size >= 1
    1
  else
    0
  end 
end

# 1 if \lvert \{t \mid (m,t) \in \mathbb{R}^M_T\} \rvert \geq 1 
def sound(mapping,concept)
  succ=mapping.select{|m,t| m==concept }.map{|m,t| t}.uniq
  if succ.size >= 1
    1
  else
    0
  end
end

def collectUniqueStringsFromFile(path)
  result=[]
  File.open(path) do|file|
    file.each_line{|line| result << line.strip unless line.strip.empty? }
  end
  result.uniq
end

def collectMappingFromFile(path)
  result=[]
  File.open(path) do|file|
    file.each_line do|line|
      unless line.strip.empty?
        mapping=line.strip.split(":").map{|c| c.strip}
        if mapping.size>1
          mapping.freeze #prevent updates to mapping to ensure hash stability
          result << mapping
        end
      end
    end
  end  
  result.uniq
end

# begin of execution
key="-a"
files=[]

seperator=";"
verbose=false
table=false

ARGV.each do|x| 
 case x
  when /^-[hV]$/
   key=$~.to_s
  when /^-t$/
   table=true
   key="-a"
  when /^-v$/
   verbose=true
  else
   files << x
  end
end

if files.size<3 or key=="-h"
  puts Documentation % Version
  exit(1)
end

if key=="-V"
  puts Version
  exit(1)
end

unless (files.size-1)%2 == 0
  $stderr.puts "For each tool a corresponding mapping must be provided."
  exit(2)
end

files.each do|file|
  unless File.exists?(file)
    $stderr.puts "The selected file %s does not exist." % file
    exit(2)
  end
end

if verbose
  files.each do|path|
    $stderr.puts "Reading file %s" % [path]
  end
end

#separate files into models, tools, and mappings
modelpath=files.first
model=collectUniqueStringsFromFile(modelpath)

tools=[]
files.last(files.size-1).each_slice(2) do |toolpath,mappingpath|
  tool=collectUniqueStringsFromFile(toolpath)
  mapping=collectMappingFromFile(mappingpath)
  tools << [tool,mapping]
end

# compute metrics
conceptcount=model.size
constructcount=tools.map{|t,m| t.size }.reduce(:+)

if verbose
  $stderr.puts "#model concepts: %d" % [conceptcount]
  $stderr.puts "#tools:          %d" % [tools.size]
  $stderr.puts "#tool construct: %d" % [constructcount]
  
end

if conceptcount==0
  $stderr.puts "ERROR: the abstractions did not contain any concepts"
  exit(-1)
end

if constructcount==0
  $stderr.puts "ERROR: the tools did not contain any constructs"
  exit(-1)
end

#laconiccount = \sum\nolimits_{T\in \mathcal{T}} \sum\nolimits_{t\in T} \text{laconic}(M,T,t)
laconiccount=tools.map do|tool,mapping|
  tool.map do|construct|
    laconic(mapping,construct)
  end.reduce(:+)
end.reduce(:+)
laconicity=laconiccount.to_f / constructcount.to_f

#\sum\nolimits_{m\in m}\,\big(\min\nolimits_{T\in\mathcal{T}}\,\text{lucid}(M,T,m) \big)
lucidcount=model.map do|concept|
  tools.map do|tool,mapping|
    lucid(mapping,concept)
  end.min
end.reduce(:+)
lucidity=lucidcount.to_f / conceptcount.to_f

#\sum\nolimits_{T\in \mathcal{T}} \sum\nolimits_{t\in T} \text{complete}(M,T,t)
completecount=tools.map do|tool,mapping|
  tool.map do|construct|
    complete(mapping,construct)
  end.reduce(:+)
end.reduce(:+)
completeness=completecount.to_f / constructcount.to_f

#\sum\nolimits_{m\in M}\,\big(\max\nolimits_{T\in\mathcal{T}}\,\text{sound}(M,T,m)\big)
soundcount=model.map do|concept|
  tools.map do|tool,mapping|
    sound(mapping,concept)
  end.max
end.reduce(:+)
soundness=soundcount.to_f / conceptcount.to_f

if table
  $stdout.puts [conceptcount, constructcount, laconiccount, lucidcount, completecount, soundcount].join(seperator)
else
  $stdout.puts "laconicity: %.2f (%d/%d)" % [laconicity, laconiccount, constructcount]
  $stdout.puts "lucidity: %.2f (%d/%d)" % [lucidity, lucidcount, conceptcount]
  $stdout.puts "completeness: %.2f (%d/%d)" % [completeness, completecount, constructcount]
  $stdout.puts "soundness: %.2f (%d/%d)" % [soundness, soundcount, conceptcount]
end

exit(0)


