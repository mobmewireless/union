module ApplicationHelper
  def admin?
    APP_CONFIG['admin_emails'].include? session[:authenticated]['info']['email'].strip
  end

  def shorten_if_required(text, allowed_length)
    if text.length > allowed_length
      (text[0..3] + "<a href='#' title='#{text}'>...</a>").html_safe
    else
      text
    end
  end

  def controller?(*controller)
    controller.include?(params[:controller])
  end

  def action?(*action)
    action.include?(params[:action])
  end

  def email_name(email_address)
    return email_address unless email_address.include? '@'

    concerned_segment = email_address.split('@').first

    concerned_segment.split(/[\W_]/).map do |word|
      word.capitalize
    end.join ' '
  end
end
