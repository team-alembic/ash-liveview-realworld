defmodule UserControllerTest do
  use Realworld.RepoCase
  use Plug.Test

  alias Realworld.Controller.UserController
  alias Realworld.Support.User

  @opts UserController.init([])

  test "successful registration" do
    user = %{
      username: "User",
      email: "email@email.com",
      password: "password"
    }

    params =
      %{
        user: user
      }
      |> Jason.encode!()

    request =
      conn(:post, "", params)
      |> put_req_header("content-type", "application/json")

    result = UserController.call(request, @opts)

    assert result.state == :sent
    assert result.status == 200

    response = result.resp_body |> Jason.decode!(keys: :atoms)

    refute(is_nil(response.user.token))

    email = user.email
    username = user.username

    assert match?(
             %{
               user: %{email: ^email, username: ^username, bio: nil, image: nil, token: _}
             },
             response
           )
  end

  test "fail without params" do
    request =
      conn(:post, "")
      |> put_req_header("content-type", "application/json")

    result = UserController.call(request, @opts)

    assert result.state == :sent
    assert result.status == 422

    response = %{
      errors: %{user: ["can't be empty"]}
    }

    assert result.resp_body == response |> Jason.encode!()
  end

  test "fail with invalid params" do
    user = %{
      email: "",
      password: "",
      username: ""
    }

    params =
      %{
        user: user
      }
      |> Jason.encode!()

    request =
      conn(:post, "", params)
      |> put_req_header("content-type", "application/json")

    result = UserController.call(request, @opts)

    assert result.state == :sent
    assert result.status == 422

    response = %{
      errors: %{
        email: ["must be present"],
        password: ["must be present"],
        username: ["must be present"]
      }
    }

    assert result.resp_body == response |> Jason.encode!()
  end

  test "fail with duplicated email" do
    user = %{
      username: "user",
      email: "email@email.com",
      password: "password"
    }

    {:ok, strategy} = AshAuthentication.Info.strategy(User, :password)
    {:ok, _resource} = AshAuthentication.Strategy.action(strategy, :register, user)

    params =
      %{
        user: user
      }
      |> Jason.encode!()

    request =
      conn(:post, "", params)
      |> put_req_header("content-type", "application/json")

    result = UserController.call(request, @opts)

    response = %{
      errors: %{
        email: ["has already been taken"]
      }
    }

    assert result.state == :sent
    assert result.status == 422
    assert result.resp_body == response |> Jason.encode!()
  end

  test "fail with duplicated username" do
    user = %{
      username: "user",
      email: "email@email.com",
      password: "password"
    }

    {:ok, strategy} = AshAuthentication.Info.strategy(User, :password)
    {:ok, _resource} = AshAuthentication.Strategy.action(strategy, :register, user)

    params =
      %{
        user: %{user | email: "email@email_2.com"}
      }
      |> Jason.encode!()

    request =
      conn(:post, "", params)
      |> put_req_header("content-type", "application/json")

    result = UserController.call(request, @opts)

    response = %{
      errors: %{
        username: ["has already been taken"]
      }
    }

    assert result.state == :sent
    assert result.status == 422
    assert result.resp_body == response |> Jason.encode!()
  end

  test "successful login" do
    user = %{
      username: "User",
      email: "email@email.com",
      password: "password"
    }

    {:ok, strategy} = AshAuthentication.Info.strategy(User, :password)

    {:ok, _resource} = AshAuthentication.Strategy.action(strategy, :register, user)

    params =
      %{
        user: %{email: user.email, password: user.password}
      }
      |> Jason.encode!()

    conn =
      conn(:post, "/login", params)
      |> put_req_header("content-type", "application/json")

    conn = UserController.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200

    response = conn.resp_body |> Jason.decode!(keys: :atoms)

    refute(is_nil(response.user.token))

    email = user.email
    username = user.username

    assert match?(
             %{
               user: %{email: ^email, username: ^username, bio: nil, image: nil, token: _}
             },
             response
           )
  end

  test "fail login" do
    params =
      %{
        user: %{
          email: "email@email.com",
          password: "password"
        }
      }
      |> Jason.encode!()

    request =
      conn(:post, "/login", params)
      |> put_req_header("content-type", "application/json")

    result = UserController.call(request, @opts)

    assert result.state == :sent
    assert result.status == 422

    response_expected = %{
      errors: %{
        email: ["is invalid"],
        password: ["is invalid"]
      }
    }

    response = result.resp_body |> Jason.decode!(keys: :atoms)

    assert response === response_expected
  end
end
