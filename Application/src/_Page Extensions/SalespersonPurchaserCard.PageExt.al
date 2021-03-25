pageextension 6014455 "NPR Salesperson/Purchaser Card" extends "Salesperson/Purchaser Card"
{
    layout
    {
        addafter(Invoicing)
        {
            group("NPR Security")
            {
                Caption = 'Security';
                field("NPR Register Password"; Rec."NPR Register Password")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the NPR Register Password field';
                }
                field("NPR Supervisor POS"; Rec."NPR Supervisor POS")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Supervisor POS field';
                }
                field("NPR Locked-to Register No."; Rec."NPR Locked-to Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Locked-to Register No. field';
                }
            }
        }
    }
}