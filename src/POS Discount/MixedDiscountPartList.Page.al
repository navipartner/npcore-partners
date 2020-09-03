page 6014447 "NPR Mixed Discount Part List"
{
    // NPR5.31/MHA /20170110  CASE 262904 Object created

    Caption = 'Mixed Discount Combination Parts';
    CardPageID = "NPR Mixed Discount";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Mixed Discount";
    SourceTableView = SORTING("Starting date", "Starting time", "Ending date", "Ending time")
                      WHERE("Mix Type" = CONST("Combination Part"));

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    Caption = 'Mix No.';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Lot; Lot)
                {
                    ApplicationArea = All;
                }
                field("Min. Quantity"; "Min. Quantity")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field("Max. Quantity"; "Max. Quantity")
                {
                    ApplicationArea = All;
                }
                field("Created the"; "Created the")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Last Date Modified"; "Last Date Modified")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

