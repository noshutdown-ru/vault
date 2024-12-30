# plugins/vault/test/functional/key_files_controller_test.rb
require File.expand_path('../../test_helper', __FILE__)

class KeyFilesControllerTest < ActionController::TestCase
  fixtures :projects, :users, :key_files

  def setup
    @controller = KeyFilesController.new
    @request = ActionController::TestRequest.create
    @response = ActionController::TestResponse.create
    @project = projects(:one)
    @key_file = key_files(:one)
    @user = users(:one)
    @request.session[:user_id] = @user.id
  end

  def test_download_keyfile
    get :download, params: { project_id: @project.id, id: @key_file.id }
    assert_response :success
  end
end