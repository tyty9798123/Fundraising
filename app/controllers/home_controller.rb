class HomeController < ApplicationController

    def index
        @project = Project.all
    end

end
