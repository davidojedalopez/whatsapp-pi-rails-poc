module Api
  module V1
    class AgentMessagesController < ApplicationController
      def create
        phone = params.require(:from)
        text = params.require(:text)
        context = CustomerContext.for(phone:, message: text)
        agent_result = PiAgent::Client.new.reply(message: text, context:)

        render json: {
          reply: agent_result.text,
          agent_mode: agent_result.mode,
          context: context
        }
      end
    end
  end
end
