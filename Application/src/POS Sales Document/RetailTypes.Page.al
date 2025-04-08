page 6185040 "NPR Retail Types"
{
    Extensible = False;
    Caption = 'Sales Document Retail Types';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Retail Type";
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Retail Type"; Rec."Retail Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the retail type.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the description of the retail type.';
                }
            }
        }
    }
}
