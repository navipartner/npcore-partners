page 6151406 "NPR Magento Stores"
{
    Caption = 'Stores';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Magento Store";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Language Code"; Rec."Language Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Language Code field';
                }
            }
        }
    }
}