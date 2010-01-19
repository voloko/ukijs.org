require 'sinatra/base'
require 'haml'
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