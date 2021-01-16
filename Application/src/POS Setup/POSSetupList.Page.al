page 6150738 "NPR POS Setup List"
{
    // NPR5.54/TSA /20200407 CASE 391850 Initial Version
    // NPR5.55/TSA /20200422 CASE 400734 Added "Admin Menu Action Code"

    Caption = 'POS Setup List';
    CardPageID = "NPR POS Setup";
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Primary Key field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Login Action Code"; "Login Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Login Action Code field';
                }
                field("Text Enter Action Code"; "Text Enter Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Text Enter Action Code field';
                }
                field("Item Insert Action Code"; "Item Insert Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Item Insert Action Code field';
                }
                field("Payment Action Code"; "Payment Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Payment Action Code field';
                }
                field("Customer Action Code"; "Customer Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Customer Action Code field';
                }
                field("Lock POS Action Code"; "Lock POS Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Lock POS Action Code field';
                }
                field("Unlock POS Action Code"; "Unlock POS Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Unlock POS Action Code field';
                }
                field("OnBeforePaymentView Action"; "OnBeforePaymentView Action")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the On Before Payment View Action Code field';
                }
                field("Admin Menu Action Code"; "Admin Menu Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Admin Menu Action Code field';
                }
            }
        }
    }

    actions
    {
    }
}

