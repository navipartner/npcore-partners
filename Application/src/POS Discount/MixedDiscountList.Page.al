page 6014452 "NPR Mixed Discount List"
{
    Extensible = False;
    Caption = 'Mix Discount List';
    CardPageID = "NPR Mixed Discount";
    Editable = true;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Mixed Discount";
    SourceTableView = SORTING("Starting date", "Starting time", "Ending date", "Ending time")
                      WHERE("Mix Type" = FILTER(Standard | Combination));
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
                    ToolTip = 'Specifies the value of the Mix No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Mix Type"; Rec."Mix Type")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Mix Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Min. Quantity"; Rec."Min. Quantity")
                {

                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Min. Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Type"; Rec."Discount Type")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Discount Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Total Amount"; Rec."Total Amount")
                {

                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Total Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Total Discount %"; Rec."Total Discount %")
                {

                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Total Discount % field';
                    ApplicationArea = NPRRetail;
                }
                field("Total Discount Amount"; Rec."Total Discount Amount")
                {

                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Total Discount Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Starting date"; Rec."Starting date")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Start Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Starting time"; Rec."Starting time")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Start Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Ending date"; Rec."Ending date")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the End Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Ending time"; Rec."Ending time")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the End Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Created the"; Rec."Created the")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Created Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Last Date Modified field';
                    ApplicationArea = NPRRetail;
                }
                field(Lot; Rec.Lot)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Lot field';
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

                ToolTip = 'Executes the Dimensions action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                end;
            }
        }
    }
}

