100.times do
  Product.create(
    name: FFaker::Product.product_name,
    category: Product.categories.keys.sample,
    price: (100..500).to_a.sample
  )
end

100.times do
  Contact.create(
    name: FFaker::Name.name,
    phone_number: FFaker::PhoneNumber.phone_number
  )
end