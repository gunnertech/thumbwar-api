class AlertsController < InheritedResources::Base
  protected
  

  def collection
    # return @alerts if @alerts

  	@alerts = end_of_association_chain.where{ user_id == my{@current_user.id} }

  	@alerts = @alerts.where{ read == my{params[:read]} } if params[:read].present?
    
    @result_count = @alerts.count
    
    @last_seen_id = params[:last_seen_id]
    
    @alerts.where{ id > my{@last_seen_id} } if @last_seen_id.present?
    

  	@alerts.reorder{ id.desc }.limit(20)
  end
end
