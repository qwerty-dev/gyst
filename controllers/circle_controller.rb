get "/circles/new" do
    haml :create_circle
end

post "/circles/new" do #json
    content_type :json

    circle = Circle.new
    circle.name = params[:name]
    circle.creator_id = logged_in_user.id
    if circle.save
        logged_in_user.circles << circle
        count = {count: circle.users.count}
        [circle,count].to_json
    else
        status 500
    end
end

get "/circle/:circle_id" do
    @circle = logged_in_user.circles.find_by_id params[:circle_id]
    @user = logged_in_user
    haml :detail_circle
end

get "/circle/:circle_id/edit" do
    @circle = logged_in_user.circles.find_by_id params[:circle_id]
    haml :edit_circle
end

post  "/circle/:circle_id/edit" do
    circle = logged_in_user.circles.find_by_id params[:circle_id]
    circle[:name] = params[:name]
    if circle.save
        show_message 'Your circle was successfully edited.'
        redirect user_page
    else
        show_error "WRONG"
    end
end

get "/circle/:circle_id/delete" do
    #validation
    circle = logged_in_user.circles.find_by_id params[:circle_id]
    if !circle.nil?
        cirlce = Circle.find_by_id params[:circle_id]
        alert = Alert.find_by_add_to_circle_id cirlce.id
        if !alert.nil? && alert.add_to_circle_id == circle.id
            alert.destroy
        end
        circle.tasks.destroy
        circle.destroy
        show_message "Circle has been deleted."
    else
        show_error "Oops.. Something went wrong"
    end
    redirect user_page
end

post "/circle/add_to_circle" do
    user_to_add  = User.find_by_username params[:username]
    circle = logged_in_user.circles.find_by_name params[:circle]
    if user_to_add.nil?
        show_error "There is no user with the username #{params[:username]} '"
        redirect user_page
    end
    if logged_in_user.id == user_to_add.id
        show_error "Sorry, adding yourself is somewhat redundant"
        redirect user_page
    end
    if !user_to_add.nil? && !circle.nil? # legit fields
        alert = user_to_add.alerts.find_by_user_id user_to_add.id
        if !alert.nil? && alert.add_to_circle_id == circle.id 
             show_error "Sorry, this user has already been invited."
        elsif !(user_to_add.circles.find_by_id circle.id).nil?
             show_error "Sorry, this user is already in the circle '#{circle.name}'."
        else
            user_to_add.alerts << Alert.create(
            message: "#{logged_in_user.name.capitalize} would like to add you to the circle '#{circle.name.capitalize}'",
            creator_id: logged_in_user.id,
            alert_type: "request",
            add_to_circle_id: circle.id)
            show_message "User has been notified, please wait for the approval."
        end
    else
        show_message "Oops, something went wrong."
    end
    redirect user_page
end

get "/circle/:circle_id/remove/:id" do
    @circle = logged_in_user.circles.find_by_id params[:circle_id]
    @user =User.find_by_id params[:id]
    if !@circle.nil?
        if @circle.creator_id == @user.id #ownership check too
            show_message "This will delete the circle since you are it's owner." #ALERT
            haml :confirm_remove_from_circle
        else
            haml :confirm_remove_from_circle
        end
    else
        show_message "Missing circle to add remove from"
        redirect user_page
    end
end

post "/circle/:circle_id/remove/:id" do
    user = User.find_by_id params[:id]
    circle = Circle.find_by_id params[:circle_id]
    if circle.creator_id == user.id
        circle.users.delete user
        circle.destroy
    else 
        circle.users.delete user
    end
        redirect user_page
end

