module LoginMacros
  def login_as(user)
    visit new_user_session_path
    fill_in "user_email", with: user.email
    fill_in "user_password", with: user.password
    click_button "ログイン"
    # ログイン完了を待つ（フライング防止）
    expect(page).to have_content "ログインしました。"
  end
end
