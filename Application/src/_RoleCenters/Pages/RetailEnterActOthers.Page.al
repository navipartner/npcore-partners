page 6151251 "NPR Retail Enter. Act: Others"
{
    // #343621/ZESO/20190725  CASE 343621 Object created.

    Caption = 'Activities';
    PageType = CardPart;
    UsageCategory = Administration;
    RefreshOnActivate = true;
    SourceTable = "NPR Retail Entertainment Cue";

    layout
    {
        area(content)
        {
            cuegroup("Master Data")
            {
                Caption = 'Master Data';
                field(Items; Items)
                {
                    ApplicationArea = All;
                }
                field(Contacts; Contacts)
                {
                    ApplicationArea = All;
                }
                field(Customers; Customers)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;
    end;
}

