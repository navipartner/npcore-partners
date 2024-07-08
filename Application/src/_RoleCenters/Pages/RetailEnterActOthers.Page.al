page 6151251 "NPR Retail Enter. Act: Others"
{
    Extensible = False;
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
                    ToolTip = 'Specifies the number of the items. By clicking you can drilldown to list of items.';
                    ApplicationArea = NPRRetail;
                }
                field(Contacts; Rec.Contacts)
                {
                    ToolTip = 'Specifies the number of the contacts. By clicking you can drilldown to list of contacts.';
                    ApplicationArea = NPRRetail;
                }
                field(Customers; Rec.Customers)
                {

                    ToolTip = 'Specifies the number of the customers. By clicking you can drilldown to list of customers.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}

