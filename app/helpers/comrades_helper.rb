module ComradesHelper
  def make_list(common_comrades)
    common_comrades.map{|u| u.name}.join(', ')
  end
end
