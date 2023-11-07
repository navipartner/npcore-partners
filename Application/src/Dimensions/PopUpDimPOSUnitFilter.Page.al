page 6151299 "NPR Pop Up Dim POS Unit Filter"
{
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Pop Up Dim POS Unit Filter";
    Caption = 'Pop Up Dim POS Unit Filter';
    Extensible = False;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Name; Rec."POS Unit")
                {
                    ToolTip = 'Specifies the value of the POS Unit field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Unit Name"; Rec."POS Unit Name")
                {
                    ToolTip = 'Specifies the value of the POS Unit Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Enable; Rec.Enable)
                {
                    ToolTip = 'Specifies the value of the Enable Dimension Popup field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}