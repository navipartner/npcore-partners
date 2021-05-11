page 6150643 "NPR POS Info Links"
{
    Caption = 'POS Info Links';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Info Link Table";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'Group';
                field("POS Info Code"; Rec."POS Info Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Info Code field';

                    trigger OnValidate()
                    begin
                        Rec.CalcFields("POS Info Description");
                    end;
                }
                field("POS Info Description"; Rec."POS Info Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Info Description field';
                }
            }
        }
    }
}
