require File.dirname(__FILE__) + '/../spec_helper'

describe LinksController, "index action" do
  controller_name :links
  
  before(:each) do
    @link = mock('link')
    Link.stub!(:new).and_return(@link)    
    get :index
  end
  
  it "should render the index view" do
    response.should render_template('links/index')
  end

  it "should instantiate a new link variable" do
    assigns[:link].should equal(@link)
  end  

end

describe LinksController do
  include LinkSpecHelper

  controller_name :links
  
  it "should not save a new link without a website url" do
    post :create, :link => {}
    assigns(:link).should have_at_least(1).errors_on(:website_url)
  end
  
  it "should save a new link with valid attributes" do
    lambda do
      post :create, :link => valid_attributes
    end.should change(Link, :count).by(1)
  end
end

describe LinksController, "create action" do
  include LinkSpecHelper
  controller_name :links
    
  it "should redirect an expired URL to the 'expired' page" do
    post :create, :link => expired_website_url
    response.should render_template( 'links/expired' )
  end
end

describe LinksController, "redirect routing" do
  controller_name :links
  
  it "should route to the redirect action in LinksController" do
    assert_routing '/abc', { :controller => 'links', :action => 'redirect', :token => 'abc' }
  end
  
  it "should redirect to the invalid page when the token is invalid" do
    get :redirect, :token => 'magoo'
    response.should redirect_to( :action => 'invalid' )
  end
end

describe LinksController, "redirect with token" do
  
  before(:each) do
    @link = mock( 'link' )
    Link.should_receive( :find_by_token ).with( 'abcd' ).and_return( @link )
    @link.stub!( :add_visit )
    @link.should_receive( :thomas_permalink ).and_return( 'http://thomas.loc.gov/cgi-bin/query/z?r108:E26MR4-0015:' )
    get :redirect, :token => 'abcd'    
  end
  
  it "should call redirected to a website when passed a token" do
    response.should redirect_to( 'http://thomas.loc.gov/cgi-bin/query/z?r108:E26MR4-0015:' )
  end
end
