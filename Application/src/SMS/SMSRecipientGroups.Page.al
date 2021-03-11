page 6014429 "NPR SMS Recipient Groups"
{

    ApplicationArea = All;
    Caption = 'SMS Recipient Groups';
    PageType = List;
    SourceTable = "NPR SMS Recipient Group";
    UsageCategory = Administration;
    Editable = False;
    CardPageId = "NPR SMS Recipient Group";
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
