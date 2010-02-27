require 'sinatra/base'
require 'haml'
require 'json'
require 'lib/helpers'
require 'net/http'

SERVER_ROOT = File.expand_path(File.dirname(__FILE__))
DEVELOPMENT = ENV['RACK_ENV'] == 'development'

UKI_HOST = '127.0.0.1'
UKI_PORT = 21119
UKI_PATH = '/src/'

def version_info
  path = File.join(SERVER_ROOT, 'public', 'version_info.json')
  JSON.load File.read(path)
end

class Ukijs < Sinatra::Base
  if DEVELOPMENT
    # proxy requests to development uki version
    get '/src/*' do
      proxy_response = Net::HTTP.start(UKI_HOST, UKI_PORT) { |http| http.get("#{UKI_PATH}#{params[:splat][0]}") }
      proxy_response.each_header { |name, value|
        response.header[name] = value
      }
      proxy_response.body
    end
    
    def process_src_paths(content)
      content
    end
  else
    def process_src_paths(content)
      replace_src_paths(content, version_info)
    end
  end
  
  get '/' do
    process_src_paths(haml :index, :locals => {:version_info => version_info})
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
  
  get '/functional/*' do
    redirect '/examples/' + params[:splat][0].sub('.html', '/')
  end
  
  get '/app/functional/*' do
    redirect '/examples/' + params[:splat][0].sub('.html', '/')
  end
  
  get '/examples/' do
    path = File.join(SERVER_ROOT, 'examples')
    exampleList = list_examples(path).map do |name|
      { 
        :path => name, 
        :title => extract_example_title(File.join(path, name)),
        :order => extract_example_order(File.join(path, name)) 
      }
    end.sort { |e1, e2| e1[:order] <=> e2[:order] }
    haml :exampleList, :locals => { :exampleList => exampleList }
  end
  
  get '/examples/*' do
    redirect request.path + '/' unless request.path.match(%{/$}) # force trailing slash
    
    path = File.join(SERVER_ROOT, 'examples', params[:splat][0])
    page = get_example_page(path)
    if page
      process_src_paths(page) 
    else
      haml(:example, :locals => {
        :html => process_src_paths(extract_example_html(path)), 
        :title => extract_example_title(path)}
      )
    end
  end
  
  get '*' do
    path = request.path
    response.header['Content-type'] = 'text/plain' if path.match(/\.txt$/) || !path.match(/\./)
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