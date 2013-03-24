## Jekyll Blog Migration Tools

This is a quick project I wrote to help migrate my blog from [Tumblr](http://www.tumblr.com).

There were a few issues with the import that I needed to address. The first was that all the 
file names were named with the ID, instead of something that resembled a permalink. I wanted 
to rename the files with a permalink based on the title.

The second was that within Tumblr I decided to use [gist](http://gist.github.com) to store all 
my code snippets for my blog posts. Part of why I wanted to migrate to Jekyll was to take 
advantage of tools to render the code snippets within the post body. Running the gist 
transformer pulls down the gist files and adds the correct `Pygments` layout. 

### Running the Migration Tool

Since this is just one level better than a quick and dirty script, running it requires some work.
After installing all the gems, you will need to edit the file and select which transformer to use.

#### Running the Gist transformer
    
Invoke the code with the following line:

    transformer = PostTransformer.new(ARGV[0], GistTransform.new)
    
#### Running the name transformer 

Invoke the code with the following line:

    transformer = PostTransformer.new(ARGV[0], NameTransform.new)
    
#### Running the script

    ruby migration_tool.rb /path/to/posts/in/jekyll
    

### Notes about the Gist transformer

The Gist transformer uses Nokogiri to insert XML nodes within the original imported document.
This has two bad side effects. The first is that there is some unwanted mark-up. You will need
to manually remove the `div` with the class `remove_this_node`.

Secondly, XML or anything that looks like XML becomes garbled. This will also require manual intervention.

