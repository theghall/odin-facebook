module WorthiesHelper
  def user_marked_worthy(user, post)
    Worthy.exists?(post_id: post.id, user_id: user.id)
  end

  def worthy_count_text(post)
    you = post.reaction_users.include?(current_user)

    count = post.reaction_users.count

    if you && count == 1
      text = 'You'
    else
      text = (you == true ? "You and #{count - 1}" + ' ' + 'other'.pluralize(count - 1) : "#{count}")
    end
  end

  def worthy_users(post)
    post.reaction_users.pluck(:name).join(', ')
  end
end
