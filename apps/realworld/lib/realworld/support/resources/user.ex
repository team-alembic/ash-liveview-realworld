defmodule Realworld.Support.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication],
    authorizers: [Ash.Policy.Authorizer]

  alias Realworld.Support.Token

  postgres do
    table "users"
    repo Realworld.Repo
  end

  actions do
    create :register_with_password do
      argument(:password, :string, allow_nil?: false, sensitive?: true)
      accept [:username, :email]
      allow_nil_input [:hashed_password]
      change AshAuthentication.Strategy.Password.HashPasswordChange
      change AshAuthentication.GenerateTokenChange
    end

    update :update_profile do
      accept [:email, :bio, :image]
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :username, :string, allow_nil?: false
    attribute :email, :string, allow_nil?: false
    attribute :hashed_password, :string, allow_nil?: false, sensitive?: true
    attribute :bio, :string
    attribute :image, :string
  end

  identities do
    identity :unique_email, [:email]
    identity :unique_username, [:username]
  end

  validations do
    validate present(:email), on: :create
    validate present(:username), on: :create
  end

  authentication do
    api Realworld.Support

    strategies do
      password do
        identity_field(:email)
        hashed_password_field(:hashed_password)
        confirmation_required?(false)
      end
    end

    tokens do
      enabled?(true)
      store_all_tokens?(true)
      token_resource(Token)
      signing_algorithm("HS256")
      signing_secret(&get_config/2)
      require_token_presence_for_authentication?(true)
    end

    policies do
      policy action_type(:read) do
        authorize_if AshAuthentication.Checks.AshAuthenticationInteraction
      end

      policy action_type(:create) do
        authorize_if AshAuthentication.Checks.AshAuthenticationInteraction
      end

      # policy always() do
      #   authorize_if always()
      # end
    end
  end

  def get_config(path, _resource) do
    value =
      :ash_authentication
      |> Application.get_all_env()
      |> get_in(path)

    {:ok, value}
  end
end
