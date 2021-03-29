page 6150751 "NPR POS Default User Views"
{
    Caption = 'POS Default User Views';
    PageType = List;
    SourceTable = "NPR POS Default User View";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Register No."; Rec."Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("User Name"; Rec."User Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User Name field';
                }
                field("POS View Code"; Rec."POS View Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS View Code field';
                }
            }
        }
    }
}