class User < ApplicationRecord


  def update(avatar, role, username, points)
    self.avatar = avatar
    self.role = role
    self.username = username
    self.points = points
    save
  end

  def verify
    self.verified = 1
  end
end
