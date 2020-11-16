page 6014536 "NPR Scanner: Field Setup"
{
    Caption = 'Scanner - Field Setup';
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR Scanner: Field Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Order; Order)
                {
                    ApplicationArea = All;
                }
                field(Prefix; Prefix)
                {
                    ApplicationArea = All;
                    Caption = 'Prefix';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field(Postfix; Postfix)
                {
                    ApplicationArea = All;
                }
                field(Padding; Padding)
                {
                    ApplicationArea = All;
                    Caption = 'Padding';
                }
                field(Position; Position)
                {
                    ApplicationArea = All;
                }
                field(Length; Length)
                {
                    ApplicationArea = All;
                    Caption = 'Length';
                }
            }
        }
    }

    actions
    {
    }
}

