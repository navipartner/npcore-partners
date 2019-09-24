codeunit 6060126 "MM Membership Kiosk"
{
    // MM1.28/TSA /20180213 CASE 302748 Initial Version

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    procedure GetCss(PageId: Integer) Css: Text
    begin

        case PageId of
          0 : Css := WelcomePageCss ();
          1 : Css := ScanTicketBarcodeCss();
          2 : Css := MemberInfoCaptureCss();
          3 : Css := TakePhotoCss();
          4 : Css := PreviewCardCss ();
          5 : Css := PrintCss ();
          6 : Css := ShowErrorCss ();
          else
            Css := WelcomePageCss ();
        end;
    end;

    procedure GetHtml(PageId: Integer;var Parameters: DotNet JObject) Html: Text
    begin

        case PageId of
          0 : Html := WelcomePage (Parameters);
          1 : Html := ScanTicketBarcodePage (Parameters);
          2 : Html := MemberInfoCapturePage (Parameters);
          3 : Html := TakePhotoPage (Parameters);
          4 : Html := PreviewCardPage (Parameters);
          5 : Html := PrintPage (Parameters);
          6 : Html := ShowErrorPage (Parameters);
          else
            Html := WelcomePage (Parameters);
        end;
    end;

    procedure GetScript(PageId: Integer) Script: Text
    begin
        case PageId of
          0 : Script := WelcomePageScript ();
          1 : Script := ScanTicketBarcodeScript () ;
          2 : Script := MemberInfoCaptureScript ();
          3 : Script := TakePhotoScript ();
          4 : Script := PreviewCardScript ();
          5 : Script := PrintScript ();
          6 : Script := ShowErrorScript ();
          else
            Script := WelcomePageScript ();
        end;
    end;

    local procedure "--Json Helper"()
    begin
    end;

    local procedure GetStringValue(JObject: DotNet JObject;"Key": Text): Text
    var
        JToken: DotNet JToken;
    begin

        JToken := JObject.GetValue (Key);
        if (IsNull (JToken)) then
          exit ('');

        exit (JToken.ToString ());
    end;

    local procedure "Kiosk Pages"()
    begin
    end;

    procedure WelcomePageCss() CSS: Text
    begin

        CommonCss (CSS);

        CSS+=
        '.touch-anywhere {'+
        ' position:absolute;'+
        ' bottom:5vh;'+
        ' right:5vh;'+
        ' font-weight:bold;'+
        ' font-size:calc(1vw+1vh+0.5vmin);'+
        '}';

        CSS+=
        '.home a{'+
        ' position:fixed;'+
        ' width:100%;'+
        ' height:100%;'+
        ' top:0;'+
        ' left:0;'+
        '}';

        CSS+=
        '#logo{'+
        ' display:flex;'+
        ' justify-content:left;'+
        ' align-items:center;'+
        ' width:80%;'+
        ' height:100%;'+
        ' margin:auto;'+
        '}';
    end;

    local procedure WelcomePage(var Parameters: DotNet JObject) Html: Text
    begin
        Html :=
        '<!doctype html>'+
        '<html lang="en">'+
        '<head>'+
        '    <meta charset="utf-8">'+
        '    <title>Self-service kiosk</title>'+
        //'    <link href="https://navipartner.test.navipartner.dk/self-service-kiosk/css/styles.css" media="screen, projection" rel="stylesheet" type="text/css" />'+
        //'    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>'+
        //'    <link href="https://fonts.googleapis.com/css?family=Lato:400,700" rel="stylesheet">'+
        '</head>'+
        '    <body class="home">'+
        '       <div id="main">'+
        '           <a href="#" title="Touch anywhere to start" onClick="NavigateNext();return false;">'+
        '           <div id="logo">'+
        '               <img src="https://navipartner.test.navipartner.dk/self-service-kiosk/images/logo.gif" alt="Navipartner" />'+
        '           </div></a>'+
        '           <div class="touch-anywhere">'+
        '               Touch anywhere to start'+
        '           </div>'+
        '       </div>'+
        '    </body>'+
        '</html>';
    end;

    local procedure WelcomePageScript() Script: Text
    begin
        Script :=
        '  window.NavigateNext = function() {' +
        '     var NavigateNextMethod = new n$.Event.Method("NavigateNext"); ' +
        '         NavigateNextMethod.raise();' +
        '  }';
    end;

    local procedure ScanTicketBarcodeCss() Css: Text
    begin

        CommonCss (Css);
        ContainerCss (Css);
    end;

    local procedure ScanTicketBarcodePage(var Parameters: DotNet JObject) Html: Text
    begin

        Html :=
        '<!doctype html>'+
        '<html lang="en">'+
        '<head>'+
        '    <meta charset="utf-8">'+
        '    <title>Scan your barcode | Self-service kiosk</title>'+
        //'    <link href="https://navipartner.test.navipartner.dk/self-service-kiosk/css/styles.css" media="screen, projection" rel="stylesheet" type="text/css" />'+
        '</head>'+
        '    <body>'+
        '       <div id="main">'+
        '           <a href="#" OnClick="StartPage();return false";><img id="small-logo" src="https://navipartner.test.navipartner.dk/self-service-kiosk/images/logo.gif" alt="Navipartner" /></a>'+
        '           <div id="container">'+
        '               <h1>New membership</h1>'+
        '               <div id="content">'+
        '                   <h2>Scan your barcode<br />to begin membership registration</h2>'+
        '                   <a class="barcode" href="#"><img src="https://navipartner.test.navipartner.dk/self-service-kiosk/images/barcode.jpg" alt="Navipartner" /></a>'+
        '                   <input id="typed4" type="text" placeholder="Scan ticket number." />'+
        '               </div>'+
        '               <a class="next nav" href="#" onClick="NavigateNext(); return false;"><span>Next</span></a>'+
        '           </div>'+
        '       </div>'+
        '    </body>'+
        '</html>';
    end;

    local procedure ScanTicketBarcodeScript() Script: Text
    begin
        Script :=
        '  window.StartPage = function() {' +
        '     var StartPageMethod = new n$.Event.Method("StartPage"); ' +
        '         StartPageMethod.raise();' +
        '  };';

         Script +=
         '  window.NavigateNext = function() {' +
         '     var NavigateNextMethod = new n$.Event.Method("NavigateNext"); ' +
         '         NavigateNextMethod.raise({ ticketbarcode: document.getElementById("typed4").value });' +
         '  };';

        Script +=
         '  setTimeout(function() {' +
         '    var typed4 = document.getElementById("typed4");' +
         '    typed4.focus();' +
         '    typed4.onkeyup = function(e) {' +
         '      e.which === 13 && NavigateNext();' +
         '    };' +
         '  }, 500);';
    end;

    local procedure MemberInfoCaptureCss() Css: Text
    begin

        CommonCss (Css);
        ContainerCss (Css);
    end;

    local procedure MemberInfoCapturePage(var Parameters: DotNet JObject) Html: Text
    begin
        Html :=

        '<!doctype html>'+
        '<html lang="en">'+
        '<head>'+
        '    <meta charset="utf-8">'+
        '    <meta name="viewport" content="width=device-width, initial-scale=1" />'+
        '    <title>Data entry | Self-service kiosk</title>'+
        //'    <link href="https://navipartner.test.navipartner.dk/self-service-kiosk/css/styles.css" media="screen, projection" rel="stylesheet" type="text/css" />'+
        '</head>'+
        '    <body>'+
        '       <div id="main">'+
        '           <a href="#" OnClick="StartPage();return false";><img id="small-logo" src="https://navipartner.test.navipartner.dk/self-service-kiosk/images/logo.gif" alt="Navipartner" /></a>'+
        '           <div id="container">'+
        '               <h1>New membership</h1>'+
        '               <div id="content">'+
        '                   <h2>Please type requested info:</h2>'+
        StrSubstNo ('           <input id="mmFirstName" placeholder="First name" value="%1"/>', GetStringValue (Parameters, 'FirstName'))+
        StrSubstNo ('           <input id="mmLastName" placeholder="Last name" value="%1"/>', GetStringValue (Parameters, 'LastName'))+
        StrSubstNo ('           <input id="mmEmail" placeholder="Email address" value="%1"/>', GetStringValue (Parameters, 'EmailAddress'))+
        StrSubstNo ('           <input id="mmBirthDate" placeholder="Date of birth (DD/MM/YYYY)" value="%1"/>', GetStringValue (Parameters, 'DayOfBirth'))+
        StrSubstNo ('           <input id="mmPhone" placeholder="Phone number" value="%1"/>', GetStringValue (Parameters, 'PhoneNumber'))+
        '               </div>'+
        '               <a class="back nav" href="#" onClick="StartPage(); return false;"><span>Back</span></a>'+
        '               <a class="next nav" href="#" onClick="NavigateNext(); return false;"><span>Next</span></a>'+
        '           </div>'+
        '       </div>'+
        '    </body>'+
        '</html>';
    end;

    local procedure MemberInfoCaptureScript() Script: Text
    begin

        Script :=
        '  window.StartPage = function() {' +
        '     var StartPageMethod = new n$.Event.Method("StartPage"); ' +
        '         StartPageMethod.raise();' +
        '  };';

         Script +=
         '  window.NavigateNext = function() {' +
         '     var NavigateNextMethod = new n$.Event.Method("NavigateNext"); ' +
         '         NavigateNextMethod.raise({'+
         '           mmFirstName: document.getElementById("mmFirstName").value,'+
         '           mmLastName: document.getElementById("mmLastName").value,'+
         '           mmEmail: document.getElementById("mmEmail").value,'+
         '           mmBirthDate: document.getElementById("mmBirthDate").value,'+
         '           mmPhone: document.getElementById("mmPhone").value,'+
         '         });' +
         '  };';

        Script +=
         '  setTimeout(function() {' +
         '    var mmFirstName = document.getElementById("mmFirstName");' +
         '    var mmLastName = document.getElementById("mmLastName");' +
         '    var mmEmail = document.getElementById("mmEmail");' +
         '    var mmBirthDate = document.getElementById("mmBirthDate");' +
         '    var mmPhone = document.getElementById("mmPhone");' +
         '    mmFirstName.focus();' +
         '    mmFirstName.onkeyup = function(e) {(e.which === 13) && mmLastName.focus(); };' +
         '    mmLastName.onkeyup = function(e) {(e.which === 13) && mmEmail.focus(); };' +
         '    mmEmail.onkeyup = function(e) {(e.which === 13) && mmBirthDate.focus(); };' +
         '    mmBirthDate.onkeyup = function(e) {(e.which === 13) && mmPhone.focus(); };' +
         '    mmPhone.onkeyup = function(e) {e.which === 13 && NavigateNext(); };' +
         '  }, 500);';
    end;

    local procedure TakePhotoCss() Css: Text
    begin

        CommonCss (Css);
        ContainerCss (Css);
    end;

    local procedure TakePhotoPage(var Parameters: DotNet JObject) Html: Text
    begin
        Html :=
        '<!doctype html>'+
        '<html lang="en">'+
        '<head>'+
        '    <meta charset="utf-8">'+
        '    <meta name="viewport" content="width=device-width, initial-scale=1" />'+
        '    <title>Take a photo | Self-service kiosk</title>'+
        //'    <link href="https://navipartner.test.navipartner.dk/self-service-kiosk/css/styles.css" media="screen, projection" rel="stylesheet" type="text/css" />'+
        '</head>'+
        '    <body>'+
        '       <div id="main">'+
        '           <a href="#" OnClick="StartPage();return false";><img id="small-logo" src="https://navipartner.test.navipartner.dk/self-service-kiosk/images/logo.gif" alt="Navipartner" /></a>'+
        '           <div id="container">'+
        '               <h1>New membership</h1>'+
        '               <div id="content">'+
        '                   <h2>Take a photo:</h2>'+
        '                   <div class="photo-holder"><img src="https://navipartner.test.navipartner.dk/self-service-kiosk/images/transparent.png" alt="Navipartner" /></div>'+
        '                   <a class="camera" href="#"></a>'+
        '                   <h3>Press the icon when you are ready!</h3>'+
        '               </div>'+
        '               <a class="back nav" href="#" onClick="NavigateBack(); return false;"><span>Back</span></a>'+
        '               <a class="next nav" href="#" onClick="NavigateNext(); return false;"><span>Next</span></a>'+
        '           </div>'+
        '       </div>'+
        '    </body>'+
        '</html>';
    end;

    local procedure TakePhotoScript() Script: Text
    begin

        Script :=
        '  window.StartPage = function() {' +
        '     var StartPageMethod = new n$.Event.Method("StartPage"); ' +
        '         StartPageMethod.raise();' +
        '  };';

        Script +=
        '  window.NavigateBack = function() {' +
        '     var NavigateBackMethod = new n$.Event.Method("NavigateBack"); ' +
        '         NavigateBackMethod.raise();' +
        '  };';

        Script +=
        '  window.NavigateNext = function() {' +
        '     var NavigateNextMethod = new n$.Event.Method("NavigateNext"); ' +
        '         NavigateNextMethod.raise();' +
        '  };';
    end;

    local procedure PreviewCardCss() Css: Text
    begin

        CommonCss (Css);
        ContainerCss (Css);
    end;

    local procedure PreviewCardPage(var Parameters: DotNet JObject) Html: Text
    begin

        //MESSAGE ('Params: %1', Parameters.ToString ());

        Html :=
        '<!doctype html>'+
        '<html lang="en">'+
        '<head>'+
        '    <meta charset="utf-8">'+
        '    <meta name="viewport" content="width=device-width, initial-scale=1" />'+
        '    <title>Card preview | Self-service kiosk</title>'+
        //'    <link href="https://navipartner.test.navipartner.dk/self-service-kiosk/css/styles.css" media="screen, projection" rel="stylesheet" type="text/css" />'+
        '</head>'+
        '    <body>'+
        '       <div id="main">'+
        '           <a href="#" OnClick="StartPage();return false";><img id="small-logo" src="https://navipartner.test.navipartner.dk/self-service-kiosk/images/logo.gif" alt="Navipartner" /></a>'+
        '           <div id="container">'+
        '               <h1>New membership</h1>'+
        '               <div id="content">'+
        '                   <h2>Membership card preview</h2>'+
        '                   <div class="preview-card-holder">'+
        '                        <div class="left"><img src="https://navipartner.test.navipartner.dk/self-service-kiosk/images/photo.jpg" alt="Navipartner" /></div>'+
        StrSubstNo ('                            <div class="name">%1 %2</div>', GetStringValue (Parameters, 'FirstName'), GetStringValue (Parameters, 'LastName')) +
        StrSubstNo ('                            <div class="date">%1</div>', GetStringValue (Parameters, 'DayOfBirth')) +
        StrSubstNo ('                            <div class="name">%1</div>', GetStringValue (Parameters, 'EmailAddress')) +
        StrSubstNo ('                            <div class="name">%1</div>', GetStringValue (Parameters, 'PhoneNumber')) +
        '                        </div>'+
        '                   </div>'+
        '               <a class="back nav" href="#" onClick="NavigateBack(); return false;"><span>Back</span></a>'+
        '               <a class="next nav" href="#" onClick="NavigateNext(); return false;"><span>PRINT</span></a>'+
        '               </div>'+
        '           </div>'+
        '       </div>'+
        '    </body>'+
        '</html>';
    end;

    local procedure PreviewCardScript() Script: Text
    begin

        Script :=
        '  window.StartPage = function() {' +
        '     var StartPageMethod = new n$.Event.Method("StartPage"); ' +
        '         StartPageMethod.raise();' +
        '  };';

        Script +=
        '  window.NavigateBack = function() {' +
        '     var NavigateBackMethod = new n$.Event.Method("NavigateBack"); ' +
        '         NavigateBackMethod.raise();' +
        '  };';

        Script +=
        '  window.NavigateNext = function() {' +
        '     var NavigateNextMethod = new n$.Event.Method("NavigateNext"); ' +
        '         NavigateNextMethod.raise();' +
        '  };';
    end;

    local procedure PrintCss() Css: Text
    begin

        CommonCss (Css);
        ContainerCss (Css);
        LoaderCss (Css);

        Css+=
        '#small-printer {'+
        ' width:150px;'+
        ' position:relative;'+
        '}';
    end;

    local procedure PrintPage(var Parameters: DotNet JObject) Html: Text
    begin

        Html :=
        '<!doctype html>'+
        '<html lang="en">'+
        '<head>'+
        '    <meta charset="utf-8">'+
        '    <meta name="viewport" content="width=device-width, initial-scale=1" />'+
        '    <title>Printing | Self-service kiosk</title>'+
        //'    <link href="https://navipartner.test.navipartner.dk/self-service-kiosk/css/styles.css" media="screen, projection" rel="stylesheet" type="text/css" />'+
        '</head>'+
        '    <body>'+
        '       <div id="main">'+
        '           <div id="container">'+
        '               <h1>New membership</h1>'+
        '               <div id="content">'+
        '                   <h2>Printing your membercard...</h2>'+
        '                   <img id="small-printer" src="https://navipartner.test.navipartner.dk/self-service-kiosk/images/print.png" alt="Navipartner" />'+
        '                   <div class="loader12"></div>'+
        '               </div>'+
        '           </div>'+
        '       </div>'+
        '    </body>'+
        '</html>';
    end;

    local procedure PrintScript() Script: Text
    begin
        Script :=
        ' window.StartPage = function() {' +
        '   var StartPageMethod = new n$.Event.Method("StartPage"); ' +
        '       StartPageMethod.raise();' +
        '};';

        Script +=
        ' window.PageTimeOut = function() {'+
        '   var delay = 5000;'+
        '   setTimeout(function(){ StartPage(); }, delay);'+
        '}; PageTimeOut();';
    end;

    local procedure ShowErrorCss() Css: Text
    begin

        CommonCss (Css);
        ContainerCss (Css);
        LoaderCss (Css);
    end;

    local procedure ShowErrorPage(var Parameters: DotNet JObject) Html: Text
    begin

        Html :=
        '<!doctype html>'+
        '<html lang="en">'+
        '<head>'+
        '    <meta charset="utf-8">'+
        '    <meta name="viewport" content="width=device-width, initial-scale=1" />'+
        '    <title>Printing | Self-service kiosk</title>'+
        //'    <link href="https://navipartner.test.navipartner.dk/self-service-kiosk/css/styles.css" media="screen, projection" rel="stylesheet" type="text/css" />'+
        '</head>'+
        '    <body>'+
        '       <div id="main">'+
        '           <div id="container">'+
        '               <h1 class="errorInformation">Ops! Something went wrong.</h1>'+
        '               <div id="content">'+
        StrSubstNo('                   <h3>%1</h3>', GetStringValue (Parameters, 'ErrorMessage')) +
        '               <div class="loader12"></div>'+
        '               <a class="next nav" href="#" onClick="OnAfterError(); return false;"><span>Next</span></a>'+
        '               </div>'+
        '           </div>'+
        '       </div>'+
        '    </body>'+
        '</html>';
    end;

    local procedure ShowErrorScript() Script: Text
    begin

        Script :=
        ' window.StartPage = function() {' +
        '   var StartPageMethod = new n$.Event.Method("StartPage"); ' +
        '       StartPageMethod.raise();' +
        '};';

        Script +=
        '  window.OnAfterError = function() {' +
        '     var OnAfterErrorMethod = new n$.Event.Method("OnAfterError"); ' +
        '         OnAfterErrorMethod.raise();' +
        '  };';

        Script +=
        ' window.PageTimeOut = function() {'+
        '   var delay = 15000;'+
        '   setTimeout(function(){ OnAfterError(); }, delay);'+
        '}; PageTimeOut();';
    end;

    local procedure CommonCss(var Css: Text)
    begin

        Css:=
        'html,body,div,span,applet,object,iframe,'+
        'h1,h2,h3,h4,h5,h6,p,blockquote,pre,'+
        'a,abbr,acronym,address,big,cite,code,'+
        'del,dfn,em,img,ins,kbd,q,s,samp,'+
        'small,strike,strong,sub,sup,tt,var,'+
        'b,u,i,center,'+
        'dl,dt,dd,ol,ul,li,'+
        'fieldset,form,label,legend,'+
        'table,caption,tbody,tfoot,thead,tr,th,td,'+
        'article,aside,canvas,details,embed,'+
        'figure,figcaption,footer,header,hgroup,'+
        'menu,nav,output,ruby,section,summary,'+
        'time,mark,audio,video {'+
        ' margin:0;'+
        ' padding:0;'+
        ' border:0;'+
        ' font:inherit;'+
        ' font-size:100%;'+
        ' vertical-align:baseline;'+
        '}';

        Css+=
        'body {'+
        ' background:#005191;'+
        ' display:flex;'+
        ' height:100vh;'+
        ' justify-content:center;'+
        ' align-items:center;'+
        ' font-family:"Lato",sans-serif;'+
        '}';

        Css+=
        '#main {'+
        ' height:70%;'+
        ' min-height:500px;'+
        ' background:#fff;'+
        ' width:1200px;'+
        ' border-radius:15px;'+
        ' margin:50px;'+
        ' position:relative;'+
        '}';

        Css+=
        '#small-logo {'+
        ' width:300px;'+
        ' position:absolute;'+
        ' top:40px;'+
        ' left:40px;'+
        '}';
    end;

    local procedure ContainerCss(var Css: Text)
    begin

        Css +=
        '#container {'+
        ' text-align:center;'+
        ' height:70%;'+
        ' display:flex;'+
        ' flex-flow:column;'+
        ' justify-content:center;'+
        '}';

        Css +=
        '#container h1 {'+
        ' font-size:40px;'+
        ' font-weight:bold;'+
        ' text-transform:uppercase;'+
        ' margin-bottom:40px;'+
        '}'+
        '@media only screen and (max-height:899px) {'+
        ' #container h1 {'+
        ' font-size:40px;'+
        ' margin-bottom:20px;'+
        ' }'+
        '}';

        Css +=
        '#container h2 {'+
        ' font-size:30px;'+
        ' margin-bottom:10px;'+
        ' line-height:30px;'+
        '}'+
        '@media only screen and (max-height:899px) {'+
        ' #container h2 {'+
        ' font-size:30px;'+
        ' line-height:40px;'+
        ' margin-bottom:20px;'+
        ' }'+
        '}';

        Css +=
        '#container h3 {'+
        ' font-size:24px;'+
        '}';

        Css +=
        '.errorInformation {'+
        ' font-size:24px;'+
        ' color:#ff0000;'+
        '}';

        Css +=
        '#container form {'+
        ' text-align:center;'+
        ' margin-top:10px;'+
        '}';

        Css +=
        '#container input {'+
        ' background:#000;'+
        ' color:#fff;'+
        ' width:500px;'+
        ' height:30px;'+
        ' font-size:20px;'+
        ' padding:0 5px;'+
        ' font-weight:normal;'+
        ' border:none;'+
        ' display:block;'+
        ' clear:both;'+
        ' margin:auto;'+
        '}';

        Css +=
        '#container .click_here {'+
        ' position:absolute;'+
        ' width:100px;'+
        ' top:50px;'+
        '}';

        Css +=
        '#container a.nav {'+
        ' font-weight:bold;'+
        ' color:#005191;'+
        ' background:url(https://navipartner.test.navipartner.dk/self-service-kiosk/images/sprite.png) no-repeat;'+
        ' width:92px;'+
        ' height:92px;'+
        '}';

        Css +=
        '#container a.nav span {'+
        ' display:block;'+
        ' text-transform:uppercase;'+
        ' margin-top:100px;'+
        ' font-size:28px;'+
        '}';

        Css +=
        '#container a.nav.back {'+
        ' position:absolute;'+
        ' bottom:70px;'+
        ' left:40px;'+
        '}';

        Css +=
        '#container a.nav.next {'+
        ' position:absolute;'+
        ' bottom:70px;'+
        ' right:40px;'+
        ' background-position:-116px 0;'+
        '}';

        Css +=
        '#container a.barcode {'+
        ' display:block;'+
        ' margin-bottom:2px;'+
        '}';

        Css +=
        '#container .photo-holder {'+
        ' margin:0 auto 30px;'+
        '}';

        Css +=
        '#container .photo-holder img {'+
        ' width:173px;'+
        ' height:196px;'+
        ' border:3px solid #005191;'+
        '}';


        Css +=
        '#container a.camera {'+
        ' background:url(https://navipartner.test.navipartner.dk/self-service-kiosk/images/sprite.png) no-repeat;'+
        ' width:87px;'+
        ' height:63px;'+
        ' background-position:-293px -14px;'+
        ' display:block;'+
        ' margin:0 auto 40px;'+
        '}'+
        '@media only screen and (max-height:899px) {'+
        ' #container a.camera {'+
        ' margin:0 auto 20px;'+
        ' }'+
        '}';

        Css +=
        '#container .preview-card-holder {'+
        ' width:430px;'+
        ' background:#f2f2f2;'+
        ' margin:60px auto 50px;'+
        ' padding:30px;'+
        ' overflow:hidden;'+
        ' box-shadow:0 0 30px #999;'+
        '}'+
        '@media only screen and (max-height:899px) {'+
        ' #container .preview-card-holder {'+
        ' margin:40px auto 30px;'+
        ' }'+
        '}';

        Css +=
        '#container .preview-card-holder .left {'+
        ' float:left;'+
        ' margin-right:30px;'+
        '}';

        Css +=
        '#container .preview-card-holder .left img {'+
        ' border:4px solid #005191;'+
        '}';

        Css +=
        '#container .preview-card-holder .right {'+
        ' float:left;'+
        ' text-align:left;'+
        ' background:url(https://navipartner.test.navipartner.dk/self-service-kiosk/images/transparent-logo.png) no-repeat center center;'+
        '}';

        Css +=
        '#container .preview-card-holder .right .name, #container .preview-card-holder .right .date, #container .preview-card-holder .right .card-no {'+
        ' font-size:20px;'+
        ' font-weight:bold;'+
        ' text-transform:uppercase;'+
        ' padding-bottom:10px;'+
        '}';

        Css +=
        '#container .preview-card-holder .right .card-code {'+
        ' width:155px;'+
        ' margin-top:30px;'+
        '}';
    end;

    local procedure LoaderCss(var Css: Text)
    begin

        Css +=
        '@keyframes u52b1nc1g {'+
        '0% {box-shadow: -60px 40px 0 2px #000000, -30px 40px 0 0 #cccccc, 0px 40px 0 0 #cccccc, 30px 40px 0 0 #cccccc, 60px 40px 0 0 #cccccc;}'+
        '25% {box-shadow: -60px 40px 0 0 #cccccc, -30px 40px 0 2px #000000, 0px 40px 0 0 #cccccc, 30px 40px 0 0 #cccccc, 60px 40px 0 0 #cccccc;}'+
        '50% {box-shadow: -60px 40px 0 0 #cccccc, -30px 40px 0 0 #cccccc, 0px 40px 0 2px #000000, 30px 40px 0 0 #cccccc, 60px 40px 0 0 #cccccc;}'+
        '75% {box-shadow: -60px 40px 0 0 #cccccc, -30px 40px 0 0 #cccccc, 0px 40px 0 0 #cccccc, 30px 40px 0 2px #000000, 60px 40px 0 0 #cccccc;}'+
        '100% {box-shadow: -60px 40px 0 0 #cccccc, -30px 40px 0 0 #cccccc, 0px 40px 0 0 #cccccc, 30px 40px 0 0 #cccccc, 60px 40px 0 2px #000000;}'+
        '}';

        Css +=
        '.loader12 {\'+
        'width:20px;'+
        'height:20px;'+
        'border-radius:50%;'+
        'position:relative;'+
        'animation:u52b1nc1g 1s linear alternate infinite;'+
        'top: 50%;'+
        'margin:-50px auto 0;'+
        'margin-top:0;'+
        '}';
    end;
}

