import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash"
export default class extends Controller {
  connect() {
    setTimeout(() => {
      this.dismiss()
    }, 3000)
  }

  dismiss() {
    // Bootstrapのフェードアウト用クラスを削除してアニメーション開始
    this.element.classList.remove("show")
    
    // アニメーションが終わる頃（0.5秒後）に要素自体を削除
    setTimeout(() => {
      this.element.remove()
    }, 500)
  }
}
