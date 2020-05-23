# Action Controller (Application Controller inherits)
class ApplicationController < ActionController::Base
  include Pagy::Backend
  protect_from_forgery with: :exception
  around_action :switch_locale
  before_action { @pagy_locale = params[:locale] || 'en' }


  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def default_url_options
    { locale: I18n.locale }
  end
end
