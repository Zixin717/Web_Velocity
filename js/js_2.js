
/* 拖曳函式 */





/* 運算函式：計算配送時間 */
function deliverDate(){

    /* new Date：買個新時鐘回家 取得今天日期 */
    /* 1. 獲取今天日期 */
    var today = new Date();

    /* getDate：從買回來的新時鐘那邊 看一下今天日期 */
    /* 2. 設定預定天數（三天後到貨） */
    var daysToAdd = 3;

    /* setDate：從買回來的新時鐘那邊 轉動時間 */
    /* 3. 算出目標日期 */
    today.setDate(today.getDate()+daysToAdd);

    /* 4. 格式化日期 */
    var finalDate = today.toLocaleDateString();

    /* 5. 抓到 HTML 的 span 把字塞進去 */
    document.getElementById('arrival-date').innerText = finalDate;
}

// 重點：呼叫函數讓它執行
deliverDate();