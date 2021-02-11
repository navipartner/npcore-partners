pageextension 6014455 "NPR Salesperson/Purchaser Card" extends "Salesperson/Purchaser Card"
{
    // NPR5.29/TJ  /20170123 CASE 263484 Copies tab Security and action CashCodes from page 6014428
    // NPR5.38/AE  /20180113 CASE 289390 Added filed Supervisor POS
    // NPR5.53/BHR /20191111 CASE 369354 Removed foeld Customer Creation
    layout
    {
        addafter(Invoicing)
        {
            group("NPR Security")
            {
                Caption = 'Security';
                field("NPR Register Password"; "NPR Register Password")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the NPR Register Password field';
                }
                field("NPR Supervisor POS"; "NPR Supervisor POS")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Supervisor POS field';
                }
                field("NPR Reverse Sales Ticket"; "NPR Reverse Sales Ticket")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Reverse Sales Ticket field';
                }
                field("NPR Locked-to Register No."; "NPR Locked-to Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Locked-to Register No. field';
                }
            }
        }
    }
}

