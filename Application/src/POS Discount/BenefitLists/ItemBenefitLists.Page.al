page 6151093 "NPR Item Benefit Lists"
{
    Extensible = false;
    Caption = 'Item Benefit Lists';
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = Lists;
    SourceTable = "NPR Item Benefit List Header";
    CardPageId = "NPR Item Benefit List Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the code of the Item Benefit List.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the description of the Item Benefit List.';
                }
            }
        }
    }

}