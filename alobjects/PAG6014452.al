page 6014452 "Mixed Discount List"
{
    // NPR4.14/TS  /20150818  CASE 220970 Action Card removed from Actions
    // NPR5.29/TJ  /20170123  CASE 263787 Commented out code under action Dimensions-Multiple and set Visible property to FALSE
    // NPR5.31/MHA /20170110  CASE 262904 Added field 100 "Mix Type"

    Caption = 'Mix Discount List';
    CardPageID = "Mixed Discount";
    Editable = false;
    PageType = List;
    SourceTable = "Mixed Discount";
    SourceTableView = SORTING("Starting date","Starting time","Ending date","Ending time")
                      WHERE("Mix Type"=FILTER(Standard|Combination));
    UsageCategory = Lists;

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
                field(Status;Status)
                {
                }
                field(Description;Description)
                {
                }
                field("Mix Type";"Mix Type")
                {
                }
                field("Min. Quantity";"Min. Quantity")
                {
                    BlankZero = true;
                }
                field("Discount Type";"Discount Type")
                {
                }
                field("Total Amount";"Total Amount")
                {
                    BlankZero = true;
                }
                field("Total Discount %";"Total Discount %")
                {
                    BlankZero = true;
                }
                field("Total Discount Amount";"Total Discount Amount")
                {
                    BlankZero = true;
                }
                field("Starting date";"Starting date")
                {
                }
                field("Starting time";"Starting time")
                {
                    Visible = false;
                }
                field("Ending date";"Ending date")
                {
                }
                field("Ending time";"Ending time")
                {
                    Visible = false;
                }
                field("Created the";"Created the")
                {
                    Visible = false;
                }
                field("Last Date Modified";"Last Date Modified")
                {
                    Visible = false;
                }
                field(Lot;Lot)
                {
                }
                field("Unit price incl VAT";"Unit price incl VAT")
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

