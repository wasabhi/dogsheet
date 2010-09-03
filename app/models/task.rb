class Task < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [:parent_id, :user_id]

  NAME_SEPARATOR = ':'

  belongs_to :user
  has_many :timeslices, :dependent => :destroy

  acts_as_nested_set

  # Returns the timeslices of this task an all it's children
  def branch_timeslices
    Timeslice.by_task_ids branch_ids
  end

  # Creates an array of tasks by splitting the passed string on NAME_SEPARATOR.
  # Each task will be the child of the previous in the string.
  #
  # If root_task is passed, this will be set as the parent of the first task
  # created.  Otherwise, the first task will be a root level task.
  def self.split_and_create(string, root_task = nil)
    tasks = string.split(':').collect do |name|
      Task.create :name => name.strip
    end
    tasks.inject(root_task) do |previous,current|
      unless previous.nil? or !current.instance_of?(Task)
        current.parent = previous
        current.save
      end
      current
    end
    tasks
  end

  def duration(date = nil)
    duration = 0
    if date.nil?
      slices = timeslices.each
    else
      slices = timeslices.by_date(date).each
    end
    slices.each do |timeslice|
      duration += timeslice.duration
    end
    duration
  end

  # Return the duration of this task and all it's children
  def branch_duration(date = nil)
    self.self_and_descendants.inject(0) { |sum,task| sum + task.duration(date) }
  end

  # Returns an array of durations for each day in daterange
  def branch_duration_array(daterange)
    daterange.collect { |date| branch_duration(date) }
  end

  # Returns a string for use in the jquery sparkline graphs
  def sparkline(daterange = 28.days.ago.to_date .. Date.today)
    branch_duration_array(daterange).join(',')
  end

  # Return the task name prefixed by the given string multiplied by the
  # tasks tree depth.
  def name_with_depth(prefix = '-')
    "#{prefix * self.level}#{self.name}"
  end

  # Return the name of the task and all it's ancestors, separated by separator.
  #
  # The optional back_to argument is a task which must be an ancestor of this
  # task.  If supplied, the task passed as back_to and all of it's ancestors
  # will be excluded from the name.
  def name_with_ancestors(separator = NAME_SEPARATOR, back_to = nil)
    self_and_ancestors.reject do |task|
      task.is_or_is_ancestor_of? back_to unless back_to.nil?
    end.map(&:name).join(separator)
  end

  # Returns the task name sanitized for filesystem use.  
  def safe_name
    name.strip.gsub(/[^0-9A-Za-z.\-_ ]/, '').gsub(/ +/,'_')
  end

  # Returns the ids for this task and all it's descandants as an array
  def branch_ids
    self.self_and_descendants.collect { |task| task.id }
  end

  # If rate is nil on a Task, it is inherited from the parent recursively
  # until a non nil rate is found.  If the root task is reached and it has
  # a nil rate, nil is returned
  def rate
    # If this record has a rate value in the db, return it
    if attribute_present? :rate
      attributes['rate']
    else
      # If this task has a parent, return the rate from that, else
      # theirs nowhere left to recurse to so return nil
      if root?
        nil
      else
        parent.rate
      end
    end
  end

  def create_xero_invoice(gateway, contact, timeslices, account_code)
    invoice = gateway.build_invoice({
      :invoice_type => "ACCREC",
      :due_date => 1.month.from_now # TODO - Make configurable
    })
    invoice.contact.name = contact
    timeslices.each do |timeslice|
      invoice.add_line_item({
        :description => timeslice.task.name_with_ancestors(':', self),
        :unit_amount => timeslice.task.rate,
        :quantity => timeslice.decimal_hours,
        :account_code => account_code
      })
    end
    response = invoice.create
    if response.invoice.invoice_number
      timeslices.each do |timeslice|
        # TODO - Handle errors
        timeslice.update_attribute(:invoice_number, 
                                   response.invoice.invoice_number)
      end
    end
    response.invoice
  end

  # Returns true if this task has any timeslices which have not been billed.
  # Checks the tasks child tasks as well if deep is true, otherwise only
  # checks this task.  deep defaults to true.
  def has_unbilled_timeslices?(deep = true)
    Timeslice.unbilled.by_task(self,deep).count > 0
  end

  # By default, sort all finders by lft
  def self.find(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    if not options.include? :order
      options[:order] = 'lft'
    end
    args.push(options)
    super
  end
end
