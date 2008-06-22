require 'date'

# Calendar
module Calendar

  VERSION = '0.1.0'

  def calendar(options = {}, &block)
    raise(ArgumentError, "No year given")  unless options.has_key?(:year)
    raise(ArgumentError, "No month given") unless options.has_key?(:month)

    block                        ||= Proc.new {|d| nil}

    defaults = {
      :table_class => 'calendar',
      :month_name_class => 'monthName',
      :other_month_class => 'dif_month',
      :day_name_class => 'dayName',
      :day_class => 'day',
      :first_day => 1,
      :last_day => -1,
      :abbrev => (0..2),
      :first_day_of_week => 0,
      :accessible => true,
      :show_today => true,
      :previous_month_text => nil,
      :next_month_text => nil
    }
    options = defaults.merge options

    first = Date.civil(options[:year], options[:month], options[:first_day])
    last = Date.civil(options[:year], options[:month], options[:last_day])

    first_weekday = first_day_of_week(options[:first_day_of_week])
    last_weekday = last_day_of_week(options[:first_day_of_week])
    
    day_names = Date::DAYNAMES.dup
    first_weekday.times do
      day_names.push(day_names.shift)
    end

    cal = "<h2 class=\"calendar\">#{Date::MONTHNAMES[options[:month]]} #{options[:year]}</h2>"
    cal << %(<table class="#{options[:table_class]}" border="0" cellpadding="0" cellspacing="1" width="100%">)
    cal << %(<thead><tr>)
    if options[:previous_month_text] or options[:next_month_text]
      cal << %(<th colspan="2">#{options[:previous_month_text]}</th>)
      colspan=3
    else
      colspan=7
    end
    day_names.each do |d|
      unless d[options[:abbrev]].eql? d
        cal << "<th scope='col' width=\"14%\"><abbr title='#{d}'>#{d[options[:abbrev]]}</abbr></th>"
      else
        cal << "<th scope='col' width=\"14%\">#{d[options[:abbrev]]}</th>"
      end
    end
    cal << "</tr></thead><tbody><tr>"
    beginning_of_week(first, first_weekday).upto(first - 1) do |d|
      cal << %(<td class="#{options[:other_month_class]})
      cal << " weekendDay" if weekend?(d)
      if options[:accessible]
        cal << %(">#{d.day}<span class="hidden"> #{Date::MONTHNAMES[d.month]}</span></td>)
      else
        cal << %(">#{d.day}</td>)
      end
    end unless first.wday == first_weekday
    first.upto(last) do |cur|
      cell_text, cell_attrs = block.call(cur)
      cell_text  ||= cur.mday
      cell_attrs ||= {:class => options[:day_class]}
      cell_attrs[:class] += " weekendDay" if [0, 6].include?(cur.wday) 
      cell_attrs[:class] += " today" if (cur == Date.today) and options[:show_today]  
      cell_attrs = cell_attrs.map {|k, v| %(#{k}="#{v}") }.join(" ")
      cell_text = "<b>#{cell_text}</b> TODAY" if (cur == Date.today) and options[:show_today]
      cal << "<td #{cell_attrs}>#{cell_text}</td>"
      cal << "</tr><tr>" if cur.wday == last_weekday
    end
    (last + 1).upto(beginning_of_week(last + 7, first_weekday) - 1)  do |d|
      cal << %(<td class="#{options[:other_month_class]})
      cal << " weekendDay" if weekend?(d)
      if options[:accessible]
        cal << %(">#{d.day}<span class='hidden'> #{Date::MONTHNAMES[d.mon]}</span></td>)
      else
        cal << %(">#{d.day}</td>)        
      end
    end unless last.wday == last_weekday
    cal << "</tr></tbody></table>"
  end
  
  private
  
  def first_day_of_week(day)
    day
  end
  
  def last_day_of_week(day)
    if day > 0
      day - 1
    else
      6
    end
  end
  
  def days_between(first, second)
    if first > second
      second + (7 - first)
    else
      second - first
    end
  end
  
  def beginning_of_week(date, start = 1)
    days_to_beg = days_between(start, date.wday)
    date - days_to_beg
  end
  
  def weekend?(date)
    [0, 6].include?(date.wday)
  end
  
end
