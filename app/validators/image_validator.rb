class ImageValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.attached?

    is_image = value.content_type.in?(%w[image/jpeg image/jpg image/png image/svg+xml])

    if !is_image
      record.errors.add(attribute, :file_type_not_image)
    end

    if value.blob.byte_size > 10.megabytes
      record.errors.add(attribute, :file_too_large)
    end
  end
end
