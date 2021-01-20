page 6151251 "NPR Retail Enter. Act: Others"
{
    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NPR Retail Entertainment Cue";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            cuegroup("Master Data")
            {
                Caption = 'Master Data';
                field(Items; Rec.Items)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Items field';
                }
                field(Contacts; Rec.Contacts)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contacts field';
                }
                field(Customers; Rec.Customers)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customers field';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset;
        if not Rec.Get then begin
            Rec.Init;
            Rec.Insert;
        end;
    end;
}

