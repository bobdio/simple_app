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

Customer.delete_all
Customer.create(
  {
    firstname: "Tester",
    lastname: "Customer",
    email: "test@email.com",
    password: "1234567",
    password_confirmation: "1234567"
  }
)