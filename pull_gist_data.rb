require 'octokit'

class GistEmbedder
    
    def initialize(post_dir)
        @postDir = post_dir

        Octokit.netrc = true
        @client = Octokit.user
        @client = Octokit::Client.new
    end
    
    
end

# @client.gist(3880535).files.each do |file|
#    puts file[1].content
# end