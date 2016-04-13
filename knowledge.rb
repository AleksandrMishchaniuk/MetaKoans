
  def attribute(arg, &block)
    
    name = arg
    # if arg.class == Hash
    #   arg.each { |key, val| name = key }
    # end

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

    # puts class_variables.to_s

    define_method :initialize do
      # self.class.class_variables.each do |var|
      #   val = self.class.class_variable_get(var)

      #   puts self.class.to_s+' => '+var.to_s+" = "+val.to_s #-----------
        
      #   var = var.to_s.delete('@')
      #   val = self.instance_eval &val if val.class == Proc
      #   self.instance_variable_set(("@"+var).to_sym, val)
      # end
      self.class.class_variable_get(:@@inits).each do |name, val|
        val = self.instance_eval &val if val.class == Proc
        self.instance_variable_set(("@#{name}").to_sym, val)
      end
    end

    define_method name.to_sym do 
      val = self.instance_variable_get(("@"+name).to_sym)
      # return self.instance_eval &val if val.class == Proc
      val
    end

    define_method "#{name}=".to_sym do |val|
      self.instance_variable_set(("@"+name).to_sym, val)
    end
    
    define_method "#{name}?".to_sym do 
      return false unless self.instance_variable_get(("@"+name).to_sym)
      self.instance_variable_defined?(("@"+name).to_sym)
    end

    define_singleton_method name.to_sym do 
      self.class_variable_get(("@@"+name).to_sym)
    end

    define_singleton_method "#{name}=".to_sym do |val|
      self.class_variable_set(("@@"+name).to_sym, val)
    end
    
    define_singleton_method "#{name}?".to_sym do 
      return false unless self.class_variable_get(("@@"+name).to_sym)
      self.class_variable_defined?(("@@"+name).to_sym)
    end

    def self.inherited(subclass)
      self.class_variables.each do |var|
        val = self.class_variable_get(var)
        # puts self.to_s+' => '+var.to_s+" = "+val.to_s        #-----------
        subclass.class_variable_set(var, val)
        # puts subclass.to_s+' => '+var.to_s+" = "+subclass.class_variable_get(var).to_s #-----------
      end
    end

  end
