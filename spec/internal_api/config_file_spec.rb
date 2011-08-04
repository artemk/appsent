require 'spec_helper'

describe AppSent::ConfigFile do

  subject { described_class }

  before :each do
    @params = {
      'config_path' => '/path/to/config',
      'config_name' => 'config_name',
      'env'         => :environment,
      'type'        =>  Hash
    }
  end

  let(:fake_config_filename) { '/path/to/config/config_name.yml' }

  let(:params) do
    [
      @params['config_path'],
      @params['config_name'],
      @params['env'],
      @params['type']
    ]
  end

  context ".new" do

    %w(valid? options constantized error_message).each do |method|
      it { subject.new(*params).should respond_to(method)}
    end

    context "should send right variables to AppSent::ConfigValue" do

      let(:mock_config_value) { mock(AppSent::ConfigValue, :valid? => true) }

      context "using old API" do

        it "in a simple case" do
          AppSent::ConfigValue.should_receive(:new).once.with(
            'username',
            String,
            'user',
            nil,
            nil
          ).and_return(mock_config_value)

          AppSent.init(:path => '../fixtures', :env => 'test') do
            database do
              username :type => String
            end
          end
        end

      end

    end

  end

  context "#valid?" do

    context "should be true" do

      it "if config exists and environment presence(without type)(no values)" do
	YAML.should_receive(:load_file).once.with(fake_config_filename).and_return('environment' => {:a=>100500})
	subject.new(*params).should be_valid
      end

      it "if config exists and environment presence(with type specified)(no values)" do
	@params['type']=Array
	YAML.should_receive(:load_file).once.with(fake_config_filename).and_return(:environment => [1,2,3])
	subject.new(*params).should be_valid
      end

      it "if config exists and environment presence(with values)" do
	values_block = lambda {
	  value :type => String
	}
	YAML.should_receive(:load_file).once.with(fake_config_filename).and_return('environment' => {:value=>'100500'})
	subject.new(*params,&values_block).should be_valid
      end

    end

    context "should be false" do

      it "if config does not exists" do
	YAML.should_receive(:load_file).once.with(fake_config_filename).and_raise(Errno::ENOENT)
      end

      it "if environment does not presence in config" do
	YAML.should_receive(:load_file).once.with(fake_config_filename).and_return('other_environment' => {:a=>100500})
      end

      it "if wrong type" do
	@params['type'] = Array
	YAML.should_receive(:load_file).once.with(fake_config_filename).and_return(:environment => 123)
      end

      after :each do
	subject.new(*params).should_not be_valid
      end

    end

  end

end
