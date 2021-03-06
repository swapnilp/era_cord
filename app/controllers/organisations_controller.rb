class OrganisationsController < ApplicationController
  load_and_authorize_resource param_method: :my_sanitizer, except: [:new_user, :get_last_attendances, :add_attendances]
  #before_action :authenticate_user!, only: [:manage_organisation, :manage_roles, :update_roles, :manage_courses
  #                                          :add_cources, :add_remaining_cources, :new_user,:disable_users, :enable_users 
  #                                          :remaining_cources, :add_remaining_cources, :delete_users, 
  #                                          :edit_password, :update_password, :launch_sub_organisation]
  before_action :authenticate_user!, except: [:new, :create, :regenerate_organisation_code, :get_last_attendances, :add_attendances]
  skip_before_filter :authenticate_with_token!, only: [:get_last_attendances, :add_attendances]
  
  before_filter :authenticate_org_with_token!, only: [:get_last_attendances, :add_attendances]
  before_action :authenticate_organisation!, only: [:get_last_attendances, :add_attendances]

  before_action :active_standards!, only: [:organisation_classes]


  def show
    if current_user.has_role? :organisation
      render json: {success: true, organisation: @organisation.as_json, is_root: @organisation.root?}
    else
      render json: {success: false}
    end
  end


  def edit
    if current_user.has_role? :organisation
      render json: {success: true, organisation: @organisation.as_json.except(:is_send_message), is_root: @organisation.root?}
    else
      render json: {success: false}
    end
  end

  def update
    if current_user.has_role? :organisation
      if current_user.valid_password?(update_organisation_params["password"])
        change_account_sms = false
        if update_organisation_params["account_sms"] != @organisation.account_sms && @organisation.root?
          change_account_sms = true
        end
        @organisation.update({mobile: update_organisation_params["mobile"], short_name: update_organisation_params["short_name"], account_sms: update_organisation_params["account_sms"]})
        if @organisation.root?
          @organisation.update({enable_service_tax: update_organisation_params["enable_service_tax"], pan_number: update_organisation_params["pan_number"], tan_number: update_organisation_params["tan_number"], service_tax: update_organisation_params["service_tax"]})
        end
        
        if change_account_sms
          Delayed::Job.enqueue OrganisationRegistationSms.new(@organisation.account_sms_message)
        end
        
        render json: {success: true}
      else
        render json: {success: false, message: "Enter valid password"}
      end

    else
      render json: {success: false, message: "Unauthorised"}
    end
  end


  def organisation_cources
    organisation_standards = @organisation.organisation_standards.includes(:standard, :assigned_organisation)
    render json: {success: true, body: ActiveModel::ArraySerializer.new(organisation_standards, each_serializer: OrganisationCoursesSerializer, scope: {is_root: @organisation.root?}).as_json, is_root:  @organisation.root?}
  end

  def organisation_classes
    organisation_classes = @organisation.jkci_classes.where(standard_id: @active_standards).order("id desc")
    other_organisation_classes = JkciClass.includes(:organisation).where(organisation_id: @organisation.descendant_ids, standard_id: @active_standards).order("standard_id asc")

    render json: {success: true, classes: organisation_classes.map(&:organisation_class_json), 
      other_classes: other_organisation_classes.map(&:organisation_class_json)}
  end

  def remaining_cources
    standards = Standard.select([:id, :name, :stream]).where("id not in (?)", ([0] + @organisation.standards.map(&:id)))
    if @organisation.root?
      render json: {body: ActiveModel::ArraySerializer.new(standards, each_serializer: StandardSerializer).as_json}
    else
      render json: {body: [].as_json}
    end
  end

  def remaining_standard_organisations
    #standard = Standard.where(id: params[:standard_id])
    org_standard_id = @organisation.descendants.joins(:organisation_standards).where("organisation_standards.standard_id = ? && organisation_standards.is_assigned_to_other = ?", params[:standard_id], false).map(&:id)
    if @organisation.root? || @organisation.subtree_ids.include?(org_standard_id[0])
      ids = [0] << org_standard_id
      organisations = @organisation.descendants.where("id not in (?)", ids.flatten)
      render json: {success: true, body: ActiveModel::ArraySerializer.new(organisations, each_serializer: SubOrganisationSerializer).as_json}
    else
      render json: {success: false, message: "You Don't have permission to handle this standard"}
    end
  end

  def switch_organisation_standard
    if params[:switch_organisation_standard] && params[:switch_organisation_standard][:role] == 'Handler'
      success = @organisation.switch_organisation(params[:switch_organisation_standard][:new_organisation], params[:switch_organisation_standard][:standard_id])
      render json: {success: success, message: "Something went wrong"}
    elsif params[:switch_organisation_standard] && params[:switch_organisation_standard][:role] == 'Observer'
      assigned_org_id = @organisation.organisation_standards.where(standard_id: params[:switch_organisation_standard][:standard_id]).first.try(:assigned_organisation_id) || @organisation.id
      new_org_standard = OrganisationStandard.find_or_initialize_by({standard_id: params[:switch_organisation_standard][:standard_id], organisation_id: params[:switch_organisation_standard][:new_organisation]})
      new_org_standard.is_assigned_to_other =  true
      new_org_standard.assigned_organisation_id =  assigned_org_id
      new_org_standard.save
      render json: {success: true}
    else
      render json: {success: false, message: "Invalide date"}
    end
    #success = @organisation.switch_organisation(params[:old_organisation_id], params[:new_organisation_id], params[:standard_id])
    #respond_to do |format|
    #  format.json {render json: {success: success}}
    #end
  end
  
  def organisation_standards
    organisation_standards = @organisation.standards.includes(:organisation_standards).where("organisation_standards.is_active = ?", true)
    render json: {success: true, organisation_standards: organisation_standards.map{|org_standard| org_standard.organisation_json({}, @organisation)}}
  end

  def sub_organisations_list
    sub_organisations = @organisation.descendants
    render json: sub_organisations, each_serializer: SubOrganisationSerializer
  end

  def add_standards
    standards = Standard.select([:id, :name, :stream]).where(id: params[:ids])
    if @organisation && @organisation.root?
      @organisation.add_standards(standards)#standards << standards
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def get_clerks
    clerks = @organisation.users.clerks.select([:id, :email, :organisation_id, :is_enable, :last_sign_in_at, :mobile])
    user_clerks = @organisation.user_clerks.select([:id, :email, :organisation_id, :mobile])
    render json: {data: clerks.map(&:clerk_json), user_clerks: user_clerks.map(&:clerk_json)}
  end
  
  def edit_clerks
    clerk = @organisation.users.clerks.select([:id, :email, :organisation_id, :is_enable, :mobile]).where(id: params[:clerk_id]).first
    if clerk.present?
      render json: {success: true, data: clerk.edit_clerk_json}
    else
      render json: {success: false}
    end
  end

  def update_clerks
    clerk = @organisation.users.clerks.where(id: params[:clerk_id]).first
    if clerk.present? && clerk.update_attributes(update_clerks_params)
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def get_clerk_roles
    user = @organisation.users.clerks.where(id: params[:user_id]).first
    if user
      roles = user.roles.map(&:name)
      user_roles = CLERK_ROLES.map{|role| {role => roles.include?(role)}}.reduce Hash.new, :merge
      render json: {success: true, roles: roles, clerks_roles: @organisation.root? ? ADMIN_CLERK_ROLES : CLERK_ROLES}
    else
      render json: {success: false}
    end
  end
  
  def update_clerk_roles
    user = @organisation.users.clerks.where(id: params[:user_id]).first
    user.manage_clerk_roles(params[:roles],  @organisation.root?)
    render json: {success: true}
  end

  def toggle_enable_users
    user = @organisation.users.clerks.where(id: params[:user_id]).first
    if user
      user.update_attributes({is_enable: params[:enabled]})
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def create_organisation_clerk
    if @organisation.path.map(&:email).include?(user_params[:email])
      return render json: {success: false, message: "You can not create organiser as clerk. Please Use different email"}
    end
    is_save, new_user = User.create_clerk(user_params, @organisation)
    if is_save
      render json: {success: true}
    else
      render json: {success: false, message: new_user.errors.full_messages.join(' , ')}
    end
  end

  #def get_user_email
  #  user = @organisation.users.clerks.where(id: params[:user_id]).first
  #  if user
  #    render json: {success: true, email: user.email}
  #  else
  #    render json: {success: false}
  #  end
  #end
  #
  #def update_clerk_password
  #  user = @organisation.users.clerks.where(id: params[:user_id], email: params[:email]).first
  #  if user && user.update_attributes(update_password_params)
  #    render json: {success: true}
  #  else
  #    render json: {success: false}
  #  end
  #end

  def delete_clerk
    user = @organisation.users.clerks.where(id: params[:user_id]).first
    if user && (!user.has_role? :organisation)
      success  = user.delete_user('clerk')
      render json: {success: success}
    else
      render json: {success: false}
    end
  end

  def get_organisation_standards
    standards = @organisation.standards.where("organisation_standards.is_assigned_to_other = ? and organisation_standards.is_active = ?", false, true)
      .where(id: params[:standards].split(','))
    render json: standards, each_serializer: StandardSerializer
  end


  def launch_sub_organisation
    if @organisation.root.subtree.map(&:email).include? organisation_params[:email]
      return render json: {success: false, message: "Organisation email allready registered in parent tree Please assign standard to organisation."}
    end
    #sub_organisation = @organisation.sub_organisations.build(organisation_params)
    sub_organisation = @organisation.sub_organisations.find_or_initialize_by({email: organisation_params[:email]})
    sub_organisation.name = "#{@organisation.name}-#{organisation_params[:name]}"
    sub_organisation.mobile = organisation_params[:mobile]
    if sub_organisation.save
      standard_ids = params[:standard_ids].split(',').map(&:to_i)
      standards = Standard.where(id: standard_ids)
      standards.each do |standard|
        @organisation.launch_sub_organisation(sub_organisation.id, standard)
      end
      render json: {success: true}
    else
      render json: {success: false, message: sub_organisation.errors.full_messages.join('. ') }
    end
  end

  def pull_back_sub_organisations
    if @organisation.descendant_ids.include?(params[:sub_organisation_id].to_i)
      old_org = @organisation.descendants.where(id: params[:sub_organisation_id]).first 
    end
    if old_org
      @organisation.pull_back_organisation(old_org)
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def remove_standard_from_organisation
    organisation_standard = OrganisationStandard.where(standard_id: params[:standard_id], organisation_id: params[:organisation_id]).first
    if organisation_standard && organisation_standard.id != @organisation.id
      if organisation_standard.is_assigned_to_other
        organisation_standard.destroy
        render json: {success: true}
      else
        success = @organisation.switch_organisation(@organisation.id, params[:standard_id])
        organisation_standard.destroy
        render json: {success: success, message: "Something went wrong"}
      end
    else
      render json: {success: false, message: "Invalide data"}
    end

  end

  def absenty_graph_report
    headers, labels, reports = @organisation.class_absenty_graph_report(params[:duration_type])
    sum_data = reports.map(&:sum)
    render json: {success: true, headers: headers, labels: labels, data: reports, sum_data: sum_data, is_display: sum_data.flatten.sum > 0}
  end

  def exams_graph_report
    headers, labels, reports = @organisation.class_exams_graph_report(params[:duration_type])
    sum_data = reports.map(&:sum)
    render json: {success: true, headers: headers, labels: labels, data: reports, sum_data: sum_data, is_display: sum_data.flatten.sum > 0}
  end

  def off_class_graph_report
    headers, labels, reports = @organisation.off_class_graph_report(params[:duration_type])
    sum_data = reports.map(&:sum)
    render json: {success: true, headers: headers, labels: labels, data: reports, sum_data: sum_data, is_display: sum_data.flatten.sum > 0}
  end

  def disable_organisation_standard
    unless @organisation.root?
      return render json: {success: false, message: "Contact to root organisation."}
    end
    organisation_standards = OrganisationStandard.where(standard_id: params[:standard_id])
    organisation_classes = JkciClass.where(standard_id: params[:standard_id])
    organisation_standards.update_all({is_active: false})
    organisation_classes.update_all({is_active: false})
    render json: {success: true}
  end

  def enable_organisation_standard
    unless @organisation.root?
      return render json: {success: false, message: "Contact to root organisation."}
    end
    organisation_standards = OrganisationStandard.where(standard_id: params[:standard_id])
    organisation_classes = JkciClass.where(standard_id: params[:standard_id])
    organisation_standards.update_all({is_active: true})
    organisation_classes.update_all({is_active: true})
    render json: {success: true}
  end

  def get_standard_fee
    if @organisation.root?
      organisation_standard= OrganisationStandard.where(id: params[:course_id]).first
      if organisation_standard.present?
        render json: {success: true, fee: organisation_standard.total_fee, name: organisation_standard.standard.std_name}
      else
        render json: {success: false, message: "Wrong standard selected"}
      end
    else
      render json: {success: false, message: "Must be root organiser"}
    end
  end

  def get_class_fee
    if @organisation.root?
      jkci_class= JkciClass.where(id: params[:class_id]).first
      if jkci_class.present?
        render json: {success: true, fee: jkci_class.fee, name: jkci_class.class_name}
      else
        render json: {success: false, message: "Wrong standard selected"}
      end
    else
      render json: {success: false, message: "Must be root organiser"}
    end
  end

  def update_standard_fee
    unless @organisation.root?
      return render json: {success: false, message: "Must be root organiser"}
    end

    if current_user &&  current_user.valid_password?(params[:fee][:password])
      organisation_standard= OrganisationStandard.where(id: params[:course_id]).first
      if organisation_standard.present?
        organisation_standard.update_attributes({total_fee: params[:fee][:fee]})
        JkciClass.where(standard_id: organisation_standard.standard_id).active.update_all({fee: params[:fee][:fee]})
        render json: {success: true, message: "Fee is updated"}
      else
        render json: {success: false, message: "Wrong standard selected"}
      end
    else
      render json: {success: false, message: "Please enter valid password"}
    end
  end

  def update_class_fee
    unless @organisation.root?
      return render json: {success: false, message: "Must be root organiser"}
    end

    if current_user &&  current_user.valid_password?(params[:fee][:password])
      jkci_class= JkciClass.where(id: params[:class_id]).first
      if jkci_class.present?
        jkci_class.update_attributes({fee: params[:fee][:fee]})
        render json: {success: true, message: "Fee is updated"}
      else
        render json: {success: false, message: "Wrong class selected"}
      end
    else
      render json: {success: false, message: "Please enter valid password"}
    end
  end
  
  def get_class_rooms
    if params[:filter] && JSON.parse(params[:filter])["class_time"]
      time = JSON.parse(params[:filter])["class_time"].to_time.in_time_zone
    else
      time = Time.current
    end

    if params[:filter] && JSON.parse(params[:filter])["end_time"]
      end_time = JSON.parse(params[:filter])["end_time"].to_time.in_time_zone
    else
      end_time = time + 2.hours
    end
    
    if params[:filter] && JSON.parse(params[:filter])["selectedWeekDay"]
      cwday = JSON.parse(params[:filter])["selectedWeekDay"]
    else
      cwday = Date.today.cwday
    end
    filter_time = time.strftime("%H.%M").to_f
    filter_end_time = end_time.strftime("%H.%M").to_f
    class_rooms = TimeTableClass.joins([{time_table: :jkci_class}]).includes([{subject: :standard}, :sub_class]).where("jkci_classes.is_current_active = ? && (time_table_classes.end_time >= ? && time_table_classes.start_time <= ?) && time_table_classes.cwday = ?", true, filter_time, filter_end_time, cwday)
    render json: {success: true, class_rooms: class_rooms.map(&:class_rooms_json), cwday: cwday, time: time, end_time: end_time}
  end
  
  def upload_logo
    logo = @organisation.logos.build
    logo.image = logo_upload_params[:image]
    logo.organisation_id = @organisation.id
    if logo.save
      @organisation.update_attributes(logo_url: logo.image_url(:thumb))
      render json: {success: true, url: logo.image_url(:thumb)}
    else
      render json: {success: false, message: document.errors.full_messages.join(' , ')}
    end
  end

  def get_last_attendances
    attendance = Attendance.last
    render json: {success: true, date: attendance.try(:date).to_s, student_id:  attendance.try(:student_id).to_i}
  end
  
  def add_attendances
    render json: {success: true}
  end

  def verify_user_mobile
    if user_token_params[:mobile_token] == current_user.mobile_token
      current_user.update_attributes({verify_mobile: true, mobile_token: nil})
      User.where(email: current_user.email, mobile: current_user.mobile).update_all({verify_mobile: true, mobile_token: nil})
      render json: {success: true}
    else
      render json: {success: false, message: "Token is not valid. Please try again"}
    end
  end

  def resend_mobile_token
    if current_user.mobile.present?
      current_user.send_otp_token
      render json: {success: true}
    else
      render json: {success: false}
    end
  end


  private
  
  def my_sanitizer
    #params.permit!
    params.require(:organisation).permit!
  end

  def organisation_params
    params.require(:organisation).permit(:parent_id, :name, :email, :mobile)
  end

  def user_params
    params.require(:clerk).permit(:email, :mobile)
  end

  def logo_upload_params
    params.require(:organisation).permit(:image)
  end

  def update_password_params
    params.require(:clerk).permit(:password, :password_confirmation, :salt, :encrypted_password)
  end

  def update_clerks_params
    params.require(:clerk).permit(:mobile)
  end

  def update_organisation_params
    params.require(:organisation).permit(:name, :email, :mobile, :password, :short_name, :account_sms, :pan_number, :tan_number, :service_tax, :enable_service_tax)
  end
  
  def user_token_params
    params.require(:user).permit(:mobile_token)
  end
end
