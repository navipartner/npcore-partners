page 6151406 "NPR Magento Stores"
{
    Extensible = False;
    Caption = 'Stores';
    Editable = false;
    PageType = List;
    UsageCategory = None;
    ObsoleteState = Pending;
    ObsoleteTag = 'NPR23.0';
    ObsoleteReason = 'Page ''NPR Magento Store List'' is used instead.';
    SourceTable = "NPR Magento Store";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Language Code"; Rec."Language Code")
                {

                    ToolTip = 'Specifies the value of the Language Code field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
