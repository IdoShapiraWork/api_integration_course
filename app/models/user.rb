class User < ApplicationRecord


  def update(server_user)
    self.avatar = server_user['avatar']
    self.role = server_user['role']
    self.username = server_user['username']
    self.points = server_user['points']
  end

  def verify
    self.verified = 1
  end
end
