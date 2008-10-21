class UsersController < ApplicationController
  before_filter :login_required, :admin_required
  before_filter :load_user, :except => [:index, :new, :create]
  
  def index
    @users = User.find(:all, :order => 'name')
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to users_path
    else
      render :action => 'new'
    end
  end
  
  def show
  end
  
  def update
    if @user.update_attributes(params[:user])
      redirect_to users_path
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @user.destroy
    
    flash[:notice] = "#{@user.name} deleted"
    redirect_to users_path
  end
  
  private 
  
  def load_user
    @user = User.find(params[:id])
  end
end
