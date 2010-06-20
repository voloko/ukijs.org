require 'sinatra/base'
require 'haml'
require 'json'
require 'lib/helpers'
require 'net/http'
require 'uki/builder'

SERVER_ROOT = File.expand_path(File.dirname(__FILE__))
UKI_ROOT = File.join(SERVER_ROOT, '../uki');
DEVELOPMENT = ENV['RACK_ENV'] == 'development'
# 
# UKI_HOST = '127.0.0.1'
# UKI_PORT = 21119
# UKI_PATH = '/src/'
# 
def version_info
  path = File.join(SERVER_ROOT, 'public', 'version_info.json')
  JSON.load File.read(path)
end

def process_src_paths(content)
  content
end

# def process_src_paths(content)
#   replace_src_paths(content, version_info)
# end


class Ukijs < Sinatra::Base
  get %r{\.cjs$} do
    path = request.path.sub(/\.cjs$/, '.js').sub(%r{^/}, './')
    path = File.join(UKI_ROOT, path)
    pass unless File.exists? path
    
    response.header['Content-type'] = 'application/x-javascript; charset=UTF-8'
    begin
      Uki::Builder.new(path, :optimize => false).code
    rescue Exception => e
      message = e.message.sub(/\n/, '\\n')
      "alert('#{message}')"
    end
  end
  
  get '/' do
    process_src_paths(haml :index, :locals => {:version_info => version_info})
  end
  
  get '/examples/' do
    path = File.join(UKI_ROOT, 'examples')
    exampleList = list_examples(path).map do |name|
      { 
        :path => name, 
        :title => extract_example_title(File.join(path, name)),
        :order => extract_example_order(File.join(path, name)) 
      }
    end.sort { |e1, e2| e1[:order] <=> e2[:order] }.select { |e| e[:order] > 0 }
    haml :exampleList, :locals => { :exampleList => exampleList }
  end
  
  get '/examples/*/' do
    path = File.join(UKI_ROOT, request.path)
    pass unless File.exists? path
    
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
    public_path = File.join(SERVER_ROOT, 'public', request.path)
    uki_path = File.join(UKI_ROOT, request.path) 
    path = File.exists? (public_path) ? public_path : uki_path
    send_file path
  end
  
  # compat redirects
  
  get %r{/examples/[^/]+/?$} do
    redirect request.path.sub('/examples/', '/examples/core-examples/')
  end
  
  get '/functional/*' do
    redirect '/examples/' + params[:splat][0].sub('.html', '/')
  end
  
  get '/app/functional/*' do
    redirect '/examples/' + params[:splat][0].sub('.html', '/')
  end
end