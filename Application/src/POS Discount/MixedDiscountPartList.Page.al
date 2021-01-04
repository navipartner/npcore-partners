page 6014447 "NPR Mixed Discount Part List"
{
    // NPR5.31/MHA /20170110  CASE 262904 Object created

    Caption = 'Mixed Discount Combination Parts';
    CardPageID = "NPR Mixed Discount";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
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
                    ToolTip = 'Specifies the value of the Mix No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Lot; Lot)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Lot field';
                }
                field("Min. Quantity"; "Min. Quantity")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    ToolTip = 'Specifies the value of the Min. Quantity field';
                }
                field("Max. Quantity"; "Max. Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max. Quantity field';
                }
                field("Created the"; "Created the")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Created Date field';
                }
                field("Last Date Modified"; "Last Date Modified")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Last Date Modified field';
                }
            }
        }
    }

    actions
    {
    }
}

