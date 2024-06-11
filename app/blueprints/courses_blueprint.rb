# frozen_string_literal: true

class CoursesBlueprint < Blueprinter::Base
  fields :title, :description
  field(:fullname, name: :creator) do |_user, options|
    options[:fullname]
  end
end
