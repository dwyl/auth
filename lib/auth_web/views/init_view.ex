defmodule AuthWeb.InitView do
  use AuthWeb, :view

  def status_image(true_false) do
    base = "https://user-images.githubusercontent.com/194400/"
    t = "154710782-66ab7319-8307-4cd4-9e5a-497990b86c7a.png"
    f = "154711150-3fde9f49-eed5-4e1b-bd2a-f9f52afee65a.png"

    IO.inspect(true_false, label: "status_image/9 true_false")
    case true_false do
      true -> base <> t
      false -> base <> f
    end
  end
end
