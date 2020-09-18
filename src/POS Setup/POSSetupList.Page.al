page 6150738 "NPR POS Setup List"
{
    // NPR5.54/TSA /20200407 CASE 391850 Initial Version
    // NPR5.55/TSA /20200422 CASE 400734 Added "Admin Menu Action Code"

    Caption = 'POS Setup List';
    CardPageID = "NPR POS Setup";
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR POS Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Primary Key"; "Primary Key")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Login Action Code"; "Login Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Text Enter Action Code"; "Text Enter Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Item Insert Action Code"; "Item Insert Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Payment Action Code"; "Payment Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Customer Action Code"; "Customer Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Lock POS Action Code"; "Lock POS Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Unlock POS Action Code"; "Unlock POS Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("OnBeforePaymentView Action"; "OnBeforePaymentView Action")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Admin Menu Action Code"; "Admin Menu Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }
}

