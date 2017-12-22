module ComradeRequestsHelper

  def destroy_request(id)
    request = Comrade.find(id)

    requestee_id = request.requestee_id

    request.delete

    requestee_id
  end
end
