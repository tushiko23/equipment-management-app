require 'rails_helper'

RSpec.describe "Comments", type: :request do
  let!(:attacker) { User.create!(email: "attacker@example.com", password: "password123", name: "攻撃者") }
  let!(:victim) { User.create!(email: "victim@example.com", password: "password123", name: "被害者") }
  let!(:category) { Category.create!(name: "Mac製品") }
  let!(:item) { Item.create!(name: "MacBook", unique_id: "10001", category: category, state: :available) }
  
  # 被害者が書いたコメント
  let!(:target_comment) { Comment.create!(content: "素晴らしい備品ですね！", user: victim, item: item) }

  before do
    # 攻撃者がログインする
    sign_in attacker
  end

  describe "DELETE /items/:item_id/comments/:id" do
    context "他人のコメントを勝手に削除しようとした場合（異常系）" do
      it "削除されず、元の状態が維持されること" do
        delete item_comment_path(item, target_comment)

        # 2. 検証：攻撃が防がれたか確認する
        # （Lendingの時を思い出してください。データベースからコメントが減っていないこと、安全な場所にリダイレクトされることを検証します）
        expect(Comment.count).to eq 1
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
