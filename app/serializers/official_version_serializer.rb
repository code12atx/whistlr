class OfficialVersionSerializer < ActiveModel::Serializer
  root :serializer
  embed :ids, include: true
  
  attributes :id, :type, :approved, :declined, :pending, :bio, :facebook_alias, :facebook_id, :name, :twitter_alias, :website
  has_one :upload

  has_one :user
  has_one :master, root: :officials
  has_one :version_attributes
  has_one :poll_attributes
end
