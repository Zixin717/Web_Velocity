document.addEventListener('DOMContentLoaded',()=>{
    /* 會員登入 start */
        // 1. 抓元素
        const loginOverlay = document.getElementById('loginOverlay'); // 會員登入 底下的黑背景
        const userLogin = document.getElementById('userLogin');       // 會員登入 抽屜
        const closeLoginBtn = document.getElementById('closeLoginBtn'); // 關閉按鈕X
    
        // 用 querySelectorAll 抓取所有穿著 "open-login-btn" 制服的按鈕
        // 這會變成一個陣列：[按鈕1, 按鈕2, 按鈕3...]
        const openLoginBtns = document.querySelectorAll('.open-login-btn');
    
        // 2. 事件 — 打開會員登入抽屜
        const openLogin = ()=>
            {
                userLogin.classList.add('active');    // 抽屜出現
                loginOverlay.classList.add('active'); // 黑背景出現
            };

        // 3. 事件 — 關閉會員登入抽屜
        const closeLogin = ()=>
            {
                userLogin.classList.remove('active');    // 抽屜消失
                loginOverlay.classList.remove('active'); // 黑背景消失
            };
    
        // 4. 綁定監聽器
        // 因為 openLoginBtns 是一群人，所以我們要用 forEach 一個一個抓出來交代任務
        // btn 代表「當下抓到的那一個按鈕」
        openLoginBtns.forEach((btn) => {
            btn.addEventListener('click', (e) => {
                e.preventDefault(); // 防止亂跳
                openLogin();       // 執行打開
            });
        closeLoginBtn.addEventListener('click', closeLogin); // 關閉按鈕
        loginOverlay.addEventListener('click', closeLogin); // 點黑背景也能關閉
        });
    /* 會員登入 end */
}
);