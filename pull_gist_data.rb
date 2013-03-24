require 'octokit'
require 'nokogiri'

class GistTransform
    def initialize
        Octokit.netrc = true
        @client = Octokit.user
        @client = Octokit::Client.new
    end
    
    def transform(file_name, front_matter, content)
        fragment = Nokogiri::HTML::fragment(content)
        fragment.xpath('p[@class = "embed_gist"]').each  do |node|
            gist_href = node.xpath('a/@href')
            gist_id =  gist_href.to_s.split('/').last
            changed = false
            @client.gist(gist_id).files.each do |files|
                files.each do |file|
                    if file.class != Hashie::Mash
                        next
                    end
                    
                    lang =  file['language'].downcase
                    content = file['content']
                    new_node = Nokogiri::XML::Node.new "div", fragment
                    new_node['class'] =  'highlight'
                    new_text = "\n{% highlight #{lang} %}\n"
                    new_text += content
                    new_text += "\n{% endhighlight %}\n"
                    new_node.inner_html = new_text
                    node.replace new_node
                    changed = true
                end
            end
            
            fullcontent = [front_matter, fragment.to_s].join("\n")
            
            # new_node = Nokogiri::XML::Node.new "div", fragment
            # new_node.inner_html = "<!-- replaced -->"
            # node.replace new_node
        end
    end
end

class PostTransformer
    def initialize(post_dir, transformer)
        @postDir = post_dir
        @transformer = transformer
    end
    
    def run 
        Dir.foreach(@postDir) do |post|
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

transformer = PostTransformer.new(ARGV[0], GistTransform.new)
transformer.run()

# @client.gist(3880535).files.each do |file|
#    puts file[1].content
# end