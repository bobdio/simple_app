Product.delete_all

20.times do |n|
  Product.create(
    {
      name: "Test product #{n}",
      price: n,
      status: (n % 2 == 0),
      description: "test product description #{n}"
    }
  )
end