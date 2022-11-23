describe "chef-client fips" do
  def enable_fips_if_supported
    if ENV["OMNIBUS_FIPS_MODE"].to_s.downcase == "true"
      OpenSSL.fips_mode = true
      sleep 0.1
      OpenSSL.fips_mode = false
    end
  end
  it "Should not error on enabling fips_mode" do
    expect { enable_fips_if_supported }.not_to raise_error
  end
end
