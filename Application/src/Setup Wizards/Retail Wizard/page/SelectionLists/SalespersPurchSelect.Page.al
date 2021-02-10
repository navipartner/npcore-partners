page 6059800 "NPR Salespers/PurchSelect"
{
    Caption = 'Salespeople';
    PageType = List;
    SourceTable = "Salesperson/Purchaser";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code of the record.';
                }
                field(Name; Name)
                {
                    ApplicationArea = Suite, RelationshipMgmt;
                    ToolTip = 'Specifies the name of the record.';
                }
            }
        }
    }
}