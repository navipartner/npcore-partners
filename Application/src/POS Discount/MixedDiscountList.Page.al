page 6014452 "NPR Mixed Discount List"
{
    Extensible = False;
    Caption = 'Mix Discount List';
    ContextSensitiveHelpPage = 'docs/retail/discounts/how-to/create_mix_discount/';
    CardPageID = "NPR Mixed Discount";
    Editable = true;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Mixed Discount";
    SourceTableView = sorting("Starting date", "Starting time", "Ending date", "Ending time")
                      where("Mix Type" = filter(Standard | Combination));
    UsageCategory = Lists;
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
                    Editable = false;
                    ToolTip = 'Specifies the unique number of the mix discount';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    Editable = false;
                    ToolTip = 'Specifies the status of the mix discount';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    Editable = false;
                    ToolTip = 'Specifies the name of the mix discount';
                    ApplicationArea = NPRRetail;
                }
                field("Mix Type"; Rec."Mix Type")
                {

                    Editable = false;
                    ToolTip = 'Specifies the type of the mix discount';
                    ApplicationArea = NPRRetail;
                }
                field("Min. Quantity"; Rec."Min. Quantity")
                {

                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the minimum quantity of the mix discount';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Type"; Rec."Discount Type")
                {

                    Editable = false;
                    ToolTip = 'Specifies the discount type of the mix discount.';
                    ApplicationArea = NPRRetail;
                }
                field("Total Amount"; Rec."Total Amount")
                {

                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the total amount of the mix discount.';
                    ApplicationArea = NPRRetail;
                }
                field("Total Discount %"; Rec."Total Discount %")
                {

                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the total discount amount of the mix discount.';
                    ApplicationArea = NPRRetail;
                }
                field("Total Discount Amount"; Rec."Total Discount Amount")
                {

                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the total discount amount of the mix discount';
                    ApplicationArea = NPRRetail;
                }
                field("Starting date"; Rec."Starting date")
                {

                    Editable = false;
                    ToolTip = 'Specifies the start date of the mix discount';
                    ApplicationArea = NPRRetail;
                }
                field("Starting time"; Rec."Starting time")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the start time of the mix discount';
                    ApplicationArea = NPRRetail;
                }
                field("Ending date"; Rec."Ending date")
                {

                    Editable = false;
                    ToolTip = 'Specifies the end date of the mix discount';
                    ApplicationArea = NPRRetail;
                }
                field("Ending time"; Rec."Ending time")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the end time of the mix discount.';
                    ApplicationArea = NPRRetail;
                }
                field("Created the"; Rec."Created the")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the date on which the mix discount was created.';
                    ApplicationArea = NPRRetail;
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the last date on which the mix discount has been modified.';
                    ApplicationArea = NPRRetail;
                }
                field(Lot; Rec.Lot)
                {

                    Editable = false;
                    ToolTip = 'Specifies the lot of the mix discount';
                    ApplicationArea = NPRRetail;
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
                RunPageLink = "Table ID" = CONST(6014411),
                              "No." = FIELD(Code);
                ShortCutKey = 'Shift+Ctrl+D';

                ToolTip = 'Displays the dimensions of the selected mix discount. You can manage the dimensions for the selected mix discount';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

