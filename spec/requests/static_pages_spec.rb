require 'spec_helper'

describe "Static pages" do
  subject { page }
  describe "Login page" do
    before { visit login_path }
    it { should have_content('Login') } 
  end
end
