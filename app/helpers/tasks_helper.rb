module TasksHelper
  def task_tree(task)
    content_tag :li, :rel => task.id, :class => "task" do
      if task.leaf?
        task.name
      else
        task.name + content_tag(:ul) do
          task.children.map {|t| task_tree(t)}.join
        end
      end
    end
  end

  def task_sparkline(task, range = 13.days.ago .. Date.today)
    range.collect { |date| task.branch_duration(date) }.join(',')
  end
end
