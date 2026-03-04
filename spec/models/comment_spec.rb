require 'rails_helper'

RSpec.describe Comment, type: :model do
  let!(:random_password) { (('a'..'z').to_a.sample(8) + ('0'..'9').to_a.sample(2)).shuffle.join }
  let!(:category) { Category.create!(name: "MacBook") }
  let!(:user) { User.create!(email: "test_comment@example.com", password: random_password, name: "テスト太郎") }
  let!(:item) { Item.create!(name: "MacBook", unique_id: "1000", category: category, state: :available) }
  describe "バリデーションの確認" do
    context "異常系" do
      it "コメントの中身が空の場合、保存されず無効(invalid)になること" do
        comment = Comment.new(content: "", user: user, item: item)
        expect(comment).to be_invalid
        expect(comment.errors.full_messages).to include("コメントを入力してください")
      end
    end
  end
end
