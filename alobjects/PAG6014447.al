page 6014447 "Mixed Discount Part List"
{
    // NPR5.31/MHA /20170110  CASE 262904 Object created

    Caption = 'Mixed Discount Combination Parts';
    CardPageID = "Mixed Discount";
    Editable = false;
    PageType = List;
    SourceTable = "Mixed Discount";
    SourceTableView = SORTING("Starting date","Starting time","Ending date","Ending time")
                      WHERE("Mix Type"=CONST("Combination Part"));

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code";Code)
                {
                    Caption = 'Mix No.';
                }
                field(Description;Description)
                {
                }
                field(Lot;Lot)
                {
                }
                field("Min. Quantity";"Min. Quantity")
                {
                    BlankZero = true;
                }
                field("Max. Quantity";"Max. Quantity")
                {
                }
                field("Created the";"Created the")
                {
                    Visible = false;
                }
                field("Last Date Modified";"Last Date Modified")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

