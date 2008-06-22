class CalendarGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      calendar_style_dir = "public/stylesheets/calendar"
      m.directory calendar_style_dir
      m.file File.join("style.css"), File.join(calendar_style_dir, "style.css")
    end
  end
end
