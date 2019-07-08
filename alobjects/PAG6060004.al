page 6060004 "GIM - Setup"
{
    Caption = 'GIM - Setup';
    PageType = Card;
    SourceTable = "GIM - Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Import Document Nos.";"Import Document Nos.")
                {
                }
            }
            group(Notification)
            {
                field("Sender E-mail";"Sender E-mail")
                {
                    Visible = false;
                }
                field("Mailing Templates";"Mailing Templates")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        if not Get then
          Insert;
    end;
}

