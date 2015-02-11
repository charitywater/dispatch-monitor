class ProjectsController < ApplicationController
  def index
    params[:filters] ||= {}
    params[:filters]["sort_column"] = "deployment_code" if params[:filters]["sort_column"].nil?
    params[:filters]["sort_direction"] = "asc" if params[:filters]["sort_direction"].nil?

    @projects = ProjectList.new(FilterForm.new(filter_params))
  end

  def search
    @search = Project.search do
      fulltext params["deployment_code"]
    end
    
    @projects = CollectionPresenter.new(@search.results, ProjectPresenter)
  end

  def show
    redirect_to map_project_path(params[:id])
  end

  def edit
    project = Project.find(params[:id])
    authorize project, :update?

    @project = ProjectPresenter.new(project)
  end

  def update
    project = Project.find(params[:id])
    authorize project, :update?

    if project.update(project_params)
      redirect_to projects_path,
        success: t(
          '.success',
          community_name: project.community_name,
          deployment_code: project.deployment_code,
      )
    else
      @project = ProjectPresenter.new(project)
      flash.now[:alert] = t('.alert')
      render :edit
    end
  end

  def destroy
    project = Project.find(params[:id])
    authorize project, :destroy?

    project.destroy

    redirect_to projects_path,
        success: t(
          '.success',
          community_name: project.community_name,
          deployment_code: project.deployment_code,
      )
  end

  private

  def project_params
    params.require(:project)
      .permit(*editable_fields)
      .map { |k, v| [k, v.strip] }.to_h
      .with_indifferent_access
      .merge(contact_phone_numbers: phone_numbers)
  end

  def editable_fields
    %i(
      beneficiaries community_name contact_email contact_name
      cost_actual district funding_source image_url
      inventory_cost inventory_group inventory_type is_ready_to_fund latitude
      location_type longitude package_id package_name plaque_text
      possible_location_types quarter region resubmission_notes
      revenue_category revenue_category_display_label review_status_name
      site_name state sub_district system_name water_point_name
    )
  end

  def phone_numbers
    values = (params[:project][:contact_phone_numbers] || {}).values
    values.map(&:strip).select(&:present?)
  end
end
