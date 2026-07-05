class HomeController < ApplicationController
  def show
    render json: {
      name: "WhatsApp Pi Rails POC",
      status: "ok",
      health: rails_health_check_url,
      test_endpoint: api_v1_agent_messages_url
    }
  end
end
