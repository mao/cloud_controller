require 'spec_helper'

describe ServiceBinding do
  it "requires a name" do
    bdg = ServiceBinding.new
    bdg.should have_at_least(1).errors_on(:name)
  end

  it "serializes credentials and binding_options" do
    opts = ["foo", "bar"]
    cred = {"baz" => "jaz"}
    bdg = ServiceBinding.new(:name => 'foo', :binding_options => opts, :credentials => cred)
    bdg.save
    bdg.should be_valid

    bdg = ServiceBinding.find(bdg.id)
    bdg.should_not be_nil

    (bdg.binding_options == opts).should be_true
    (bdg.credentials == cred).should be_true
  end

  it "is unique for a given (app, config)" do
    u = User.new(:email => 'foo@bar.com')
    u.set_and_encrypt_password('foobar')
    u.save
    u.should be_valid

    a = App.new(
      :owner     => u,
      :name      => 'foobar',
      :framework => 'sinatra',
      :runtime   => 'ruby18')
    a.save
    a.should be_valid

    cfg = ServiceConfig.new(:name => 'foo', :alias => 'bar')
    cfg.save
    cfg.should be_valid

    bdg = ServiceBinding.new(
      :name => 'foo',
      :app  => a,
      :service_config => cfg
    )
    bdg.save
    bdg.should be_valid

    bdg = ServiceBinding.new(
      :name => 'foo',
      :app  => a,
      :service_config => cfg
    )
    bdg.save
    bdg.should_not be_valid
  end

  describe '#for_staging' do
    it "should show correct label for multi versions service" do
      u = User.new(:email => 'foo@bar.com')
      u.set_and_encrypt_password('foobar')
      u.save
      u.should be_valid

      a = App.new(
        :owner     => u,
        :name      => 'foobar',
        :framework => 'sinatra',
        :runtime   => 'ruby18'
      )
      a.save
      a.should be_valid

      svc = Service.new(:label => "foo-1.0", :url=>"http://example.com", :token => 'bar')
      svc.save
      svc.should be_valid

      cfg = ServiceConfig.new(:name => 'foo', :alias => 'bar', :service => svc,
                          :data => {"version" => "2.0"})
      cfg.save
      cfg.should be_valid

      binding = ServiceBinding.new(
        :name => 'foo',
        :app  => a,
        :service_config => cfg
      )
      binding.save
      binding.should be_valid

      binding.for_staging[:label].should == "foo-2.0"
    end
  end
end
