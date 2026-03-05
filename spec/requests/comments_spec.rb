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

  describe "POST /items/:item_id/comments" do
    context "有効なパラメータと、他人のuser_idを勝手に混ぜて送信した場合" do
      it "勝手に混ぜたuser_idは無視され、必ず「ログイン中のユーザー（攻撃者）」のコメントとして作成されること" do
        expect {
          post item_comments_path(item), params: {
            comment: { content: "他人のフリをしてコメントするぞ！", user_id: victim.id }
          }
        }.to change(Comment, :count).by(1)

        # 誰のコメントとして作られたかの検証
        # 新しく作られた最新のコメント（Comment.last）を取得して、
        # そのユーザーが「被害者(victim)」ではなく「ログイン中のユーザー(attacker)」になっていることを証明する
        expect(Comment.last.user_id).to eq attacker.id
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "PATCH /items/:item_id/comments/:id" do
    context "他人のコメントを勝手に編集しようとした場合（異常系）" do
      it "更新されず、元の内容が維持されること" do
        patch item_comment_path(item, target_comment), params: {
          comment: { content: "攻撃者によって書き換えられた悪意あるコメント！" }
        }
        expect(target_comment.reload.content).to eq "素晴らしい備品ですね！"
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "DELETE /items/:item_id/comments/:id" do
    context "他人のコメントを勝手に削除しようとした場合（異常系）" do
      it "削除されず、元の状態が維持されること" do
        delete item_comment_path(item, target_comment)

        # データベースからコメントが減っていないこと、安全な場所にリダイレクトされることを検証します）
        expect(Comment.count).to eq 1
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
