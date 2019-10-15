pageextension 6014449 pageextension6014449 extends "Salesperson/Purchaser Card" 
{
    // NPR5.29/TJ  /20170123 CASE 263484 Copies tab Security and action CashCodes from page 6014428
    // NPR5.38/AE  /20180113 CASE 289390 Added filed Supervisor POS
    layout
    {
        addafter(Invoicing)
        {
            group(Security)
            {
                Caption = 'Security';
                field("Register Password";"Register Password")
                {
                }
                field("Supervisor POS";"Supervisor POS")
                {
                }
                field("Customer Creation";"Customer Creation")
                {
                }
                field("Reverse Sales Ticket";"Reverse Sales Ticket")
                {
                }
                field("Locked-to Register No.";"Locked-to Register No.")
                {
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
                RunPageLink = Code=FIELD(Code),
                              Type=CONST(SalesPerson);
                RunPageView = SORTING(Type,Code,"Alt. No.");
                ShortCutKey = 'Ctrl+A';
            }
        }
    }
}

