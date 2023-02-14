page 6059903 "NPR Custom Message Page"
{
    Extensible = False;
    PageType = Card;
    UsageCategory = None;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'Message';
    layout
    {
        area(Content)
        {
            usercontrol("Message Page"; "NPR Custom Message")
            {
                ApplicationArea = NPRRetail;

                trigger Ready()
                begin
                    CurrPage."Message Page".Init(_title, _message);
                end;

                trigger OKCliked()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    procedure ShowMessage(Title: Text; Message: Text)
    begin
        _title := Title;
        _message := Message;
        CurrPage.RunModal();
    end;

    var
        _title: Text;
        _message: Text;
}