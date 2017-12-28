module ComradeRequestsHelper
  include ApplicationHelper

  def destroy_request(id)
    request = Comrade.find(id)

    requestee_id = request.requestee_id

    Comrade.with_advisory_lock(comrade_request) do
        request.delete
    end

    requestee_id
  end
end
