module ComradeRequestsHelper
  include ApplicationHelper

  def destroy_request(id)
    request = Comrade.find(id)

    Comrade.with_advisory_lock(comrade_request) do
        request.delete
    end
  end
end
