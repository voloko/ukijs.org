require 'sinatra/base'
require 'haml'
require 'json'
require 'base64'
require 'fileutils'
require 'tempfile'
require 'lib/helpers'
require 'net/http'

SERVER_ROOT = File.expand_path(File.dirname(__FILE__))

UKI_HOST = '127.0.0.1'
UKI_PORT = 21119
UKI_PATH = '/src/'

class Ukijs < Sinatra::Base
  get '/' do
    haml :index
  end
  
  get '/src/*' do
    proxy_response = Net::HTTP.start(UKI_HOST, UKI_PORT) { |http| http.get("#{UKI_PATH}#{params[:splat][0]}") }
    proxy_response.each_header { |name, value|
      response.header[name] = value
    }
    proxy_response.body
  end
  
  get %r{/examples/.*\.(png|css|jpg|js|zip)$} do
    path = request.path
    response.header['Content-type'] = 'image/png' if path.match(/\.png$/)
    response.header['Content-type'] = 'text/css' if path.match(/\.css$/)
    response.header['Content-type'] = 'image/jpeg' if path.match(/\.jpg$/)
    response.header['Content-type'] = 'text/javascript;charset=utf-8' if path.match(/\.js$/)
    response.header['Content-Encoding'] = 'gzip' if path.match(/\.gz/)
    if path.match(/.zip$/)
      response.header['Content-Type'] = 'application/x-zip-compressed'
      response.header['Content-Disposition'] = 'attachment; filename=tmp.zip'
    end
    
    File.read File.join(SERVER_ROOT, path)
  end
  
  get '/examples/*' do
    redirect request.path + '/' unless request.path.match(%{/$}) # force trailing slash
    
    path = File.join(SERVER_ROOT, 'examples', params[:splat][0])
    page = get_example_page(path)
    page || haml(:examples, :locals => {:html => extract_example_html(path), :title => extract_example_title(path)})
  end
  
  # Expects json: [ 
  #   { name: 'file-name.png', data: 'png data' },
  #   { name: 'file-name.gif', data: 'gif data' },
  #   ...
  # ]
  # returns json: {
  #   optimized: [
  #     { name: 'file-name.png', data: 'png data' },
  #     { name: 'file-name.gif', data: 'gif data' },
  #     ...
  #   ],
  #   url: 'path-to-zip-file'
  # }
  post '/imageCutter' do
    items = JSON.load(params['json'])
    optimized = []
    FileUtils.rm_r Dir.glob('tmp/*')
    items.each do |row|
      data = Base64.decode64(row['data'])
      data = row['name'].match(/\.gif$/) ? optimize_gif(data) : optimize_png(data)
      File.open(File.join('tmp', row['name']), 'w') { |f| f.write(data) }
      optimized << { 'name' => row['name'], 'data' => encode64(data) }
    end
    `zip tmp.zip tmp/*`
    FileUtils.mv 'tmp.zip', 'tmp/tmp.zip'
    response.header['Content-Type'] = 'application/x-javascript'
    { 'url' => '/tmp/tmp.zip', 'optimized' => optimized }.to_json
  end
  
  get %r{^/tmp/.*\.zip} do
    response.header['Content-Type'] = 'application/x-zip-compressed'
    response.header['Content-Disposition'] = 'attachment; filename=tmp.zip'
    File.read(request.path.sub(%r{^/}, ''))
  end
  
  get '*' do
    path = request.path
    response.header['Content-type'] = 'image/png' if path.match(/\.png$/)
    response.header['Content-type'] = 'text/css' if path.match(/\.css$/)
    response.header['Content-type'] = 'image/jpeg' if path.match(/\.jpg$/)
    response.header['Content-type'] = 'text/javascript;charset=utf-8' if path.match(/\.js$/)
    response.header['Content-Encoding'] = 'gzip' if path.match(/\.gz/)
    if path.match(/.zip$/)
      response.header['Content-Type'] = 'application/x-zip-compressed'
      response.header['Content-Disposition'] = 'attachment; filename=tmp.zip'
    end
    
    File.read File.join(SERVER_ROOT, 'public', path) rescue pass
  end
  
  
end