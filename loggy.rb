require 'simple_stats'

@hash_result = {
    'GET /api/users/{user_id}/count_pending_messages' => {
        dynos: {},
        response_times: [],
        count: 0
    },
    'GET /api/users/{user_id}/get_messages' => {
        dynos: {},
        response_times: [],
        count: 0
    },
    'GET /api/users/{user_id}/get_friends_progress' => {
        dynos: {},
        response_times: [],
        count: 0
    },
    'GET /api/users/{user_id}/get_friends_score' => {
        dynos: {},
        response_times: [],
        count: 0
    },
    'POST /api/users/{user_id}' => {
        dynos: {},
        response_times: [],
        count: 0
    },
    'GET /api/users/{user_id}' => {
        dynos: {},
        response_times: [],
        count: 0
    }
}

def find_max_dyno(dynos)
  dynos.max_by { |k, v| v }
end

def extract_attributes
  file = File.open('sample.log')
  file.each_line do |f|
    log = f.split /\s+/
    @timestamp = log.shift
    @heroku = log.shift
    @log_level = log.shift
    @method = log.shift.sub!('method=', '')
    @path = log.shift.sub!('path=', '')
    @host = log.shift
    @fwd = log.shift
    @dyno = log.shift.sub('dyno=', '')
    @connect = log.shift.sub!('connect=', '')
    @service = log.shift.sub!('service=', '')

    analyze_log
  end
end

def analyze_log
  replace_user_id
  @hash_result.each do |key, value|
    if key == "#{@method} #{@path}"
      value[:count] += 1
      value[:response_times] << @connect.to_i + @service.to_i
      value[:dynos][@dyno] ||= 0
      value[:dynos][@dyno] += 1
    end
  end
end

def replace_user_id
  # Replace user id with param
  @path.gsub!(/\d+/, "{user_id}")
end


def shout_out
  @hash_result.each do |key, value|
    puts "URL => #{key} has been called #{value[:count]} times"
    puts "Average Response time: #{value[:response_times].mean} ms"
    puts "Median: #{value[:response_times].median} ms"
    puts "Mode: #{value[:response_times].modes} ms"
    puts "Most response dyno: #{find_max_dyno(value[:dynos])}"
    puts "======================================================================="
  end
end

extract_attributes
shout_out

