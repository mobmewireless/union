class ServersDatatable
  delegate :params, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Server.count,
      iTotalDisplayRecords: servers_datatable.total_entries,
      aaData: data
    }
  end

  private

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def data
    servers_datatable.map do |server|
      [
        server_hostname(server),
        server.deployments.count,
        server.projects.uniq.count
      ]
    end
  end

  def servers_datatable
    @servers ||= begin
      servers = if params[:sSearch]
        Server.where('hostname LIKE ?', "%#{params[:sSearch]}%")
      else
        Server.all
      end

      servers.order('hostname ASC').page(page).per_page(per_page)
    end
  end

  def server_hostname(server)
    link_to server.hostname, server
  end
end
