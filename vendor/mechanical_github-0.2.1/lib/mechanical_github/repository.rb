module MechanicalGithub
  
  # represents a project
  class Repository
    attr_reader :name, :description, :homepage, :username
    
    def initialize(session, name, username, description, homepage)
      @name = name
      @description = description
      @homepage = homepage
      @username = username
      @session = session
    end
    
    def self.url_for(username, name)
      "https://github.com/#{username}/#{name}"
    end
    
    def wiki
      Wiki.new(self, @session)
    end
    
  end
end