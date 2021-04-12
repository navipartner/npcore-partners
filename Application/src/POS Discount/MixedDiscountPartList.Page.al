page 6014447 "NPR Mixed Discount Part List"
{
    // NPR5.31/MHA /20170110  CASE 262904 Object created

    Caption = 'Mixed Discount Combination Parts';
    CardPageID = "NPR Mixed Discount";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    Caption = 'Mix No.';
                    ToolTip = 'Specifies the value of the Mix No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Lot; Rec.Lot)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Lot field';
                }
                field("Min. Quantity"; Rec."Min. Quantity")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    ToolTip = 'Specifies the value of the Min. Quantity field';
                }
                field("Max. Quantity"; Rec."Max. Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max. Quantity field';
                }
                field("Created the"; Rec."Created the")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Created Date field';
                }
                field("Last Date Modified"; Rec."Last Date Modified")
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

