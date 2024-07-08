page 6014447 "NPR Mixed Discount Part List"
{
    Extensible = False;
    // NPR5.31/MHA /20170110  CASE 262904 Object created

    Caption = 'Mixed Discount Combination Parts';
    CardPageID = "NPR Mixed Discount";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Mixed Discount";
    SourceTableView = SORTING("Starting date", "Starting time", "Ending date", "Ending time")
                      WHERE("Mix Type" = CONST("Combination Part"));
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {

                    Caption = 'Mix No.';
                    ToolTip = 'Specifies the value of the Mix No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Lot; Rec.Lot)
                {

                    ToolTip = 'Specifies the value of the Lot field';
                    ApplicationArea = NPRRetail;
                }
                field("Min. Quantity"; Rec."Min. Quantity")
                {

                    BlankZero = true;
                    ToolTip = 'Specifies the value of the Min. Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Max. Quantity"; Rec."Max. Quantity")
                {

                    ToolTip = 'Specifies the value of the Max. Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Created the"; Rec."Created the")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Created Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Last Date Modified field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

