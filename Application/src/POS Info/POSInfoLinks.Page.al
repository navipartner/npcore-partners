page 6150643 "NPR POS Info Links"
{
    Caption = 'POS Info Links';
    PageType = List;
    UsageCategory = None;
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
                field("When to Use"; Rec."When to Use")
                {
                    ToolTip = 'Specifies when the POS Info Code is to be applied. The setting will work only with customers. Selecting Negative or Positive option will result in the POS Info Code to be taken into account only if customer balance is of the same sign';
                    ApplicationArea = All;
                    Visible = IsCustomerTable;
                }
            }
        }
    }
    var
        IsCustomerTable: Boolean;

    trigger OnOpenPage()
    begin
        IsCustomerTable := Rec."Table ID" = Database::Customer;
    end;
}
