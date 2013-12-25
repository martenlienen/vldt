describe Vldt::DSL do
  v = Class.new do
    extend Vldt::DSL

    def self.user
      join(
        validate(:name, chain(string, length_greater_than(6))),
        validate(:email, string),
        validate(:age, join(whole_number, positive)))
    end

    def self.ingredient
      join(
        validate(:name, chain(string, one_of("Rice", "Tomato", "Potato"))),
        validate(:amount, positive),
        validate(:unit, chain(string, length_between(3, 10))))
    end

    def self.recipe
      join(
        validate(:user, user),
        validate(:title, string),
        validate(:ingredients, join(
          array,
          length_greater_than(2),
          each(ingredient))))
    end
  end

  it "should validate a user" do
    expect(v.user.validate({ name: "cqql#", email: "1@3", age: -3.3 })).to eq({
      [:name] => [[:length_greater_than, { min: 6 }]],
      [:age] => [[:whole_number, {}], [:positive, {}]]
    })
  end

  it "should validate a recipe" do
    recipe = {
      user: {
        name: "username",
        age: 5
      },
      title: 5,
      ingredients: [
        {
          name: "Rice",
          amount: 20
        },
        {
          name: "Nail",
          amount: 10,
          unit: "pieces"
        }
      ]
    }

    expect(v.recipe.validate(recipe)).to eq({
      [:user, :email] => [[:present, {}]],
      [:title] => [[:string, {}]],
      [:ingredients] => [[:length_greater_than, { min: 2 }]],
      [:ingredients, 0, :unit] => [[:present, {}]],
      [:ingredients, 1, :name] => [[:one_of, { values: ["Rice", "Tomato", "Potato"] }]]
    })
  end
end
