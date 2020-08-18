page 6150738 "POS Setup List"
{
    // NPR5.54/TSA /20200407 CASE 391850 Initial Version
    // NPR5.55/TSA /20200422 CASE 400734 Added "Admin Menu Action Code"

    Caption = 'POS Setup List';
    CardPageID = "POS Setup";
    PageType = List;
    SourceTable = "POS Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Primary Key";"Primary Key")
                {
                }
                field(Description;Description)
                {
                }
                field("Login Action Code";"Login Action Code")
                {
                    Editable = false;
                }
                field("Text Enter Action Code";"Text Enter Action Code")
                {
                    Editable = false;
                }
                field("Item Insert Action Code";"Item Insert Action Code")
                {
                    Editable = false;
                }
                field("Payment Action Code";"Payment Action Code")
                {
                    Editable = false;
                }
                field("Customer Action Code";"Customer Action Code")
                {
                    Editable = false;
                }
                field("Lock POS Action Code";"Lock POS Action Code")
                {
                    Editable = false;
                }
                field("Unlock POS Action Code";"Unlock POS Action Code")
                {
                    Editable = false;
                }
                field("OnBeforePaymentView Action";"OnBeforePaymentView Action")
                {
                    Editable = false;
                }
                field("Admin Menu Action Code";"Admin Menu Action Code")
                {
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }
}

