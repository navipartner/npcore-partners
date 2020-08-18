page 6014467 "Quantity Discount List"
{
    // NPR5.29/TJ  /20170123 CASE 263787 Commented out code under action Dimensions-Multiple and set Visible property to FALSE
    // NPR5.30/BHR /20170223 CASE 265244 Add field Item No.
    // NPR5.55/TJ  /20200421 CASE 400524 Removed Name from action Dimension-Single to default to page name
    //                                   Removed group Dimensions and unused action Dimensions-Multiple

    Caption = 'Quantity Discount List';
    CardPageID = "Quantity Discount Card";
    Editable = false;
    PageType = List;
    SourceTable = "Quantity Discount Header";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Main No.";"Main No.")
                {
                }
                field("Item No.";"Item No.")
                {
                }
                field(Description;Description)
                {
                }
                field("Starting Date";"Starting Date")
                {
                }
                field("Closing Date";"Closing Date")
                {
                }
                field(Status;Status)
                {
                }
                field("Global Dimension 1 Code";"Global Dimension 1 Code")
                {
                    Caption = 'Shortcut Dimension 1 Code';
                }
                field("Global Dimension 2 Code";"Global Dimension 2 Code")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Dimensions)
            {
                Caption = 'Dimensions';
                Image = Dimensions;
                RunObject = Page "Default Dimensions";
                RunPageLink = "Table ID"=CONST(6014439),
                              "No."=FIELD("Main No.");
                ShortCutKey = 'Shift+Ctrl+D';
            }
        }
    }
}

