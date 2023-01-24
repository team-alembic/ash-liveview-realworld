defmodule ProfileControllerTest do
  use Realworld.RepoCase
  use Plug.Test

  alias Realworld.Controller.ProfileController
  alias Realworld.Support.User

  @opts ProfileController.init([])

  test "successful get profile" do
    user = %{
      username: "user",
      email: "email@email.com",
      password: "password"
    }

    {:ok, strategy} = AshAuthentication.Info.strategy(User, :password)

    {:ok, %{__metadata__: %{token: token}}} =
      AshAuthentication.Strategy.action(strategy, :register, user)

    request =
      conn(:get, "")
      |> put_req_header("authorization", "Token #{token}")
      |> put_req_header("content-type", "application/json")

    result = ProfileController.call(request, @opts)

    assert result.state == :sent
    assert result.status == 200

    response_expected = %{
      user: %{
        email: user.email,
        username: user.username,
        bio: nil,
        image: nil
      }
    }

    response = result.resp_body |> Jason.decode!(keys: :atoms)

    assert(response === response_expected)
  end

  test "fail get profile without token" do
    request =
      conn(:get, "")
      |> put_req_header("content-type", "application/json")

    result = ProfileController.call(request, @opts)

    assert result.state == :sent
    assert result.status == 401

    response_expected = %{
      errors: %{
        authorization: ["is invalid"]
      }
    }

    response = result.resp_body |> Jason.decode!(keys: :atoms)

    assert(response === response_expected)
  end

  test "fail get profile with invalid token" do
    token = 1..100 |> Enum.map(fn _ -> <<Enum.random('0123456789abcdef')>> end) |> Enum.join()

    request =
      conn(:get, "")
      |> put_req_header("authorization", "Token #{token}")
      |> put_req_header("content-type", "application/json")

    result = ProfileController.call(request, @opts)

    assert result.state == :sent
    assert result.status == 401

    response_expected = %{
      errors: %{
        authorization: ["is invalid"]
      }
    }

    response =
      result.resp_body
      |> Jason.decode!(keys: :atoms)

    assert(response === response_expected)
  end

  test "successful profile updated" do
    user = %{
      username: "user",
      email: "email@email.com",
      password: "password"
    }

    {:ok, strategy} = AshAuthentication.Info.strategy(User, :password)

    {:ok, %{__metadata__: %{token: token}}} =
      AshAuthentication.Strategy.action(strategy, :register, user)

    new_email = "email2@email.com"

    params =
      %{
        user: %{
          email: new_email
        }
      }
      |> Jason.encode!()

    request =
      conn(:put, "", params)
      |> put_req_header("authorization", "Token #{token}")
      |> put_req_header("content-type", "application/json")

    result = ProfileController.call(request, @opts)

    assert result.state == :sent
    assert result.status == 200

    response = result.resp_body |> Jason.decode!(keys: :atoms)

    assert match?(
             %{
               user: %{email: ^new_email, username: _, bio: _, image: _}
             },
             response
           )
  end

  test "fail to update profile" do
    user = %{
      username: "user",
      email: "email@email.com",
      password: "password"
    }

    {:ok, strategy} = AshAuthentication.Info.strategy(User, :password)

    {:ok, %{__metadata__: %{token: token}}} =
      AshAuthentication.Strategy.action(strategy, :register, user)

    params =
      %{
        user: %{
          email: ""
        }
      }
      |> Jason.encode!()

    request =
      conn(:put, "", params)
      |> put_req_header("authorization", "Token #{token}")
      |> put_req_header("content-type", "application/json")

    result = ProfileController.call(request, @opts)

    assert result.state == :sent
    assert result.status == 422

    resp_body = result.resp_body |> Jason.decode!(keys: :atoms)

    expected = %{
      errors: %{
        email: ["must be present"]
      }
    }

    assert resp_body === expected
  end
end
