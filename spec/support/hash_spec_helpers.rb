RSpec::Matchers.define :hash_eql do |expected|
  match do |actual|
    expected.with_indifferent_access == actual.with_indifferent_access    
  end
end