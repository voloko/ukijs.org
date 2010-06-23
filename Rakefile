require 'rubygems'
require 'json'
require 'fileutils'

desc "Build docs"
task :docs do
  base = File.dirname(__FILE__)
  Dir.chdir '../uki'
  `java -jar ../jsdoc-toolkit/jsdoc-toolkit/jsrun.jar ../jsdoc-toolkit/jsdoc-toolkit/app/run.js -a -t=../jsdoc-toolkit/jsdoc-toolkit/templates/uki src/uki-core/** src/uki-view/** -d=../ukijs.org/public/docs`
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

namespace :dev do

  desc "Run nginx host"
  task :nginx do
    sh "sudo /opt/local/sbin/nginx ;"
  end

  desc "Kill nginx"
  task :kill_nginx do
    sh "sudo kill `cat /opt/local/var/log/nginx/nginx.pid`"
  end

  desc "Restart nginx"
  task :restart_nginx, :needs => [:kill_nginx, :nginx] do
  end


  desc "Run thin development"
  task :start do
    sh "thin -C conf/dev.yaml start"
  end

  desc "Run thin"
  task :restart do
    sh "thin -C conf/dev.yaml restart"
  end

  desc "Stop thin"
  task :stop do
    sh "thin -C conf/dev.yaml stop"
  end
end

namespace :prod do
  desc "Run thin development"
  task :start do
    sh "thin -s 3 -C conf/prod.yaml start"
  end

  desc "Run thin"
  task :restart do
    sh "thin -s 3 -C conf/prod.yaml restart"
  end

  desc "Stop thin"
  task :stop do
    sh "thin -s 3 -C conf/prod.yaml stop"
  end
end
