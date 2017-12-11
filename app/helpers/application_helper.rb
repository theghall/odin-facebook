module ApplicationHelper
  def app_name
    "OdinBook"
  end

  def full_title(title = '')
    title.empty? ? app_name : title + ' | ' + app_name
  end
end
