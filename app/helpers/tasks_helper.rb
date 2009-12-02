module TasksHelper
  def task_tree(task)
    content_tag :li, :id => "task-#{task.id}", :class => "task" do
      if task.leaf?
        task.name
      else
        task.name + content_tag(:ul) do
          task.children.map {|t| task_tree(t)}.join
        end
      end
    end
  end
end
