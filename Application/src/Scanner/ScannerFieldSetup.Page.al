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
                    ToolTip = 'Specifies the value of the Order field';
                }
                field(Prefix; Prefix)
                {
                    ApplicationArea = All;
                    Caption = 'Prefix';
                    ToolTip = 'Specifies the value of the Prefix field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field(Postfix; Postfix)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Postfix field';
                }
                field(Padding; Padding)
                {
                    ApplicationArea = All;
                    Caption = 'Padding';
                    ToolTip = 'Specifies the value of the Padding field';
                }
                field(Position; Position)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Position field';
                }
                field(Length; Length)
                {
                    ApplicationArea = All;
                    Caption = 'Length';
                    ToolTip = 'Specifies the value of the Length field';
                }
            }
        }
    }

    actions
    {
    }
}

