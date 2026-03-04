# spec/requests/lendings_spec.rb
require 'rails_helper'

RSpec.describe "Lendings (裏口攻撃の防御)", type: :request do
  let!(:user) { User.create!(email: "attacker@example.com", password: "password123", name: "攻撃者さん") }
  let!(:category) { Category.create!(name: "PC周辺機器") }
  let!(:lent_item) { Item.create!(name: "誰かが使用中のMac", unique_id: "L02", category: category, state: :borrowed) }

  before do
    sign_in user
  end

  describe "POST /items/:item_id/lendings" do
    context "アイテムがすでに貸出中の場合" do
      it "直接URLからPOSTリクエストを送っても、貸出データが作成されず、エラーメッセージが出ること" do
        expect {
        post item_lendings_path(lending_item), params: { lending: { lent_at: Time.current, due_at: Date.current } }
        expect(Lending.count).to eq 0
        expect(response).to redirect_to(item_path(lent_item))
        expect(flash[:alert]).to eq "このアイテムは既に貸出中です"
      }
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
end
