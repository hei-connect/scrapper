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
        log = "#{params[:route_info].route_method} #{params[:route_info].route_version}/" +
            "#{params[:route_info].route_path.split('/')[2..-1].join('/').gsub(/\(.*\)/, '')}"
        log += " for #{params[:username]}" if params[:username]
        log
      }
    end

    desc 'Test the given credentials and return if they are valid'
    get :validate_credentials do
      validation = Konosys::Actions::Validation.new(params[:username], params[:password])

      result = begin
        validation.perform
        true
      rescue Konosys::Exceptions::LoginError
        logger.error "Login failed for #{params[:username]}"
        false
      ensure
        validation.finish
      end

      {valid: result}
    end

    desc 'Fetch the courses of the current and next week'
    get :schedule do
      schedule = Konosys::Actions::Schedule.new(params[:username], params[:password])

      begin
        weeks = schedule.fetch_current_and_next_week
      rescue Konosys::Exceptions::LoginError
        logger.error "Login failed for #{params[:username]}"
        error!({error: 'Login failed'}, 401)
      ensure
        schedule.finish
      end

      present weeks, with: Konosys::Models::Week::Entity
    end

    resource :system do
      desc 'Simple get request that returns OK'
      get :status do
        'OK'
      end
    end
  end
end