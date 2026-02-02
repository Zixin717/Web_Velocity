/* 拖曳函式 */

/* document.addEventListener -> 開啟文件的監聽事件 */
/* DOMContentLoaded          -> 加載 DOM 後執行 這是事件名稱   */
/* ()=>{}                    -> 要執行的程式 {} 花括號是為了裝超大一坨執行碼 */


document.addEventListener('DOMContentLoaded', ()=>
    {


        // 設置 const 常數 名字取為 slider
        // document.getElementById('') -> 文件的 取得元素ID 事件
        // productPreview -> 我裝圖片的可愛框框
        const slider = document.getElementById('productPreview');

        let isDown = false; // 設一個開關叫 isDown 然後設置 false 先不要開開關
        let startX;         // 先設變數 等等賦值會用到
        let oldScrollLeft;     // 先設變數 等等賦值會用到

        // 1. 滑鼠拖曳功能            -> Drag to Scroll
        //    slider.addEventListene -> 把 slider 裝滿滿 追加監聽事件！
        //    mousedown              -> 按下滑鼠左鍵
        //    (e)=>                  -> ()像投幣口 先設個 e 為案發報告書，然後 =>{} 是為了裝一大坨程式碼。
        slider.addEventListener('mousedown', (e)=>
            {
                isDown = true; // 這裡寫打開開關ㄉ功能

                // classList     -> 這個元素的 身分證上的 class 名單
                // add('active') -> 增加 active 這件事 ( 之前寫在 CSS 裡了！ )
                // active        -> 改變游標樣式
                slider.classList.add('active');
                // 小結論：
                // 總之就是監聽到 mousedown 後，
                // 觸發打開開關的 isDown = true，
                // 然後再追加 active 這件事。
                // 之所以需要 isDown 是因為我們還需要把功能關掉，
                // 原理是寫到這邊時，點下去後有抓手手效果，但滑鼠鬆開後手手無法鬆開所以要繼續寫 + 關掉這個功能！



                // startX     -> 前面宣告的 let 變數，現在賦值為 e 的 pageX。
                // pageX      -> 滑鼠按下去時，在整張網頁的水平座標 ( X軸 ) 是多少。就像大賣場， pageX 是按下去時算出離大賣場門口有多遠。
                // offsetLeft -> 元素左外側 到 父級參考物件 左內側的距離 （ 想像賣場有長型櫃子 -> productPreview 櫃子與門口的距離就是 offsetLeft ）
                // pageX - slider.offsetLeft -> 就是滑鼠按下去的位置( 賣場門口 與 我的距離 ) - ( 賣場門口 與 櫃子的距離 ) = 我與櫃子的距離
                startX = e.pageX - slider.offsetLeft; // 紀錄滑鼠按下的位置 -> 我與櫃子的距離

                // 想像賣場的 長型展示櫃 是捲筒衛生紙，裡面衛生紙( 圖片 )很長，開口( 視窗 )很小。
                // scrollLeft -> 捲軸向左滾動多少  -> 從盒子裡 拉出多少公分的 衛生紙
                oldScrollLeft = slider.scrollLeft        // 紀錄當前滾動的位置

                // 小結論：
                // 紀錄當滑鼠按下去觸發 mousedown 時的位置，以及拉了多少。
            });






        // 來到 slider 的監聽事件 mouseleave -> 寫滑鼠移開後會發生什麼
        // mouseleave -> 滑鼠移開後
        // slider.addEventListener('mouseleave',()=>
        //     {
        //         isDown = false; // 滑鼠移開後將開關關掉，到這邊手手不會鬆開的原因應該是還沒寫關掉開關後會發生什麼！
        //         slider.classList.remove('active'); // 這邊寫下滑鼠移開後，就移除 active 事件。
        //     });




        // // 來到 slider 的監聽事件 mouseup -> 寫 滑鼠按鍵放開後 會發生的事
        // slider.addEventListener('mouseup', ()=>
        //     {
        //         isDown = false; // 關掉開關，告訴電腦不抓了。
        //         slider.classList.remove('active'); // 移除抓緊的手手樣式，順便讓 scroll-snap (吸附功能) 恢復運作
        //     });

        // 手放開的邏輯 (整合了 mouseup & mouseleave)
        const stopDrag = () => {
            isDown = false; // 關掉開關
            slider.classList.remove('active'); // 移除抓取樣式
            
            // 【重要】手放開時，移除橡皮筋特效，讓它彈回去
            slider.classList.remove('pull-left-effect');
        };

        // 綁定監聽器
        slider.addEventListener('mouseup', stopDrag);
        slider.addEventListener('mouseleave', stopDrag);







        // 來到 slider 的監聽事件 mousemove -> 寫滑鼠移動後會發生什麼
        slider.addEventListener('mousemove', (e)=>
            {
                if(!isDown)return; // 如果沒按住滑鼠就不執行

                                   // isDown -> 按住滑鼠
                                   // !      -> 意思是「相反」
                                   // return -> 意思是「到此為止，收工回家！」後面程式碼都不執行
                                   // !isDown-> 沒按滑鼠
                                   // if(!isDown)return -> 如果沒按滑鼠就不執行，程式停在這裡圖片才不會亂飛。

                e.preventDefault();// preventDefault -> 防止預設，避免選取到文字。 (但我的圖沒有文字，所以是防止點到兩端側滑塊。)



                // 1. 算出現在手指在哪？( 現在式 )
                const x = e.pageX - slider.offsetLeft; // 設常數 x 為 e.pageX - slider.offsetLeft
                // 想像我按著滑鼠往左拖動，警衛又量了一次，發現這次距離賣場門口 140 公分。( 原本150 )
                // x = 140 - 100 = 40
                // ( 大門與我距離 ) - ( 大門與櫃子距離 ) = ( 我與櫃子距離 )
                // 手指 現在在 櫃子 40 公分處


                // 2. 算出手指移動多少( 現在 - 過去 = 移動距離)
                const walk = (x - startX)*2;
                // startX = e.pageX - slider.offsetLeft; // 原本滑鼠按下的位置 -> 我與櫃子原本的距離
                // x ( 現在40 ) - startX ( 原本50 ) = -10
                // -10 -> 代表 我的手指 往左邊移動 10 公分
                // *2  -> 加速器 所以 walk = -20

                // 推動捲軸
                // 想像賣場的 長型展示櫃 是捲筒衛生紙，裡面衛生紙( 圖片 )很長，開口( 視窗 )很小。
                // scrollLeft -> 捲軸向左滾動多少  -> 從盒子裡 拉出多少公分的 衛生紙
                // scrollLeft = slider.scrollLeft -> 紀錄當前滾動的位置
                // 先放著：slider.scrollLeft = oldScrollLeft - walk;   // 執行滾動
                // 回憶　　：oldScrollLeft 原本拉出的衛生紙是 300
                // walk 是移動距離 -20
                // 算式　　：300 - ( -20 ) = 300 + 20 = 320
                // 結果　　：新捲軸位置是 320
                // 視覺效果：衛生紙被拉出 20 公分，成功將內容往右邊捲！

                // 3. 【關鍵】先算出「理論上」捲軸應該要去哪裡
                // 我們先不直接改 slider.scrollLeft，先用一個變數存起來判斷。
                let targetScroll = oldScrollLeft - walk;

                // 情況 A：已經到最左邊 (0)，還想繼續往左拉 (targetScroll < 0)
                if (targetScroll < 0) {
                    // 1. 加上防呆特效 -> CSS
                    slider.classList.add('pull-left-effect'); // 加上 pull-left-effect 這件事 ( 之前寫在 CSS 裡了！ )

                    // 2. 如果理論上捲軸位置小於 0 ( 最左邊 )，就把它鎖在 0，不准真的滑過去。
                    // targetScroll = 0;
                    slider.scrollLeft = 0;
                }

                // 情況 B：正常滑動
                else{
                    // 移除防呆特效，不然拉回來時還是灰色的 -> CSS
                    slider.classList.remove('pull-left-effect');

                    // 執行真正的滾動
                    slider.scrollLeft = targetScroll;
                }

                // 情況 B：已經到最右邊，還想繼續往右拉 (targetScroll > maxScroll)
                /*const maxScroll = slider.scrollWidth - slider.clientWidth;
                if (targetScroll > maxScroll) {
                    targetScroll = maxScroll;
                }*/

            });
        // 小總結：
        // 寫到這邊基本上寫好了滑鼠移到上面去、點按與移動時會發生什麼。
        // 分別會發生以下事件：
        // 滑鼠按下去  -> 鼠標變成緊抓不放的手手 + 紀錄按下去的點；
        // 滑鼠移開    -> 鼠標事件移除，緊抓手手的圖案沒有了；
        // 滑鼠移動    -> 計算距離 + 滾動；






        // 2. 左右箭頭功能
        const nextBtn = document.querySelector('.next-btn');
        const prevBtn = document.querySelector('.prev-btn');


        // 取得容器寬度 ( 就是一張圖的寬度 )
        // 回憶：const slider = document.getElementById('productPreview');
        const scrollAmount = slider.clientWidth;


        // 按鈕的監聽事件是點擊
        nextBtn.addEventListener("click", ()=>
            {
                slider.scrollBy(
                    {
                        left: scrollAmount, behavior:'smooth'
                    }); 
            });

        prevBtn.addEventListener('click',()=>
            {
                slider.scrollBy(
                    {
                        left: -scrollAmount, behavior:'smooth'
                    });
            });


        /* 側邊導覽功能 */

    // 1. 抓取所有側邊小圖
    //    querySelectorAll -> 意思是抓出一組，會變成陣列 [ 圖0, 圖1, 圖2…… ]
    const sideItems = document.querySelectorAll('.sideBarItem');


    // 2. 幫每個小圖裝上監聽器
    //    forEach -> 像點名那樣把每個按鈕都叫出來綁定功能
    //    forEach ( (item, index) => {...} )
    //    item    -> 按鈕本身
    //    index   -> 它是第幾個
    sideItems.forEach((item, index)=>
        {
            item.addEventListener('click',()=>
                {
                    // 算出要滑去哪裡
                    // 公式：第幾個 * 一張大圖的寬度
                    // scrollAmount -> 總共滑多少
                    // clientWidth  -> 看的到的寬度
                    const scrollAmount = slider.clientWidth;
                    const targetPos = index*scrollAmount;

                    // 命令 slider 滑過去
                    // left: 0         -> 滾到最左邊。
                    // left: 500       -> 滾到距離左邊 500px 的地方。
                    // left: targetPos -> 滾到我們剛剛算出來的「第 N 張圖的位置」。
                    slider.scrollTo({
                        left: targetPos,    // 不知道 left 的意思
                        behavior: 'smooth'  // 平滑滾動
                    });
                });
        });


        /* 側邊購物籃 */
        // 1. 抓元素
        const cartSidebar = document.getElementById('cartSidebar'); // 抽屜
        const cartOverlay = document.getElementById('cartOverlay'); // 黑背景
        const closeCartBtn = document.getElementById('closeCartBtn'); // 關閉按鈕X

        // 用 querySelectorAll 抓取所有穿著 "open-cart-btn" 制服的按鈕
        // 這會變成一個陣列：[按鈕1, 按鈕2, 按鈕3...]
        const openCartBtns = document.querySelectorAll('.open-cart-btn');

        // 2. 事件 — 打開購物車抽屜
        const openCart = ()=>
            {
                cartSidebar.classList.add('active'); // 抽屜出現
                cartOverlay.classList.add('active'); // 黑背景出現
            }


        // 3. 事件 — 關閉購物車抽屜
        const closeCart = ()=>
            {
                cartSidebar.classList.remove('active'); // 抽屜消失
                cartOverlay.classList.remove('active'); // 黑背景消失
            }

        // 4. 綁定監聽器
        // 因為 openCartBtns 是一群人，所以我們要用 forEach 一個一個抓出來交代任務
        // btn 代表「當下抓到的那一個按鈕」
        openCartBtns.forEach((btn) => {
            btn.addEventListener('click', (e) => {
                e.preventDefault(); // 防止亂跳
                openCart();         // 執行打開
            });
        });

        closeCartBtn.addEventListener('click', closeCart); // 關閉按鈕
        cartOverlay.addEventListener('click', closeCart); // 點黑背景也能關閉
        
    });














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