page 6014452 "NPR Mixed Discount List"
{
    Caption = 'Mix Discount List';
    CardPageID = "NPR Mixed Discount";
    Editable = true;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Mixed Discount";
    SourceTableView = SORTING("Starting date", "Starting time", "Ending date", "Ending time")
                      WHERE("Mix Type" = FILTER(Standard | Combination));
    UsageCategory = Lists;
    ApplicationArea = All;

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
                    Editable = false;
                    ToolTip = 'Specifies the value of the Mix No. field';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Mix Type"; Rec."Mix Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Mix Type field';
                }
                field("Min. Quantity"; Rec."Min. Quantity")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Min. Quantity field';
                }
                field("Discount Type"; Rec."Discount Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Discount Type field';
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Total Amount field';
                }
                field("Total Discount %"; Rec."Total Discount %")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Total Discount % field';
                }
                field("Total Discount Amount"; Rec."Total Discount Amount")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Total Discount Amount field';
                }
                field("Starting date"; Rec."Starting date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Start Date field';
                }
                field("Starting time"; Rec."Starting time")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Start Time field';
                }
                field("Ending date"; Rec."Ending date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the End Date field';
                }
                field("Ending time"; Rec."Ending time")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the End Time field';
                }
                field("Created the"; Rec."Created the")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Created Date field';
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Last Date Modified field';
                }
                field(Lot; Rec.Lot)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Lot field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Dimensions action';

                trigger OnAction()
                begin
                end;
            }
        }
    }
}

