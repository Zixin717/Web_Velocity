// 宣告一個功能，名字叫 v1Click（等等準備給按鈕用）
let v1Click = function(){
    console.log("開始抓資料……"); //在後台印個字確認程式有在跑

    // 1. 拿起電話筒
    //    建立一個 XMLHttpRequest 物件，簡稱 xhr。
    let xhr = new XMLHttpRequest();

    // 2. 輸入電話號碼
    //    設定要去哪裡抓資料？ get = 讀取 後面加網址
    xhr.open("GET", "https://data.moa.gov.tw/Service/OpenData/ODwsv/ODwsvTravelFood.aspx");

    // 3. 監聽 load 事件 （當下資料下載完畢時，執行裡面的 function）
    xhr.addEventListener("load", function(){
        // A. 拿到資料
        // this         -> 就是這通電話(xhr)
        // responseText -> 對方回傳的純文字
        let dataString = this.responseText;

        // B. 翻譯蒟蒻
        // JSON.parse 負責把死板的文字變成 JS 裡的可操作陣列
        let dataArray = JSON.parse(dataString);

        // 中途檢查
        // 印出來檢查一下看有沒有抓到東西
        console.log("資料轉換成功！目前有" + dataArray.length + "筆資料");

        // C. 清理桌面
        // 抓到 HTML 裡用來放結果的 div
        let resultDiv = document.getElementById("divResult");
        // 把裡面內容清空 innerHTML = 空字串，避免按兩次重疊
        resultDiv.innerHTML = "";

        // D. 把資料一筆一筆拿出來做成卡片
        // forEach = 跑迴圈 把陣列裡的每個東西(item)拿出來跑一次
        dataArray.forEach(function(item){
            // 加上神奇反引號
            // 這裡製作一張 HTML 卡片
            // ${item.Name} 會被自動換成那一筆資料的店名
            let html = `
            <div sytle = "border:1px solid #ccc; margin:10px; padding:10px;">
            <h3>${item.Name}</h3>
            <p>地址：${item.Address}</p>
            <p>特色：${item.Hostword}</p>
            </div>
            `;

        // 把做好的卡片塞進(+=) resultDiv裡
        // += 的意思是「追加」，不是「覆蓋」。
        resultDiv.innerHTML += html;
        });

    });

    // 4. 按下撥出鍵
    //    前面寫很多設定，這一行程式執行下去，程式才會真的飛出去抓資料。
    xhr.send();
}


// 按鈕事件
document.getElementById('btnV1').addEventListener('click', v1Click);