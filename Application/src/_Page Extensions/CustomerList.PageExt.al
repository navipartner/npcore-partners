pageextension 6014492 "NPR Customer List" extends "Customer List"
{
    Editable = true;

    layout
    {
        addfirst(content)
        {
            //Smart search is removed but this field cannot be deleted because of the AppSource validation rules.
            field("NPR Search"; Rec."No.")
            {
                Visible = false;
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the customer''s No.';
            }
        }
        addafter("Sales (LCY)")
        {
            field("NPR Total Sales POS"; Rec."NPR Total Sales POS")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the total net amount of POS sales to the customer in LCY.';
            }
            field("NPR Total Sales"; Rec."NPR Total Sales POS" + Rec."Sales (LCY)")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Total Sales (LCY)';
                ToolTip = 'Specifies the sum of POS and backoffice (ERP) sales to the customer in LCY.';
            }
        }
        addlast(Control1)
        {
            field("NPR E-Mail"; Rec."E-Mail")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the customer''s e-mail address. Clicking on the e-mail address opens an e-mail application.';
            }
            field("NPR Mobile Phone No."; Rec."Mobile Phone No.")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the customer''s mobile phone no.';
            }
        }

        modify(Control1)
        {
            Editable = false;
        }
    }

    actions
    {
        addafter("Item &Tracking Entries")
        {
            action("NPR POS Entries")
            {
                Caption = 'POS Entries';
                Image = Entries;

                ToolTip = 'Executes the POS Entries action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSEntryNavigation: Codeunit "NPR POS Entry Navigation";
                begin
                    POSEntryNavigation.OpenPOSEntryListFromCustomer(Rec);
                end;
            }
        }
        addlast(History)
        {
            action("NPR Item Ledger Entries")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Item Ledger Entries';
                Image = ItemLedger;
                RunObject = Page "Item Ledger Entries";
                RunPageLink = "Source Type" = const(Customer),
                                "Source No." = field("No.");
                ToolTip = 'View item ledger entries for this customer.';
            }
        }
    }
}
