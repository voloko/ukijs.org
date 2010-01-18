def core_path(path)
  "/uki-core/#{path}"
end

def get_example_page(path)
  name = File.basename(path)
  html_path = File.join(path, name + '.html')
  if(File.exist?(html_path))
    File.read(html_path)
  else
    nil
  end
end

def extract_example_html(path)
  name = File.basename(path)
  js_path = File.join(path, name + '.js')
  js_contents = File.read(js_path)
  js_contents.match(%r{@example_html((.|[\n\r])*?)\*/})[1] rescue 'No html'
end

def extract_example_title(path)
  name = File.basename(path)
  js_path = File.join(path, name + '.js')
  js_contents = File.read(js_path)
  js_contents.match(%r{@example_title(.*)})[1] rescue 'Untitled'
end

def optimize_png(data)
  f = Tempfile.new(['opt_png', '.png'])
  f.write(data)
  f.close()
  p = f.path
  variants = ['.opti', '.crush', '.crush.opti', '.opti.crush']

  `optipng -q -nc -o7 #{p} -out #{p}.opti`
	`pngcrush -q -rem alla -brute #{p} #{p}.crush`
	`optipng -q -nc -o7 -i0 #{p}.crush -out #{p}.crush.opti`
	`pngcrush -q -rem alla -brute #{p}.opti #{p}.opti.crush`
  suffix = variants.max { |a, b| File.size(p + a) <=> File.size(p + b) }
  FileUtils.rm(p)
  FileUtils.mv(p + suffix, p)
  variants.each { |v| FileUtils.rm(p + v) rescue nil }
  return File.read(p)
end

def optimize_gif(data)
  f = Tempfile.new(['opt_gif', '.png'])
  f.write(data)
  f.close()
  p = f.path
  
  `convert #{p} #{p}.gif`
  return File.read("#{p}.gif")
end

def encode64(str)
  Base64.encode64(str).gsub("\n", '')
end

def process_path(path, included = {})
  code = File.read(path)
  base = File.dirname(path)
  
  code.gsub(%r{include\s*\(\s*['"]([^"']+)["']\s*\)\s*;?}) {
    include_path = File.expand_path(File.join(base, $1))
    unless included[include_path]
      included[include_path] = true
      process_path(include_path, included)
    else
      ''
    end
  }
end