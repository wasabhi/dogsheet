class Task < ActiveRecord::Base
  validates_presence_of :name

  NAME_SEPARATOR = ':'

  belongs_to :user
  has_many :timeslices, :dependent => :destroy

  acts_as_nested_set

  def duration
    duration = 0
    timeslices.each do |timeslice|
      duration += timeslice.duration
    end
    duration
  end

  # Return the duration of this task and all it's children
  def branch_duration
    self.self_and_descendants.inject(0) { |sum,task| sum + task.duration }
  end

  # Return the task name prefixed by the given string multiplied by the
  # tasks tree depth.
  def name_with_depth(prefix = '-')
    "#{prefix * self.level}#{self.name}"
  end

  def name_with_ancestors(separator = NAME_SEPARATOR)
    if self.root?
      return self.name
    else
      return self.parent.name_with_ancestors(separator) + separator + self.name
    end
  end

  # Returns the task name sanitized for filesystem use.  
  def safe_name
    name.strip.gsub(/[^0-9A-Za-z.\-_ ]/, '').gsub(/ +/,'_')
  end

  # Returns the ids for this task and all it's descandants as an array
  def branch_ids
    self.self_and_descendants.collect { |task| task.id }
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
