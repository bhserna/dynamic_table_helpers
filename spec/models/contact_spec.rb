require 'rails_helper'

RSpec.describe Contact, ".search" do
  it "by name" do
    contact1 = create :contact, name: "toy"
    contact2 = create :contact, name: "food"

    result = described_class.search("toy")
    expect(result).to eq [contact1]
  end

  it "by phone_number" do
    contact1 = create :contact, phone_number: "1234"
    contact2 = create :contact, phone_number: "7890"

    result = described_class.search("1234")
    expect(result).to eq [contact1]
  end

  it "with no value" do
    contact1 = create :contact, name: "toy"
    contact2 = create :contact, name: "food"

    result = described_class.search("")
    expect(result).to match_array [contact1, contact2]
  end
end

