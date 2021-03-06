class LinksController < ApplicationController

  caches_page :index

  def index  
    @link = Link.new
    render :action => 'index'
  end
  
  def create
    @website_url = params.include?(:website_url) ? params[:website_url] : params[:link][:website_url]
    @link = Link.find_or_create_by_url(@website_url)
    unless @link.is_a?(String)
      @link.ip_address = request.remote_ip if @link.new_record?    
      expire_page :action => :index
      if @link.save
        calculate_links # application controller, refactor soon
        render :action => :show
      else
        flash[:warning] = 'There was an issue trying to create your tinyThom.as URL.'
        redirect_to :action => :invalid
      end
    else
      render :action => :expired#, :website_url=>@website_url 
    end
  end
  
  # def expired
  #   @website_url = params[:website_url]
  # end

  def redirect
    @link = Link.find_by_token( params[:token] )

    unless @link.nil?
      @link.add_visit(request)
      redirect_to @link.thomas_permalink, { :status => 301 }
    else
      redirect_to :action => 'invalid'
    end
  end
  
  private
  
  
end
