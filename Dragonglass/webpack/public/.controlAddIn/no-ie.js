if ((/Trident.*rv\:11\./i.test(navigator.userAgent) || /MSIE/i.test(navigator.userAgent))) {
    var title = "End of support for Internet Explorer";
    var message = "Unfortunately, NP Retail no longer supports the Internet Explorer browser.\n\nWe use advanced browser functionality and modern JavaScript technologies which don't work in Internet Explorer. Please, upgrade to a more modern browser, and try accessing this URL from there.\n\nThis was a tough (but necessary) decision to make.";
    var style = ".d{width:100%;height:100%;z-index:10000;top:0;left:0;position:fixed;background-color:#3a3a3a;color:white;font-family:Gill Sans,Segoe UI Light,Apple SD Gothic Neo Thin,Verdana,Geneva,sans-serif;font-weight:300;text-align:center;padding:25%;}.d .box{position:relative;top:50%;-webkit-transform:translateY(-50%);-moz-transform:translateY(-50%);-ms-transform:translateY(-50%);-o-transform:translateY(-50%);transform:translateY(-50%);}.d .box .title{font-size:3em;padding:1em;}.d .box .message{font-size:2em;}";
    window.top.document.body.innerHTML = '<style>' + style + '</style><div class="d"><div class="box"><div class="title">' + title + '</div><div class="message">' + message.replace(/\n/g, "<br>") + '</div></div></div>';

    throw new Error("End of support for Internet Explorer");
}