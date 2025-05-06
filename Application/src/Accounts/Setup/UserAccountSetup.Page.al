page 6185049 "NPR UserAccountSetup"
{
    Extensible = false;
    Caption = 'User Account Setup';
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    SourceTable = "NPR UserAccountSetup";
    PageType = Card;

    layout
    {
        area(Content)
        {
            group(Uniqueness)
            {
                field(RequireUniquePhoneNo; Rec.RequireUniquePhoneNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the module should require phone numbers to be unique.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if (not Rec.Get()) then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}