page 6014441 "NPR Nc Show Html"
{
    Extensible = False;
    PageType = Card;
    UsageCategory = Administration;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ApplicationArea = NPRNaviConnect;
    Caption = 'Nc Show Html';

    layout
    {
        area(Content)
        {
            usercontrol("HtmlViewController"; "NPR HtmlViewerControl")
            {
                ApplicationArea = NPRNaviConnect;

                trigger Ready()
                begin
                    CurrPage.HtmlViewController.XSLT(xslt, xml);
                end;
            }
        }
    }

    var
        xml: text;
        xslt: text;

    procedure SetData(_xslt: Text; _xml: Text)
    begin
        xml := _xml;
        xslt := _xslt;
    end;

}
