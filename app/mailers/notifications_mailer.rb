class NotificationsMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications_mailer.first_notice.subject
  #
  def first_notice(debt, user)
    authenticate_user!(user)

    @debt = debt
    @user = user
    add_return_receipt headers, @user.email
    @display_attachments = true
    add_signature!

    mail(from: @user.email,
         to:   @debt.debtor.email,
         bcc:  @user.email,
         subject: t('notifications_mailer.first_notice.subject'), &:html)
  end

  def second_notice(debt, user)
    authenticate_user!(user)

    @debt = debt
    @user = user
    add_return_receipt headers, @user.email
    @display_attachments = true
    add_signature!

    mail(from: @user.email,
         to:   @debt.debtor.email,
         bcc:  @user.email,
         subject: t('notifications_mailer.second_notice.subject'), &:html)
  end

  private

  def authenticate_user!(user)
    fail I18n.t('errors.not_authorized') if user.nil?
  end

  def add_return_receipt(headers, email)
    headers[:'Return-Receipt-To'] = email
    headers[:'Disposition-Notification'] = email
    headers[:'X-Confirm-Reading-To'] = email
  end

  def add_logo!
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/57.png")
  end

  def add_signature!
    attachments.inline['signature.jpg'] = File.read("#{Rails.root}/app/assets/images/signature.jpg")
  end
end
