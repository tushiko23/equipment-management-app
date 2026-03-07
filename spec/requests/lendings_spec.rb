# spec/requests/lendings_spec.rb
require 'rails_helper'

RSpec.describe "Lendings (裏口攻撃の防御)", type: :request do
  let!(:user) do
  User.find_by(email: "attacker@example.com") ||
  User.create!(email: "attacker@example.com", password: "password123", name: "攻撃者")
  end
  let!(:category) { Category.find_or_create_by!(name: "PC周辺機器") }
  let!(:lent_item) { Item.create!(name: "誰かが使用中のMac", unique_id: "L02", category: category, state: :borrowed) }

  before do
    sign_in user
  end

  describe "POST /items/:item_id/lendings" do
    context "アイテムがすでに貸出中の場合" do
      it "直接URLからPOSTリクエストを送っても、貸出データが作成されず、エラーメッセージが出ること" do
        post item_lendings_path(lent_item), params: { lending: { lent_at: Time.current, due_at: Date.current } }
        expect(Lending.count).to eq 0
        expect(response).to redirect_to(item_path(lent_item))
        expect(flash[:alert]).to eq "このアイテムは既に貸出中です"
      end
    end

    context "アイテムが貸出可（available）の場合" do
      let!(:available_item) { Item.create!(name: "誰も使っていないMac", unique_id: "L03", category: category, state: :available) }
      it "POSTリクエストを送ると、新しく貸出データが1件作成され、成功メッセージが出ること" do
        expect {
          post item_lendings_path(available_item), params: { lending: { lent_at: Time.current, due_at: 1.day.from_now } }
        }.to change(Lending, :count).by(1)
        expect(response).to redirect_to(available_item)
        expect(flash[:notice]).to eq "貸出処理が完了しました"
      end
    end
  end

  describe "PATCH /items/:item_id/lendings/:id" do
    # 1. 準備：攻撃者（ログイン中）、被害者、そして被害者が借りているアイテムを用意する
    let!(:victim_user) { User.create!(email: "victim@example.com", password: "password123", name: "被害者さん") }
    let!(:borrowed_item) { Item.create!(name: "被害者のMac", unique_id: "R01", category: category, state: :borrowed) }

    let!(:target_lending) do
      lending = Lending.new(item: borrowed_item, user: victim_user, lent_at: 1.day.ago, due_at: 1.day.from_now)
      lending.save!(validate: false) # テストの準備なので、バリデーションを特別に無視する！
      lending
    end

    context "他人が借りているアイテムを勝手に返却しようとした場合（異常系）" do
      it "返却処理が行われず、元の状態が維持されること" do
        patch item_lending_path(borrowed_item, target_lending)
        expect(response).to have_http_status(:redirect)
        expect(target_lending.reload.returned_at).to eq nil
        expect(borrowed_item.reload.state).to eq "borrowed"
      end
    end
  end
end
