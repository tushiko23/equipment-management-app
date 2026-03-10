
document.addEventListener("turbo:load", function() {
  
  // 1. HTMLから要素を見つけてくる
  const roleSelect = document.getElementById("role-select");
  const permissionsArea = document.getElementById("permissions-area");

  // 【安全装置】もしプルダウンや箱が存在しない画面なら、何もしないで終了！
  if (!roleSelect || !permissionsArea) return;

  // 2. 表示を切り替える関数を作る
  function togglePermissions() {
    const selectedRole = roleSelect.value;
    
    if (selectedRole === "admin") {
      // adminなら箱を表示する
      permissionsArea.style.display = "block";
    } else {
      // それ以外（super_adminやgeneral）なら箱を隠す
      permissionsArea.style.display = "none";
      
      // 隠すついでに、中のチェックボックスのチェックを全て外す！
      const checkboxes = permissionsArea.querySelectorAll('input[type="checkbox"]');
      checkboxes.forEach(function(checkbox) {
        checkbox.checked = false;
      });
    }
  }

  // 3. プルダウンの値が変わった時に、関数を実行する見張り役をつける
  roleSelect.addEventListener("change", togglePermissions);

  // 4. 最初（画面が開いた瞬間）も一回関数を実行して、初期状態を整える
  togglePermissions();
});
