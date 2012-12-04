module API
  class API_v1 < Grape::API

    version 'v1', :using => :path

    helpers do
      def logger
        API.logger
      end
    end

    before do
      logger.info {
        "#{params[:route_info].route_method} #{params[:route_info].route_version}/" +
            "#{params[:route_info].route_path.split('/')[2..-1].join('/').gsub(/\(.*\)/, '')}" +
            " for #{params[:username]}"
      }
    end

    resource :schedule do
      desc 'Fetch the courses of the current and next week'
      get '/' do
        schedule = Konosys::Actions::Schedule.new(params[:username], params[:password])

        begin
          weeks = schedule.fetch_current_and_next_week
        rescue Konosys::Exceptions::LoginError
          logger.error "Login failed for #{params[:username]}"
          error!({error: 'Login failed'}, 401)
        end

        schedule.finish

        present weeks, with: Konosys::Models::Week::Entity
      end
    end

  end
end