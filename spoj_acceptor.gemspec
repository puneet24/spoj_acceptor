# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spoj_acceptor/version'
require 'rubygems'

Gem::Specification.new do |spec|
  spec.name          = "spoj_acceptor"
  spec.version       = SpojAcceptor::VERSION
  spec.authors       = ["punsa","girish"]
  spec.email         = ["puneet.241994.agarwal@gmail.com"]

  spec.summary       = %q{Downloading all the accepted solutions(SPOJ) of user using thier credentials.} 
  spec.description   = %q{Simple command and all the solutions will be downloaded in the directory.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($\)
  #spec.bindir        = "exe"
  spec.executables   = ["spoj_acceptor"]  
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "mechanize"
  spec.add_development_dependency "fileutils" 
end
