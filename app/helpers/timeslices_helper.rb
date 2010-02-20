module TimeslicesHelper
  def export_link(text)
    opts = { :action => 'index', :date => params[:date], :format => 'csv' }
    [:end_date,:task_id].each do |param|
      opts[param] = params[param] unless params[param].blank?
    end
    link_to text, opts, :class => 'export'
  end
end
