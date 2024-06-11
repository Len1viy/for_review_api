# frozen_string_literal: true

require_relative '../blueprints/courses_blueprint'

class CoursesService
  attr_reader :user, :params

  def initialize(user, params)
    @user = user
    @params = params
  end

  PAGE = 1

  def page
    params[:page]&.to_i || PAGE
  end

  PER_PAGE_DEF = 10

  def per_page
    params[:per_page]&.to_i || PER_PAGE_DEF
  end

  def limit
    per_page
  end

  def offset
    (page - 1) * per_page
  end

  def index
    if params[:student_id] && params[:tutor_id]
      @courses = Course.courses_by_teacher_and_student(params[:student_id], params[:tutor_id]).limits(limit, offset)
    elsif params[:tutor_id]
      @courses = Course.courses_by_teacher(params[:tutor_id]).limits(limit, offset)
    elsif params[:student_id]
      @courses = Course.courses_by_student(params[:student_id]).limits(limit, offset)
      @courses = @courses.map do |title, description, user_id|
        { student: User.find(params[:student_id]).fullname, title: title, description: description,
          creator: User.find(user_id).fullname }.as_json
      end
      return @courses
    else
      @courses = Course.all.limits(limit, offset)
    end
    @courses.map do |elem|
      CoursesBlueprint.render_as_json(elem, fullname: User.find(elem[:teacher_id])[:fullname])
    end
  end

  def create_course(course_params)
    return { data: '403 Forbidden', status: :forbidden } unless @user.root.eql? 2

    @course = @user.teacher_courses.new(title: course_params[:title], description: course_params[:description])
    return { data: { description: course_params[:description], fullname: @user.fullname }, status: :ok } if @course.save

    { data: @course.errors, status: :unprocessable_entity }
  end

  def subscribe
    return { data: '403 Forbidden', status: 403 } unless @user.root.eql? 1

    course = Course.find_by(id: params[:id])
    return { data: 'Course was not found', status: :unprocessable_entity } unless course

    enrollment = @user.enrollments.create(course_id: params[:id])
    return { data: {}, status: :ok } if enrollment.save

    { data: enrollment.errors, status: :unprocessable_entity }
  end

  def show
    course = Course.find_by(id: params[:id])
    return {} unless course

    ids = []
    Enrollment.where(course_id: course.id).each do |enrollment|
      ids.append(enrollment.user_id)
    end
    students = User.where(id: ids)
    { json: { title: course.title, description: course.description, fullname: User.find(course.teacher_id).fullname,
              students: students.pluck(:fullname) } }
  end
end
