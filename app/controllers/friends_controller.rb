class FriendsController < ApplicationController
  def create
    form = FriendApplyForm.includes(:user).find_by(id: params[:form_id])
    current_user.friends_friend.create(user_id: params[:id])
    current_user.users_friend.create(friend_id: params[:id])
    chatroom = Chatroom.create
    chatroom.chatroom_groups.create(user_id: current_user.id)
    chatroom.chatroom_groups.create(user_id: params[:id])
    current_user.followers_follower.create! user_id: params[:id]
    current_user.users_follower.create! follower_id: params[:id]

    form.destroy
    redirect_back fallback_location: root_path
  end

  def destroy
    friend_id = params[:id].to_i
    users = [current_user.id, friend_id]

    groups = ChatroomGroup.where("user_id in (?)", users).map{|group| group.chatroom_id}.compact.uniq
    room = Chatroom.where("id in (?) and is_group = ?", groups, false).first
    room.destroy if room

    friend = Friend.where("(user_id = ? and friend_id = ?) or (user_id = ? and friend_id = ?)", current_user.id, params[:id], params[:id], current_user.id)
    friend.destroy_all if friend

    followers = Follower.where("follower_id = ? and user_id = ? or follower_id = ? and user_id = ? ", current_user.id, friend_id, friend_id, current_user.id)
    followers.destroy_all if followers

    redirect_back fallback_location: root_path
  end
end
