require 'test_helper'

class DequeuedMessagesControllerTest < ActionController::TestCase
  setup do
    @dequeued_message = dequeued_messages(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:dequeued_messages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dequeued_message" do
    assert_difference('DequeuedMessage.count') do
      post :create, dequeued_message: { body: @dequeued_message.body }
    end

    assert_redirected_to dequeued_message_path(assigns(:dequeued_message))
  end

  test "should show dequeued_message" do
    get :show, id: @dequeued_message
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @dequeued_message
    assert_response :success
  end

  test "should update dequeued_message" do
    put :update, id: @dequeued_message, dequeued_message: { body: @dequeued_message.body }
    assert_redirected_to dequeued_message_path(assigns(:dequeued_message))
  end

  test "should destroy dequeued_message" do
    assert_difference('DequeuedMessage.count', -1) do
      delete :destroy, id: @dequeued_message
    end

    assert_redirected_to dequeued_messages_path
  end
end
