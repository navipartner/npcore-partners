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

                    ExtendedDatatype = Masked;
                    ToolTip = 'Enable defining a password for accessing a POS unit.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Supervisor POS"; Rec."NPR Supervisor POS")
                {

                    ToolTip = 'Enable specifying if the salesperson will be tagged as the Supervisor.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Locked-to Register No."; Rec."NPR Locked-to Register No.")
                {

                    ToolTip = 'Enable assigning the salesperson to a specific POS unit.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}