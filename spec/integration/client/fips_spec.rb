require "spec_helper"

describe "chef-client fips", :windows_only do
  PATH="HKLM\\System\\CurrentControlSet\\Control\\Lsa\\FipsAlgorithmPolicy"
  before do
    @registry = Chef::Win32::Registry.new
    @old_value = @registry.get_values(PATH)[0]
    @registry.set_value(PATH, @old_value.merge({data: 1}))
  end
  after do
    @registry.set_value(PATH, @old_value)
  end

  it "Should not error on enabling fips_mode" do
    expect { OpenSSL.fips_mode = true }.not_to raise_error
  end
end
