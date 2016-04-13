
  def attribute(arg, &block)
    
    name = arg

    class_variable_set(:@@inits, {}) unless class_variable_defined?(:@@inits)

    if arg.class == Hash
      inits = class_variable_get(:@@inits)
      arg.each do |key, val|
        name = key
        inits[name] = val
      end
      class_variable_set(:@@inits, inits)
    end

    if block
      inits = class_variable_get(:@@inits)
      inits[name] = block
      class_variable_set(:@@inits, inits)
    end

    puts class_variable_get(:@@inits)
    puts class_variables

    define_method :initialize do
      self.class.class_variable_get(:@@inits).each do |name, val|
        val = self.instance_eval &val if val.class == Proc
        self.instance_variable_set(("@"+name).to_sym, val)
      end
    end

    define_method name.to_sym do 
      self.instance_variable_get(("@"+name).to_sym)
    end

    define_method "#{name}=".to_sym do |val|
      self.instance_variable_set(("@"+name).to_sym, val)
    end
    
    define_method "#{name}?".to_sym do 
      return false unless self.instance_variable_get(("@"+name).to_sym)
      self.instance_variable_defined?(("@"+name).to_sym)
    end

  end
