require 'octokit'
require 'nokogiri'

class GistEmbedder
    
    def initialize(post_dir)
        @postDir = post_dir

        Octokit.netrc = true
        @client = Octokit.user
        @client = Octokit::Client.new
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
            
            fragment = Nokogiri::HTML::fragment(content_str)
            fragment.xpath('p[@class = "embed_gist"]').each  do |node|
                puts node
            end
        end
    end
end

embedder = GistEmbedder.new(ARGV[0])
embedder.run()

# @client.gist(3880535).files.each do |file|
#    puts file[1].content
# end