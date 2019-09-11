page 6014452 "Mixed Discount List"
{
    // NPR4.14/TS  /20150818  CASE 220970 Action Card removed from Actions
    // NPR5.29/TJ  /20170123  CASE 263787 Commented out code under action Dimensions-Multiple and set Visible property to FALSE
    // NPR5.31/MHA /20170110  CASE 262904 Added field 100 "Mix Type"
    // NPR5.51/SARA/20190826  CASE 365799 Able to delete more than one lines at a time

    Caption = 'Mix Discount List';
    CardPageID = "Mixed Discount";
    Editable = true;
    InsertAllowed = false;
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
                    Editable = false;
                }
                field(Status;Status)
                {
                    Editable = false;
                }
                field(Description;Description)
                {
                    Editable = false;
                }
                field("Mix Type";"Mix Type")
                {
                    Editable = false;
                }
                field("Min. Quantity";"Min. Quantity")
                {
                    BlankZero = true;
                    Editable = false;
                }
                field("Discount Type";"Discount Type")
                {
                    Editable = false;
                }
                field("Total Amount";"Total Amount")
                {
                    BlankZero = true;
                    Editable = false;
                }
                field("Total Discount %";"Total Discount %")
                {
                    BlankZero = true;
                    Editable = false;
                }
                field("Total Discount Amount";"Total Discount Amount")
                {
                    BlankZero = true;
                    Editable = false;
                }
                field("Starting date";"Starting date")
                {
                    Editable = false;
                }
                field("Starting time";"Starting time")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Ending date";"Ending date")
                {
                    Editable = false;
                }
                field("Ending time";"Ending time")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Created the";"Created the")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Last Date Modified";"Last Date Modified")
                {
                    Editable = false;
                    Visible = false;
                }
                field(Lot;Lot)
                {
                    Editable = false;
                }
                field("Unit price incl VAT";"Unit price incl VAT")
                {
                    Editable = false;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

