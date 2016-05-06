require File.join(File.expand_path(File.dirname(__FILE__)), 'loggy.rb')
require 'test/unit'

class LoggyTest < Test::Unit::TestCase

  def test_that_we_should_get_max_dyno
    hash = {'web.2' => 5, 'web.3' => 2, 'web.7' => 10}
    assert_equal ['web.7', 10], find_max_dyno(hash)
  end

  def test_that_we_can_replace_user_id_in_path
    @path = '/api/users/1234/get_friends_progress'
    assert_equal '/api/users/{user_id}/get_friends_progress', replace_user_id
  end

  def test_that_we_can_extract_attributes_from_log_file
    log_line = '2014-01-09T06:16:53.748849+00:00 heroku[router]: at=info method=POST path=/api/online/platforms/facebook_canvas/users/100002266342173/add_ticket host=services.pocketplaylab.com fwd="94.66.255.106" dyno=web.12 connect=12ms service=21ms status=200 bytes=78'
    cleaned_log = log_line.split /\s+/
    extract_attributes(cleaned_log)
    assert_equal 'POST', @method
    assert_equal '/api/online/platforms/facebook_canvas/users/100002266342173/add_ticket', @path
    assert_equal 'web.12', @dyno
    assert_equal '12ms', @connect
    assert_equal '21ms', @service
  end

  def test_that_we_can_analyze_log_and_get_correct_result
    @hash_result = {
      'GET /api/users/{user_id}/count_pending_messages' => {
          dynos: {},
          response_times: [],
          count: 0
      }
    }
    @method = 'GET'
    @path = '/api/users/{user_id}/count_pending_messages'
    @connect = '12ms'
    @service = '15ms'

    analyze_log
    assert_equal 1, @hash_result.values[0][:count]
    assert_equal [27], @hash_result.values[0][:response_times]
  end
end
