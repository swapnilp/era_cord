module MetadataSubmittable
  extend ActiveSupport::Concern

  private

  def keys_from_schema(schema_data)
    allowed_keys = []

    schema_data.each do |sch|
      allowed_keys << (sch['multiple'].present? ? { sch['name'].to_sym => [] } : sch['name'].to_sym)
    end

    allowed_keys
  end
end
