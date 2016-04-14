
  def attribute(arg, &block)
    
    name = arg

    class_variable_set(:@@inits, {}) unless class_variable_defined?(:@@inits)

    if arg.class == Hash
      arg.each do |key, val|
        name = key
        class_variable_set("@@#{name}".to_sym, val)
        inits = class_variable_get(:@@inits)
        inits[name] = val
        class_variable_set(:@@inits, inits)
      end
    end

    if block
      class_variable_set("@@#{name}".to_sym, block)
      inits = class_variable_get(:@@inits)
      inits[name] = block
      class_variable_set(:@@inits, inits)
    end

    define_method :initialize do
      self.class.class_variable_get(:@@inits).each do |name, val|
        val = self.instance_eval &val if val.class == Proc
        self.instance_variable_set(("@#{name}").to_sym, val)
      end
    end

    define_method name.to_sym do 
      if self.class == Class
        self.class_variable_get(("@@"+name).to_sym)
      else
        self.instance_variable_get(("@"+name).to_sym)
      end
    end

    define_method "#{name}=".to_sym do |val|
      if self.class == Class
        self.class_variable_set(("@@"+name).to_sym, val)
      else
        self.instance_variable_set(("@"+name).to_sym, val)
      end
    end
    
    define_method "#{name}?".to_sym do
      if self.class == Class
        return false unless self.class_variable_defined?(("@@"+name).to_sym)
        return false unless self.class_variable_get(("@@"+name).to_sym)
        true
      else
        return false unless self.instance_variable_defined?(("@"+name).to_sym)
        return false unless self.instance_variable_get(("@"+name).to_sym)
        true
      end
    end

    define_singleton_method :inherited do |subclass|
      # subclass.remove_class_variable(:@@inits)
      self.class_variables.each do |var|
        val = self.class_variable_get(var)
        subclass.class_variable_set(var, val)
      end
    end


    define_singleton_method :included do |subclass|
      self.class_variables.each do |var|
        val = self.class_variable_get(var)
        subclass.class_variable_set(var, val)
      end
    end

  end
