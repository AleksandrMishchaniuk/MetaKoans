
  def attribute(arg, &block)
    
    name = arg
    if arg.class == Hash
      arg.each { |key, val| name = key }
    end

    class_variable_set("@@#{name}".to_sym, nil) unless class_variable_defined?("@@#{name}".to_sym)

    if arg.class == Hash
      arg.each do |key, val|
        class_variable_set("@@#{name}".to_sym, val)
      end
    end

    if block
      class_variable_set("@@#{name}".to_sym, block)
    end

    # puts class_variables.to_s

    define_method :initialize do
      self.class.class_variables.each do |var|
        val = self.class.class_variable_get(var)
        var = var.to_s.delete('@')
        val = self.instance_eval &val if val.class == Proc
        self.instance_variable_set(("@"+var).to_sym, val)
      end
    end

    define_method name.to_sym do 
      val = self.instance_variable_get(("@"+name).to_sym)
      return self.instance_eval &val if val.class == Proc
      val
    end

    define_method "#{name}=".to_sym do |val|
      self.instance_variable_set(("@"+name).to_sym, val)
    end
    
    define_method "#{name}?".to_sym do 
      return false unless self.instance_variable_get(("@"+name).to_sym)
      self.instance_variable_defined?(("@"+name).to_sym)
    end

  end
