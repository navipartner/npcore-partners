pageextension 6014455 pageextension6014455 extends "Salesperson/Purchaser Card"
{
    // NPR5.29/TJ  /20170123 CASE 263484 Copies tab Security and action CashCodes from page 6014428
    // NPR5.38/AE  /20180113 CASE 289390 Added filed Supervisor POS
    // NPR5.53/BHR /20191111 CASE 369354 Removed foeld Customer Creation
    layout
    {
        addafter(Invoicing)
        {
            group(Security)
            {
                Caption = 'Security';
                field("Register Password"; "Register Password")
                {
                    ApplicationArea = All;
                }
                field("Supervisor POS"; "Supervisor POS")
                {
                    ApplicationArea = All;
                }
                field("Reverse Sales Ticket"; "Reverse Sales Ticket")
                {
                    ApplicationArea = All;
                }
                field("Locked-to Register No."; "Locked-to Register No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        addafter("Create &Interaction")
        {
            action(CashCodes)
            {
                Caption = 'Cash Codes';
                Image = "Action";
                RunObject = Page "Alternative Number";
                RunPageLink = Code = FIELD(Code),
                              Type = CONST(SalesPerson);
                RunPageView = SORTING(Type, Code, "Alt. No.");
                ShortCutKey = 'Ctrl+A';
            }
        }
    }
}

