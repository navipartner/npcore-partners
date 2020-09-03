page 6151128 "NPR NpIa ItemAddOn Line Opt."
{
    // NPR5.48/JAVA/20190205  CASE 334922 Transport NPR5.48 - 5 February 2019
    // NPR5.52/ALPO/20190912  CASE 354309 Possibility to fix the quantity so user would not be able to change it on sale line
    //                                    Possibility to predefine unit price and line discount % for Item AddOn entries set as select options
    //                                    Set whether or not specified quantity is per unit of main item
    //                                    (new controls: "Fixed Quantity", "Unit Price", "Discount %", "Per Unit")
    // NPR5.55/ALPO/20200506  CASE 402585 Define whether "Unit Price" should always be applied or only when it is not equal 0

    AutoSplitKey = true;
    Caption = 'Item AddOn Line Options';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR NpIa ItemAddOn Line Opt.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Per Unit"; "Per Unit")
                {
                    ApplicationArea = All;
                }
                field("Fixed Quantity"; "Fixed Quantity")
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Use Unit Price"; "Use Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Discount %"; "Discount %")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

