require 'rubygems'
require 'fileutils'

def read_version
  base = File.dirname(__FILE__)
  File.read(File.join(base, '..', 'uki', 'src', 'uki-core', 'uki.js')).match(%r{uki.version\s*=\s*'([^']+)'})[1]
end

desc "Copy all data from ukijs"
task :copy do
  FileUtils.rm_rf 'public/app'
  FileUtils.cp_r '../uki/app', 'public/app'
end

desc "Deploy: copy, haml and rsync"
task :deploy do
  Rake::Task[ "copy" ].execute
  Rake::Task[ "rsync" ].execute
end

desc "Rsync file to ukijs.org"
task :rsync do
  base = File.dirname(__FILE__)
  `rsync -vazC --delete --exclude build.xml -e ssh #{base}/public/ ukijs.org:/var/www/ukijs/public/`
end

desc "Build docs"
task :docs do
  base = File.dirname(__FILE__)
  Dir.chdir '../uki'
  `java -jar ../jsdoc-toolkit/jsrun.jar ../jsdoc-toolkit/app/run.js -a -t=../jsdoc-toolkit/templates/jsdoc src/uki-core/** -d=../ukijs.org/public/docs`
  Dir.chdir base
end

desc "Run thin"
task :start do
  sh "sudo thin -s 1 -C thin.yaml -R uki.ru start"
end

desc "Run thin"
task :restart do
  sh "sudo thin -s 1 -C thin.yaml -R uki.ru restart"
end

desc "Stop thin"
task :stop do
  sh "sudo thin -s 1 -C thin.yaml -R uki.ru stop"
end
