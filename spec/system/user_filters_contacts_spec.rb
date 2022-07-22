require "system_helper"

RSpec.describe "User filters contacts" do
  scenario "defaults" do
    contact1 = create :contact
    contact2 = create :contact

    visit contacts_path

    expect(page).to display_contact(contact1)
    expect(page).to display_contact(contact2)
  end

  scenario "search", js: true do
    contact1 = create :contact, name: "Benito"
    contact2 = create :contact, name: "Juan"

    visit contacts_path

    fill_in "Search", with: contact1.name

    expect(page).to display_contact(contact1)
    expect(page).not_to display_contact(contact2)
  end

  def display_contact(contact)
    have_css "#contact_#{contact.id}"
  end
end
