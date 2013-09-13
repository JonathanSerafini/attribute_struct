require 'minitest/autorun'

describe AttributeStruct do
  describe 'Camel usage' do
    before do
      AttributeStruct.camel_keys = true
      @struct = AttributeStruct.new do
        value_one true
        value_two do
          nesting true
        end
      end
    end
    after do
      AttributeStruct.camel_keys = false
    end

    it 'should camel case keys when dumped' do
      @struct._dump.keys.must_include 'ValueOne'
      @struct._dump.keys.must_include 'ValueTwo'
    end

    it 'should allow explicit disable on keys' do
      @struct._set('not_camel'._no_hump, true)
      @struct._dump.keys.must_include 'not_camel'
    end

    it 'should allow implicit disable on nested structs' do
      @struct.disable_camel do |struct|
        struct._camel_keys_set(:auto_disable)
        not_camel true
        not_camel_nest do
          no_camel_here true
        end
      end
      dump = @struct._dump
      dump['DisableCamel'][:not_camel].must_equal true
      dump['DisableCamel'][:not_camel_nest][:no_camel_here].must_equal true
      dump['ValueOne'].must_equal true
      dump['ValueTwo']['Nesting'].must_equal true
    end
  end
  describe 'Camel enabled imports' do
    before do
      @struct = AttributeStruct.new
      @struct._camel_keys_set = :auto_discovery
      @hash = {
        'Fubar' => {
          'FooBar' => true,
          'FeeBar' => {
            'FauxBar' => 'done'
          }
        }
      }
    end

    it 'should allow snake case access after import' do
      @struct._load(@hash)
      @struct.fubar.fee_bar.faux_bar.must_equal 'done'
    end
  end
end
