# encoding: utf-8
class UsersController < ApplicationController
  include UserConcern

  skip_filter :authenticate_user!, :only => [:root, :login, :resign_complete, :view_experience, :facebook,
       :login_from_uuid, :check_session, :uuid, :check_register]
  skip_before_filter :verify_authenticity_token, :only => [:login_from_uuid]

  def root
    if logged_in?
      redirect_to home_path and return
    else
      redirect_to login_path and return
    end
  end

  def check_register
      ret = {"status" => "error", "ans" => "no"}
      user = User.where(email: params[:email])
      if user
          ret[:status] = "ok"
          if user.count > 0
              ret[:ans] = "yes"
          end
      end
      render json: ret
  end

  def login
    redirect_to home_path if logged_in?
    session[:pre_user] = nil
    session[:pre_provider] = nil
    session[:from_facebook] = nil
    if InvitationCode.valid?(params[:invite_code])
      session[:invite_code] = params[:invite_code]
    else
      session[:invite_code] = nil
    end
  end
  
  def edit_user_append
    @user = me
    @user_append = me.user_append
  end
  
  def edit_user_mail
    @user = me
  end

  def update_user_mail
    user = me
    user.touch
    user.attributes = params[:user]

    @user = me

    if user.mail_magazine_changed?
      user.mail_updated_at = Time.now
    end

    if not user.save
      flash[:error] = I18n.t("flash.input_error")
      render :action => "edit_user_mail"
    else
      flash[:notice] = I18n.t("flash.updated", :name => "設定")
      redirect_to edit_user_mail_users_path
    end
  end
  
  def update_user_append
    user = me
    user.touch

    user_append = me.user_append
    user_append.user_id = user.id
    user_append.allergy = params[:user_append][:allergy]
    user_append.favorite_food = params[:user_append][:favorite_food]
    user_append.dislike_food = params[:user_append][:dislike_food]

    @user = me
    @user_append = me.user_append

    if not user.save && user_append.save
      flash[:error] = I18n.t("flash.input_error")
      render :action => "edit_user_append"
    else
      flash[:notice] = I18n.t("flash.updated", :name => "設定")
      redirect_to edit_user_append_users_path
    end
  end
  
  def resign
    @user = me
    session[:withdrawal] ||= {}
    @user.withdrawal = User.new(session[:withdrawal]).withdrawal
  end

  def resign_confirm
    @user = me
    session[:withdrawal] = params[:user]
    @user.withdrawal = User.new(session[:withdrawal]).withdrawal
  end
  
  def resign_do
    @user = me
    @user.withdrawal = User.new(session[:withdrawal]).withdrawal
    if @user.reservations.where("visit_time >= ? and status <> ? and status <>?",
                                 DateTime.now, Reservation::STATUS_CANCEL_COMP, Reservation::STATUS_SHOP_CANCEL).present? ||
       @user.reservations.where("payment_flag = ? and payment_status <> ? and payment_status <> ? and status <> ? and status <>?", 
                                 true, Reservation::PAYMENT_STATUS_CHARGED, Reservation::PAYMENT_STATUS_CHARGED_CANCEL_FEE, 
                                       Reservation::STATUS_CANCEL_COMP, Reservation::STATUS_SHOP_CANCEL).present? 
      flash[:notice] = t("flash.resign_fail_for_reservation")
      render "resign_confirm"
    else
      withdrawal_user = @user
      if @user.destroy_with_sns_provider
        SignupMailer.resign_complete(withdrawal_user).deliver()
        redirect_to :action => "resign_complete"
      else
        flash[:notice] = t("flash.resign_user_fail")
        render "resign_confirm"
      end
    end
  end
  
  def resign_complete
    session[:withdrawal] = nil
  end

  def view_experience
    me.update_attributes(:guide_flag => true) if logged_in?

    blank = Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==")
    send_data blank, :type => "image/gif" , :disposition => "inline"

  end

  def facebook
      access_token = params[:access_token]
      if access_token
          @graph = Koala::Facebook::API.new(access_token)
          profile = @graph.get_object("me")
          user = User.find_by_email(profile["email"])
          auth = {"provider" => "facebook", "uid" => profile["id"], 
                "credentials" => {"token" => access_token},
                "info" => {"nickname" => profile["last_name"] + profile["first_name"]}}
          if user
              user.update_facebook_token(auth)
          else
              gender = 3
              gender = 1 if profile["gender"] == "male"
              gender = 2 if profile["gender"] == "female"
              user = User.new(
                  :email => profile["email"],
                  :lastname => profile["last_name"],
                  :firstname => profile["first_name"],
                  :gender => gender,
                  :birthday => Date.strptime(profile["birthday"], "%m/%d/%Y")
              )
              facebook = {
                  :provider =>  "facebook",
                  :uid => profile["id"],
                  :name => profile["last_name"] + profile["first_name"],
                  :token => access_token
              }
              session[:auth] = auth
              session[:pre_user] = user
              session[:pre_provider] = facebook
              session[:from_facebook] = 1
              return redirect_to new_user_registration_path
          end

          if user
              sign_in user
              if session[:facebook_register]
                  session[:facebook_register] = nil
                  signup_complete_mail_with_coupon_mail(user)
                  flash[:notice] = I18n.t("flash.register_user_complete")
                  if Rails.env == "production"
                      flash[:conversion] = '/facebook_registration.html'
                      flash[:mixpanel] = 'Registered Member'
                  end
                  return redirect_to (user.is_japanese? ? tour_path : search_language_path)
              else
                  if session[:ref_restaurant]
                      session["user_return_to"] = restaurant_url(session[:ref_restaurant])
                  end
                  return redirect_to session["user_return_to"] || home_path
              end
          end
      end
  end

  def uuid
     set_uuid
     @user = me
     render json: @user
  end

  def login_from_uuid
      @user = User.where(:uuid => params[:uuid])[0]
      sign_in @user
      render json: {"status" => "ok","data" => @user}
  end
  
  def check_session
      dic = {}
      if logged_in?
        dic["session"] = true
      else
        dic["session"] = false
      end
      render json: dic
  end

  def reg_key
    @user = me
    session[:from_reservation] = params[:reservation] == "true" ? true : false
  end

  def update_reg_key
    @user = me
    line = LinePay.new(@user.id)
    begin
      result = line.line_key_request
    rescue LineException => e
      render :action => "reg_key"
    else
      redirect_to result["info"]["paymentUrl"]["web"]
    end
  end

  def reg_key_complete
    @user = me
    @from_reservation = session[:from_reservation]
    session[:from_reservation] = nil

    line = LinePay.new(@user.id)
    begin
      result = line.line_confirm(0, params[:transactionId])
    rescue LineException => e
      flash[:error] = t("flash.reserve_linepay_error")
    else
      @user.reg_key = result["info"]["regKey"]
      @user.save
    end
  end

  def google_auth
  end
end
