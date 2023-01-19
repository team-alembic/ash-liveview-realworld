defmodule UserControllerTest do
  use Realworld.RepoCase
  use Plug.Test

  alias Realworld.Controller.UserController

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

    conn =
      conn(:post, "", params)
      |> put_req_header("content-type", "application/json")

    conn = UserController.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200

    response = %{
      user: %{bio: nil, email: user.email, image: nil, token: nil, username: user.username}
    }

    assert conn.resp_body == response |> Jason.encode!()
  end

  test "fail without params" do
    conn =
      conn(:post, "")
      |> put_req_header("content-type", "application/json")

    conn = UserController.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 422

    response = %{
      errors: %{user: ["can't be empty"]}
    }

    assert conn.resp_body == response |> Jason.encode!()
  end

  test "fail with invalid params" do
    user = %{
      email: "",
      password: ""
    }

    params =
      %{
        user: user
      }
      |> Jason.encode!()

    conn =
      conn(:post, "", params)
      |> put_req_header("content-type", "application/json")

    conn = UserController.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 422

    response = %{
      errors: %{
        email: ["must be present"],
        password: ["must be present"]
      }
    }

    assert conn.resp_body == response |> Jason.encode!()
  end

  test "fail with duplicated email" do
    user = %{
      username: "user",
      email: "email@email.com",
      password: "password"
    }

    params =
      %{
        user: user
      }
      |> Jason.encode!()

    conn =
      conn(:post, "", params)
      |> put_req_header("content-type", "application/json")

    conn = UserController.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200

    conn2 =
      conn(:post, "", params)
      |> put_req_header("content-type", "application/json")

    conn2 = UserController.call(conn2, @opts)

    response = %{
      errors: %{
        email: ["has already been taken"]
      }
    }

    assert conn2.state == :sent
    assert conn2.status == 422
    assert conn2.resp_body == response |> Jason.encode!()
  end

  test "fail with duplicated username" do
    user = %{
      username: "user",
      email: "email@email.com",
      password: "password"
    }

    params =
      %{
        user: user
      }
      |> Jason.encode!()

    conn =
      conn(:post, "", params)
      |> put_req_header("content-type", "application/json")

    conn = UserController.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200

    params2 =
      %{
        user: %{user | email: "email@email_2.com"}
      }
      |> Jason.encode!()

    conn2 =
      conn(:post, "", params2)
      |> put_req_header("content-type", "application/json")

    conn2 = UserController.call(conn2, @opts)

    response = %{
      errors: %{
        username: ["has already been taken"]
      }
    }

    assert conn2.state == :sent
    assert conn2.status == 422
    assert conn2.resp_body == response |> Jason.encode!()
  end
end
