class NotificationsMailerPreview < ActionMailer::Preview
  def first_notice
    NotificationsMailer.first_notice(Debt.first, User.first)
  end

  def second_notice
    NotificationsMailer.second_notice(Debt.first, User.first)
  end
end
