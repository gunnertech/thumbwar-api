class AlertsController < InheritedResources::Base
  protected
  

  def collection
    # return @alerts if @alerts

  	@alerts = end_of_association_chain.where{ user_id == my{@current_user.id} }

  	@alerts = @alerts.where{ read == my{params[:read]} } if params[:read].present?

  	@alerts.reorder{ id.desc }
  end
end
