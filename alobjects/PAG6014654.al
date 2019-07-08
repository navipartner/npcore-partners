page 6014654 "POS Web Font Preview"
{
    // NPR4.14/VB/20150930 CASE 224166 Created the page to allow users to preview a web font and see all icons inside
    // NPR4.15/VB/20150930 CASE 224237 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR9   /VB/20150104 CASE 225607 Changed references for compiling under NAV 2016
    // NPR5.00/VB/20160106 CASE 231100 Update .NET version from 1.9.1.305 to 1.9.1.369
    // NPR5.00.03/VB/20160106 CASE 231100 Update .NET version from 1.9.1.369 to 5.0.398.0

    Caption = 'POS Web Font Preview';
    Editable = false;
    SourceTable = "POS Web Font";

    layout
    {
        area(content)
        {
            field(SelectedIcon;SelectedIcon)
            {
                Caption = 'Selected Icon';
                Editable = false;
            }
            field(Control6150614;'')
            {
                ShowCaption = false;
            }
            usercontrol(Host;"NaviPartner.Retail.Controls.IFramework")
            {

                trigger OnFrameworkReady()
                begin
                    FrameworkReady();
                end;

                trigger OnScreenSize(screen: DotNet Screen)
                begin
                end;

                trigger OnMessage(eventArgs: DotNet MessageEventArgs)
                begin
                    SelectedIcon := eventArgs.ToEanCodeScanned().Ean;
                end;

                trigger OnResponse(response: DotNet ResponseInfo)
                begin
                end;

                trigger OnJavaScriptCallback(js: DotNet JavaScript)
                begin
                end;

                trigger OnDialogResponse(response: DotNet Response)
                begin
                end;

                trigger OnDataUpdated(dataSource: DotNet DataSource)
                begin
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        ShowFont();
    end;

    var
        IsFrameworkReady: Boolean;
        LastCode: Code[10];
        SelectedIcon: Text;

    local procedure ShowFont()
    var
        Font: DotNet Font;
        Factory: DotNet MarshalEventArgsFactory;
    begin
        if not IsFrameworkReady then
          exit;

        if LastCode = Code then
          exit;

        LastCode := Code;

        GetFontDotNet_Obsolete(Font);
        CurrPage.Host.SendRequest(Factory.ConfigureFont(Font).ToRequestInfo());
        CurrPage.Host.Execute(StrSubstNo('n$.Framework.PreviewFont && typeof n$.Framework.PreviewFont === "function" && n$.Framework.PreviewFont("%1");',Font.Code));
    end;

    local procedure FrameworkReady()
    begin
        IsFrameworkReady := true;
        ShowFont();
    end;

    procedure GetSelectedIcon(): Text
    begin
        exit(SelectedIcon);
    end;

    procedure GetIconClass(IconClass: Text): Text
    var
        POSWebFont: Record "POS Web Font";
        FontPreview: Page "POS Web Font Preview";
        "Code": Code[10];
    begin
        if IconClass <> '' then begin
          if not POSWebFont.Get(CopyStr(IconClass,1,StrPos(IconClass,'-') - 1)) then
            if not POSWebFont.FindFirst() then
              exit;
        end else
          if not POSWebFont.FindFirst() then
            exit;

        FontPreview.SetTableView(POSWebFont);
        FontPreview.SetRecord(POSWebFont);
        FontPreview.LookupMode := true;
        if FontPreview.RunModal = ACTION::LookupOK then begin
          exit(FontPreview.GetSelectedIcon());
        end else
          exit('');
    end;
}

