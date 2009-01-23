module MechanicalGithub
  
  class Wiki
    attr_reader :project
    
    def initialize(repository, session)
      @repository = repository
      @session = session
    end
    
    def url
      "https://github.com/#{@repository.username}/#{repository.name}/wikis"
    end
    
    def pages
      
    end
    
  end
  
  class WikiPage
    attr_reader :name, :content
    
    def initialize(name, content, session=nil)
      @name = name
      @content = @content
      @session = session
    end
  end
  
end