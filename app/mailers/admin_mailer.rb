class AdminMailer < ActionMailer::Base
  default from: "svs@rbus.in", to: "svs@svs.io"

  def notify(trip)
    @trip = trip
    mail(subject: "New trip by #{@trip.user.email}")
  end

end
