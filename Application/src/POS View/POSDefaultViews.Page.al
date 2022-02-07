page 6150712 "NPR POS Default Views"
{
    Extensible = False;
    Caption = 'POS Default Views';
    PageType = List;
    SourceTable = "NPR POS Default View";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                    ToolTip = 'It defines the type for which the POS view is applicable. The Values are Login, Sale, Payment, Balance, Locked, Restaurant';
                    ApplicationArea = NPRRetail;
                }
                field("Register Filter"; Rec."Register Filter")
                {
                    ToolTip = 'Specifies any filter by POS Unit';
                    ApplicationArea = NPRRetail;
                }
                field("POS View Code"; Rec."POS View Code")
                {
                    ToolTip = 'Specifies the POS View Code to be used';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
