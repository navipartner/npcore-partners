page 6014548 "NPR POS Accessory AddOn Slct."
{
    // NPR5.44/MHA /20180309  CASE 286547 Object created - Accessory AddOn

    Caption = 'Item AddOns';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            usercontrol(Bridge; "NPR Bridge")
            {
                ApplicationArea = All;

                trigger OnFrameworkReady()
                var
                    Html: Text;
                    Css: Text;
                    Script: Text;
                begin
                    Css := InitCss();
                    Html := InitHtml();
                    Script := InitScript();
                    BridgeMgt.Initialize(CurrPage.Bridge);
                    BridgeMgt.RegisterAdHocModule('AccessoryAddOn', Html, Css, Script);
                    BridgeMgt.SetSize('100%', '600px');
                end;

                trigger OnInvokeMethod(method: Text; eventContent: JsonObject)
                begin
                    case method of
                        'ApproveItemAddOns':
                            ApproveItemAddOns(Format(eventContent));
                        'CancelItemAddOns':
                            CancelItemAddOns();
                    end;
                end;
            }
        }
    }

    actions
    {
    }

    var
        BridgeMgt: Codeunit "NPR JavaScript Bridge Mgt.";
        Text000: Label 'Cancel';
        Text001: Label 'Approve';

    local procedure InitCss() Css: Text
    begin
        Css :=
        'body, h1, h2, h3, h4, ul, li {' +
        ' padding: 0;' +
        ' margin: 0;' +
        ' font-family: Calibri;' +
        '}' +

        'li {' +
        ' list-style: none;' +
        '}' +

        'h2 {' +
        ' margin-bottom: 20px;' +
        '}' +

        '#itemAddOns {' +
        ' width: 400px;' +
        ' margin: 0 auto;' +
        ' border: 2px solid #000;' +
        ' padding: 30px;' +
        '}' +

        '#options {' +
          'border: 1px solid #000;' +
          'margin-bottom: 20px;' +
        '}' +

        '#options li {' +
          'display: flex;' +
          'justify-content: space-between;' +
          'border-bottom: 1px solid #000;' +
        '}' +

        '#options li:hover {' +
          'background: #ddd;' +
        '}' +

        '#options li:last-child {' +
          'border: none;' +
        '}' +

        '#options li div {' +
          'flex: 1 1 15%;' +
          'display: flex;' +
          'justify-content: space-between;' +
          'padding: 10px 20px;' +
          'text-overflow: ellipsis;' +
          'overflow: hidden;' +
          'white-space: nowrap;' +
        '}' +

        '#options li div a {' +
          'text-decoration: none;' +
          'font-weight: bold;' +
          'color: #000;' +
        '}' +

        '#options li div:first-child {' +
          'border-right: 1px solid #000;' +
          'flex: 1 1 85%;' +
          'display: block;' +
          'padding: 10px;' +
        '}' +

        '#buttons-set {' +
          'text-align: center;' +
        '}' +

        'button {' +
          'background: #000;' +
          'color: #fff;' +
          'padding: 10px 15px;' +
          'border: 1px solid #000;' +
          'margin-right: 10px;' +
          'font-weight: bold;' +
          'position: relative;' +
        '}' +

        'button:hover {' +
          'background: #fff;' +
          'color: #000;' +
          'cursor: pointer;' +
        '}' +

        'button:active {' +
          'top: 1px;' +
          'left: 1px;' +
        '}';

        exit(Css);
    end;

    local procedure InitHtml() Html: Text
    begin
        Html :=
          '<!doctype html>' +
          '<html lang="en">' +
          '<head>' +
            '<meta charset="utf-8">' +
            '<title>Product configuration</title>' +
              '<meta name="description" content="UI test">' +
              '<meta name="author" content="Vlad">' +
            '</head>' +
            '<body>' +
            '<div id="itemAddOns">' +
              '<h2>Burger Menu</h2>' +
              '<ul id="options">' +
                InitHtmlOption('10000', 'Ekstra Bof (10kr)') +
                InitHtmlOption('20000', 'Ost (5kr)') +
                InitHtmlOption('30000', 'Bacon (5kr)') +
                InitHtmlOption('40000', 'Ingen tomat') +
                InitHtmlOption('50000', 'Ingen agurk') +
               InitHtmlOption('60000', 'Test') +
              '</ul>' +
              '<div id="buttons-set">' +
                '<button onclick="cancelItemAddOn()">' +
                  '<span>' + Text000 + '</span>' +
                '</button>' +
                '<button onclick="approveItemAddOn()">' +
                  '<span>' + Text001 + '</span>' +
                '</button>' +
              '</div>' +
            '</div>' +
          '</body>' +
        '</html>';
        exit(Html);
    end;

    local procedure InitHtmlOption(AddOnId: Text; AddOnName: Text) Html: Text
    begin
        Html :=
        '<li id="' + AddOnId + '">' +
          '<div>' +
            '<span>' + AddOnName + '</span>' +
          '</div>' +
          '<div>' +
            '<a class="sub" href="#" onclick="decrementAddOn(\''' + AddOnId + '\'')">-</a>' +
            '<qty>0</qty>' +
            '<a class="add" href="#" onclick="incrementAddOn(\''' + AddOnId + '\'')">+</a>' +
          '</div>' +
        '</li>';

        exit(Html);
    end;

    local procedure InitScript() Script: Text
    begin
        Script :=
          InitScriptApprove() +
          InitScriptCancel() +
          InitScriptDecrement() +
          InitScriptIncremement();
        exit(Script);
    end;

    local procedure InitScriptApprove() Script: Text
    begin
        Script :=
            'window.approveItemAddOn = function() {' +
              'var nodeList = document.getElementById("options").getElementsByTagName("li");' +
              'var result = {addOns:{}};' +
              'var i;' +
              'for (i = 0; i < nodeList.length; i++) {' +
                'var addOnName = nodeList[i].id;' +
                'var qty = nodeList[i].getElementsByTagName("qty")[0].innerHTML;' +
                'result.addOns[addOnName] = qty;' +
              '}' +
              'var approveItemAddOnsMethod = new n$.Event.Method("ApproveItemAddOns");' +
              'approveItemAddOnsMethod.raise(result);' +
            '};';

        exit(Script);
    end;

    local procedure InitScriptCancel() Script: Text
    begin
        Script :=
            'window.cancelItemAddOn = function() {' +
              'var cancelItemAddOnsMethod = new n$.Event.Method("CancelItemAddOns"); ' +
              'cancelItemAddOnsMethod.raise();' +
            '};';

        exit(Script);
    end;

    local procedure InitScriptDecrement() Script: Text
    begin
        Script :=
            'window.decrementAddOn = function(addOnId) {' +
              'var qty = document.getElementById(addOnId).getElementsByTagName("qty")[0].innerHTML;' +
              'qty--;' +
              'if (qty < 0) {' +
                'qty = 0;' +
              '}' +
              'document.getElementById(addOnId).getElementsByTagName("qty")[0].innerHTML = qty;' +
            '};';

        exit(Script);
    end;

    local procedure InitScriptIncremement() Script: Text
    begin
        Script :=
            'window.incrementAddOn = function(addOnId) {' +
              'var qty = document.getElementById(addOnId).getElementsByTagName("qty")[0].innerHTML;' +
              'qty++;' +
              'document.getElementById(addOnId).getElementsByTagName("qty")[0].innerHTML = qty;' +
            '};';

        exit(Script);
    end;

    procedure ApproveItemAddOns(ItemAddOns: Text)
    begin
        Message(ItemAddOns);
        CurrPage.Close;
    end;

    local procedure CancelItemAddOns()
    begin
        CurrPage.Close;
    end;
}

