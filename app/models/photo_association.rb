# frozen_string_literal: true

class PhotoAssociation < ApplicationRecord
  belongs_to :photo, inverse_of: :photo_associations
  belongs_to :photographable, polymorphic: true
  belongs_to :crop, optional: true, counter_cache: true

  validate :photo_and_item_have_same_owner

  ##
  ## Triggers
  before_save :set_crop
  after_create { |record| record.photographable.reindex }
  after_destroy { |record| record.photographable.reindex }

  def item
    photographable
  end

  def self.item(item_id, item_type)
    find_by!(photographable_id: item_id, photographable_type: item_type).photographable
  end

  def set_crop
    if %w(Planting Seed Harvest).include?(photographable_type)
      self.crop_id = photographable.crop_id
    elsif photographable_type == 'Crop'
      self.crop_id = photographable_id
    end
  end

  private

  def photo_and_item_have_same_owner
    return unless photographable_type != 'Crop'

    errors.add(:photo, "must have same owner as item it links to") unless photographable.owner_id == photo.owner_id
  end
end
