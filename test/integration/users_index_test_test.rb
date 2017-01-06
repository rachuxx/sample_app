require 'test_helper'

class UsersIndexTestTest < ActionDispatch::IntegrationTest

  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
    @non_activated = users(:lana)
  end

  test 'index as admin including pagination and delete links' do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test 'index as non-admin' do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end

  test 'should not show not activated users on index' do
    log_in_as(@admin)
    @non_activated.update_attribute(:activated, false)
    get users_path
    assert_select 'a[href=?]', user_path(@non_activated), count: 0
  end

  test 'should redirect show when user not activated' do
    log_in_as(@admin)
    @non_activated.update_attribute(:activated, false)
    get user_path(@non_activated)
    assert_redirected_to root_path
  end
end
