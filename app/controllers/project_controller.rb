class ProjectController < ApplicationController
    # get /proejct/new
    require 'date'
    before_action :checkLogin, only: [:new, :create, :edit, :update]
    def new
    end
    
    # post /project  
    def create
        if params[:image_url] != 'undefined'
            image_url = save_file(params[:image_url])
        else
            image_url = 'NoImageUrl'
        end
        json = {
            name: params[:name],
            description: params[:description],
            content: params[:content],
            image_url: image_url,
            video_url: params[:video_url],
            target_money: params[:target_money],
            deadline: params[:deadline],
            users_id: current_user.id
        }
        save_to_project = Project.create(json)

        if save_to_project.valid?

            respond_to do |format|
                format.html{
                    head :not_found
                }
                format.json{
                    render json: {success: true}
                }
            end
            
        else

            respond_to do |format|
                format.html{
                    head :not_found
                }
                format.json{
                    render json: {success: false}
                }
            end

        end
    end

    def show
        project_id = params[:id]
        @project = Project.all.find_by({id: project_id})
        if @project.blank?
            flash[:notice] = '沒有此募資專案'
            redirect_to "/"
        end
    end



    def save_file(newFile)
        dir_url = Rails.root.join('public', 'uploads/project')
        
        FileUtils.mkdir_p(dir_url) unless File.directory?(dir_url)
    
        file_url = dir_url + newFile.original_filename
        
        File.open(file_url, 'w+b') do |file|
          file.write(newFile.read)
        end
        
        return "/uploads/project/" + newFile.original_filename
    end

    def edit
        project_id = params[:id]
        @project = Project.all.find_by({id: project_id})
        if @project.blank?
            flash[:notice] = '沒有此募資專案'
            redirect_to "/"
        end
    end


    def update
        puts 0
        
        if 'empty_url' == params[:image_url]
            image_url = 'NoImageUrl'
        elsif 'dont_change' == params[:image_url]
            image_url = Project.all.find_by({id: params[:id]})[:image_url]
        else
            image_url = save_file(params[:image_url])
        end

        json = {
            name: params[:name],
            description: params[:description],
            content: params[:content],
            image_url: image_url,
            video_url: params[:video_url],
            target_money: params[:target_money],
            deadline: params[:deadline],
            users_id: current_user.id
        }
        puts 3

        if Project.all.find_by({id: params[:id]}).update(json)

            respond_to do |format|
                format.html{
                    head :not_found
                }
                format.json{
                    render json: {success: true}
                }
            end
            
        else

            respond_to do |format|
                format.html{
                    head :not_found
                }
                format.json{
                    render json: {success: false}
                }
            end

        end



    end

    def checkLogin
        unless current_user
            flash[:notice] 
            redirect_to '/'
            return
        end
    end

end
