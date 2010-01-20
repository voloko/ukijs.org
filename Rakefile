require 'rubygems'
require 'json'
require 'fileutils'

desc "Build docs"
task :docs do
  base = File.dirname(__FILE__)
  Dir.chdir '../uki'
  `java -jar ../jsdoc-toolkit/jsrun.jar ../jsdoc-toolkit/app/run.js -a -t=../jsdoc-toolkit/templates/jsdoc src/uki-core/** -d=../ukijs.org/public/docs`
  Dir.chdir base
end

desc "Generate version info"
task :version_info do
  base = File.dirname(__FILE__)
  src_base = File.join(base, '..', 'uki', 'src', 'uki-core')
  pkg_base = File.join(base, '..', 'uki', 'pkg')
  target_path = File.join(base, 'public', 'version_info.json')
  info = {
    :version => File.read(File.join(src_base, 'uki.js')).match(%r{uki.version\s*=\s*'([^']+)'})[1],
    :dev_size => File.size(File.join(pkg_base, 'uki.dev.js')),
    :compressed_size => File.size(File.join(pkg_base, 'uki.gz.js')),
  }
  File.open(target_path, 'w') { |f| f.write info.to_json }
end

desc "Run thin development"
task :start do
  sh "sudo thin -C dev.yaml start"
end

desc "Run thin"
task :restart do
  sh "sudo thin -C dev.yaml restart"
end

desc "Stop thin"
task :stop do
  sh "sudo thin -C dev.yaml stop"
end

namespace :prod do
  desc "Run thin development"
  task :start do
    sh "sudo thin -s 3 -C prod.yaml start"
  end

  desc "Run thin"
  task :restart do
    sh "sudo thin -s 3 -C prod.yaml restart"
  end

  desc "Stop thin"
  task :stop do
    sh "sudo thin -s 3 -C prod.yaml stop"
  end
end
