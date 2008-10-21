class BluesHeroController < ApplicationController
  layout 'blues_hero'

  def registration_payment
    @registration = BluesHeroRegistration.find(params[:id])
  end

  def register
    @registration = BluesHeroRegistration.find_or_initialize(params[:registration])
    return unless request.post?

    if @registration.save
      render :action => "registration_payment"
    end
  end
end