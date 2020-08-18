page 6151128 "NpIa Item AddOn Line Options"
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
    SourceTable = "NpIa Item AddOn Line Option";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No.";"Item No.")
                {
                }
                field("Variant Code";"Variant Code")
                {
                }
                field(Description;Description)
                {
                }
                field("Description 2";"Description 2")
                {
                }
                field(Quantity;Quantity)
                {
                }
                field("Per Unit";"Per Unit")
                {
                }
                field("Fixed Quantity";"Fixed Quantity")
                {
                }
                field("Unit Price";"Unit Price")
                {
                }
                field("Use Unit Price";"Use Unit Price")
                {
                }
                field("Discount %";"Discount %")
                {
                }
            }
        }
    }

    actions
    {
    }
}

