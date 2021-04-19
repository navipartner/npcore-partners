page 6014441 "NPR Nc Show Html"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            usercontrol("HtmlViewController"; "NPR HtmlViewerControl")
            {
                ApplicationArea = All;
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