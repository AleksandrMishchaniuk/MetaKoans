
  def attribute(arg, &block)
    
    name = arg

    if arg.class == Hash

      arg.each do |key, val|
        name = key
        define_method :initialize do
          self.instance_variable_set(("@"+name).to_sym, val)
        end
      end

    end

    if block
      define_method :initialize do
        val = self.instance_eval &block
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
