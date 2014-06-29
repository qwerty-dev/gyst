get "/circle/create" do
    haml :create_circle
end

post "/circle/create" do
    @circle = Circle.new
    @circle.attributes = params
    @circle.creator_id = logged_in_user.id
    logged_in_user.circles << @circle
    if @circle.save
        session[:message] = 'Creation of the CIRCLE was successfull, my lord.'
        redirect "/user/#{logged_in_user.id}"
    else
        session[:message] = 'Crasdasdasdsa CIRCLE'
        redirect "/user/#{logged_in_user.id}"
    end
end

get "/circle/:circle_id" do
    @circle = logged_in_user.circles.find_by_id params[:circle_id]
    @user = logged_in_user
    haml :detail_circle
end

get "/circle/:circle_id/edit" do
    @circle = logged_in_user.circles.find_by_id "#{params[:circle_id]}"
    haml :edit_circle
end

post  "/circle/:circle_id/edit" do
    @circle = logged_in_user.circles.find_by_id "#{params[:circle_id]}"
    @circle[:name] = params[:name]
    if @circle.save
       session[:message] = 'Your circle was successfully edited.'
       redirect "/user/#{logged_in_user.id}"
    else
       session[:message] = "WRONG"
    end
end

get "/circle/:circle_id/delete" do
    #validation
    logged_in_user.circles.find(params[:circle_id]).destroy
    session[:message]  = "Circle has been cultivated successfully."
    redirect "/user/#{logged_in_user.id}"
end

post "/circle/add_to_circle" do
    user_to_add  = User.find_by_username params[:username]
    circle = logged_in_user.circles.find_by_name params[:circle]
    if !user_to_add.nil? && !circle.nil?
        user_to_add.alerts << Alert.create(
            message: "#{logged_in_user.name.capitalize} would like to add you to the circle '#{circle.name.capitalize}'",
            creator_id: logged_in_user.id,
            add_to_circle_id: circle.id)
            # circle.users << user_to_add
            show_message Alert.last.attributes
    end
    redirect "/user/#{logged_in_user.id}"
end

get "/circle/:circle_id/remove/:id" do
    @circle = Circle.find_by_id params[:circle_id]
    haml :confirm_remove_from_circle
end

post "/circle/:circle_id/remove/:id" do
    @user = User.find_by_id(params[:id])
    @circle = Circle.find_by_id params[:circle_id]
    @circle.users.delete(@user)
    redirect "/user/#{logged_in_user.id}"
end

