require 'octokit'
require 'nokogiri'
require 'yaml'
require 'stringex'
require 'fileutils'

class GistTransform
    def initialize
        Octokit.netrc = true
        @client = Octokit.user
        @client = Octokit::Client.new
    end
    
    def transform(file_name, front_matter, content)
        fragment = Nokogiri::HTML::fragment(content)
        changed = false
        
        fragment.xpath('p[@class = "embed_gist"]').each  do |node|
            gist_href = node.xpath('a/@href')
            gist_id =  gist_href.to_s.split('/').last
            @client.gist(gist_id).files.each do |files|
                files.each do |file|
                    if file.class != Hashie::Mash
                        next
                    end
                    
                    lang =  file['language'].downcase
                    if(lang == 'shell')
                        lang = 'bash' # manually convert to something pygments understands 
                    end
                    content = file['content']
                    new_node = Nokogiri::XML::Node.new "div", fragment
                    new_node['class'] =  'highlight_area'
                    new_text = "\n{% highlight #{lang} %}\n"
                    new_text += content
                    new_text += "\n{% endhighlight %}\n"
                    new_node.inner_html = new_text
                    node.replace new_node
                    changed = true
                end
            end
            
        end
        
        if(changed)
            fullcontent = [front_matter, fragment.to_s].join("\n")
            puts "writing " + file_name
            File.open(file_name, 'w') {|f| f.write(fullcontent) }
        end
    
    end
end

class NameTransform
    def initialize
        
    end
    
    def transform(file_name, front_matter, content)
        puts file_name
        if front_matter =~ /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m
          match = $POSTMATCH
          data = YAML.load($1)
        end
        if(not data['title'].nil?)
            permalink =  data['title'].to_url(:limit => 40) + '.md'
            new_file_name = File.join(File.dirname(file_name), permalink)
            FileUtils.mv file_name, new_file_name
        end
    end
end

class PostTransformer
    def initialize(post_dir, transformer)
        @postDir = post_dir
        @transformer = transformer
    end
    
    def run 
        # get a snapshot of the directory
        files = []
        Dir.foreach(@postDir) do |postfile|
            files.push(postfile)
        end
        
        files.each do |post|
            next if post == '.' or post == '..'
            file = File.open(File.join(@postDir, post))
            
            front_matter = []
            content = []
            
            append_to = front_matter
            file.each_line do |line|
                append_to.push(line)
                if(line =~ /^---\s*/ and not front_matter.size == 1)
                    append_to = content
                end
            end
            
            front_matter_str = front_matter.join('')
            content_str = content.join('')
            
            @transformer.transform(file.path, front_matter_str, content_str)
        end
    end
end

transformer = PostTransformer.new(ARGV[0], NameTransform.new)
transformer.run()
