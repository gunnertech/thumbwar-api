class AlertsController < InheritedResources::Base
  protected
  
  def collection
    @current_user.alerts
  end
end