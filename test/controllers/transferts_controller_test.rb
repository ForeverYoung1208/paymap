require 'test_helper'

class TransfertsControllerTest < ActionController::TestCase
  setup do
    @transfert = transferts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:transferts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create transfert" do
    assert_difference('Transfert.count') do
      post :create, transfert: { baz_dot: @transfert.baz_dot, filename: @transfert.filename, rev_dot: @transfert.rev_dot }
    end

    assert_redirected_to transfert_path(assigns(:transfert))
  end

  test "should show transfert" do
    get :show, id: @transfert
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @transfert
    assert_response :success
  end

  test "should update transfert" do
    patch :update, id: @transfert, transfert: { baz_dot: @transfert.baz_dot, filename: @transfert.filename, rev_dot: @transfert.rev_dot }
    assert_redirected_to transfert_path(assigns(:transfert))
  end

  test "should destroy transfert" do
    assert_difference('Transfert.count', -1) do
      delete :destroy, id: @transfert
    end

    assert_redirected_to transferts_path
  end
end
