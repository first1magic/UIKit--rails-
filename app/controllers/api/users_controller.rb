class Api::UsersController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [
  :sign_in, :update, :auth_facebook, :auth_line, :update_user_append, :update_user_mail, :update_user_anniversaries, :delete_user_anniversary, :update_reg_key, :reg_key_complete]
  skip_filter :authenticate_user!, :only=>[:auth_facebook, :auth_line]

  def index
    ret = {"status" => "error", "data" => "nodata", "at" => "user_index"}
    if me
      user = me.attributes
      append = UserAppend.where(user_id: me.id)
      if append
        append = append.first.attributes
        user = append.merge(user)
      end
      ret[:status] = "ok"
      ret[:data] = user
    end
    render :json => ret
  end
  
  def show(id)
    ret = {"status" => "error", "data" => "nodata", "at" => "user_show"}
    render :json => ret
  end
  
  def sign_in
      render :json => {"ans" => "ok"}
  end
  
  def update
      id = params[:id]
    ret = {"status" => "error", "data" => "nodata", "at" => "update"}
    
    user = User.find_by(id)
    if user
      if params[:tel]
        user.tel = params[:tel]
      end
      if params[:company_name]
        user.company_name = params[:company_name]
      end
      if params[:lastname_kana]
        user.lastname_kana = params[:lastname_kana]
      end
      if params[:firstname_kana]
        user.firstname_kana = params[:firstname_kana]
      end
      
      if user.save
         ret[:data] = user
         ret[:status] = "ok"
       end
    end
    
    render :json => ret
  end
  
  def credit_cards
    ret = {"status" => "error", "data" => "nodata", "at" => "user_credit_cards"}
    
    if me
        userId = me.id
        cards = UserCreditCard.where("user_id = ?", userId).order('card_count')
        ret[:status] = "ok"
        ret[:cards] = cards		#Modify by ARURU
    end
    render :json => ret
  end
  
  def update_user_append
    ret = {"status" => "error", "data" => "nodata", "at" => "user_append"}
    
    userId = params[:user_id]
    allergy = params[:allergy]
    favorite = params[:favorite]
    dislike = params[:dislike]
    
    if userId
      append = UserAppend.where(user_id: userId).first
      if !append
        append = UserAppend.new
        append.user_id = userId
      end
      
      if allergy
        append.allergy = allergy
      end
      if favorite
        append.favorite_food = favorite
      end
      if dislike
        append.dislike_food = dislike
      end
      append.save
      
      ret[:status] = "ok"
      ret[:data] = append
    end
    
    render :json => ret
  end
  
  def auth_facebook
    user = User.find_for_facebook_from_api(params)
    sign_in("user", user)
    render :json => {:success=>true, :uuid=>user.uuid}
  end

  def auth_line
    auth = {
        "provider" => "line",
        "uid" => params[:uid],
        "info" => {
          "nickname" => params[:nickname]
        },
        "credentials" => {
          "token" => params[:access_token],
          "expires_at" => params[:expire_at].to_f,
          "refresh_token" => params[:refresh_token]
        }
      }
    user_provider = UserProvider.find_by(:provider => "line", :uid => params["uid"])
    if user_provider
      user = user_provider.user
      user.update_line_token(auth)
      sign_in('user', user)
      render json: { status: 'ok', uuid: user.uuid }
    else
      user = User.new
      line = {
        provider:  auth["provider"],
        uid: auth["uid"],
        token: auth["credentials"]["token"],
        expire: auth["credentials"]["expire_at"],
        refresh_token: auth["credentials"]["refresh_token"]
      }
      session[:auth] = auth
      session[:pre_user] = user
      session[:pre_provider] = line
      session[:from_line] = 1
      session[:ios] = 1
      render json: { status: 'error' }
    end
  end

  def user_append
      user_append = me.user_append
      render :json => {:allergy=>user_append.allergy, :favorite_food=>user_append.favorite_food, :dislike_food=>user_append.dislike_food}
  end

  def update_user_mail
      user = me
      user.touch
      featured_mail_notification = params[:featured_mail_notification]
      mail_magazine = params[:mail_magazine]
      if featured_mail_notification
          user.featured_mail_notification = featured_mail_notification
      end
      if mail_magazine
          user.mail_magazine = mail_magazine
      end
      if user.mail_magazine_changed?
          user.mail_updated_at = Time.now
      end
      user.save
      render :json => {:status=>"ok", :success=>true}
  end

  def user_mail
      user = me
      render :json => {:status=>"ok", :data=>{
          :mail_magazine=>user.mail_magazine, :featured_mail_notification=>user.featured_mail_notification}}
  end

  def user_anniversaries
    ret = {"status" => "error", "data" => "nodata", "at" => "update"}
    user_anniversaries = UserAnniversary.where(user_id: me.id)      
    ret[:data] = user_anniversaries
    ret[:status] = "ok"
    render :json => ret
  end

  def update_user_anniversaries
    ret = {"status" => "error", "data" => "nodata", "at" => "update"}
    puts params
    p = params
    p.delete("action")
    p.delete("controller")
    @user_anniversary = UserAnniversary.new(p)
    @user_anniversary[:user_id] = me.id
    if @user_anniversary.save
      
      notice = {
        notice: I18n.t("flash.user_anniversary_created")
      }
      ret[:status] = "ok"
    end
    render :json => ret
  end

  def delete_user_anniversary
    ret = {"status" => "error", "data" => "nodata", "at" => "update"}
    id = params[:id]
    begin
        @user_anniversary = UserAnniversary.where(user_id: me.id).find(id)
        @user_anniversary.destroy
    else
        ret[:status] = "ok"
    end
    render :json => ret
  end

  def update_reg_key
    user = me
    line = LinePay.new(user.id)
    begin
      from_device = 99
      result = line.line_key_request(from_device)
    rescue LineException => e
      render :json => { status: "error" }
    else
      payment_url = result["info"]["paymentUrl"]["app"]
      transaction_id = result["info"]["transactionId"]
      render :json => { status: "ok", data: { payment_url: payment_url, transaction_id: transaction_id } }
    end
  end

  def reg_key_complete
    user = me
    line = LinePay.new(user.id)
    begin
      result = line.line_confirm(0, params[:transactionId])
    rescue LineException => e
      render :json => { status: "error" }
    else
      user.reg_key = result["info"]["regKey"]
      user.save
      render :json => { status: "ok" }
    end
  end

  def invitation_code
    user = me
    if user.invitation_code.blank?
      user.update_attribute(:invitation_code, User::generate_code)
    end
    ret = {"status" => "error", "data" => "nodata"}   
    ret[:data] = user.invitation_code
    ret[:status] = "ok"
    render :json => ret
  end



end
