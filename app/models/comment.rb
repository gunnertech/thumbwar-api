class Comment < ActiveRecord::Base
  mount_uploader :photo, PhotoUploader
  
  attr_accessible :body, :user_id, :photo
  acts_as_nested_set :scope => [:commentable_id, :commentable_type]

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  #acts_as_votable

  belongs_to :commentable, :polymorphic => true

  # NOTE: Comments belong to a user
  belongs_to :user

  has_many :alerts, as: :alertable

  validates :user, :presence => true

  after_create :create_alert

  default_scope { order('id ASC') }

  # Helper class method that allows you to build a comment
  # by passing a commentable object, a user_id, and comment text
  # example in readme
  def self.build_from(obj, user_id, comment)
    new \
      :commentable => obj,
      :body        => comment,
      :user_id     => user_id
  end

  #helper method to check if a comment has children
  def has_children?
    self.children.any?
  end

  # Helper class method to lookup all comments assigned
  # to all commentable types for a given user.
  scope :find_comments_by_user, lambda { |user|
    where(:user_id => user.id).order('created_at DESC')
  }

  # Helper class method to look up all comments for
  # commentable class name and commentable id.
  scope :find_comments_for_commentable, lambda { |commentable_str, commentable_id|
    where(:commentable_type => commentable_str.to_s, :commentable_id => commentable_id).order('created_at DESC')
  }

  # Helper class method to look up a commentable object
  # given the commentable class name and id
  def self.find_commentable(commentable_str, commentable_id)
    commentable_str.constantize.find(commentable_id)
  end

  def create_alert
    unless body.match(/evidence--/)
      commentable.watchers.each do |watcher|
        watcher.alerts.create!(alertable: self, body: "#{user.display_name} posted a new comment") unless user == watcher
      end
    
      commentable.challenges.where{status != 'rejected' }.each do |challenge|
        challenge.user.alerts.create!(alertable: self, body: "#{user.display_name} posted a new comment") unless user == challenge.user
      end
    
      commentable.challenger.alerts.create!(alertable: self, body: "#{user.display_name} posted a new comment") unless user == commentable.challenger
    end
  end
  handle_asynchronously :create_alert
end
