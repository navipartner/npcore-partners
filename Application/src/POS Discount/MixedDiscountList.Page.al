page 6014452 "NPR Mixed Discount List"
{
    // NPR4.14/TS  /20150818  CASE 220970 Action Card removed from Actions
    // NPR5.29/TJ  /20170123  CASE 263787 Commented out code under action Dimensions-Multiple and set Visible property to FALSE
    // NPR5.31/MHA /20170110  CASE 262904 Added field 100 "Mix Type"
    // NPR5.51/SARA/20190826  CASE 365799 Able to delete more than one lines at a time
    // NPR5.55/TJ  /20200421  CASE 400524 Added action Dimensions

    Caption = 'Mix Discount List';
    CardPageID = "NPR Mixed Discount";
    Editable = true;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Mixed Discount";
    SourceTableView = SORTING("Starting date", "Starting time", "Ending date", "Ending time")
                      WHERE("Mix Type" = FILTER(Standard | Combination));
    UsageCategory = Lists;

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
                    Editable = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Mix Type"; "Mix Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Min. Quantity"; "Min. Quantity")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Editable = false;
                }
                field("Discount Type"; "Discount Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Total Amount"; "Total Amount")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Editable = false;
                }
                field("Total Discount %"; "Total Discount %")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Editable = false;
                }
                field("Total Discount Amount"; "Total Discount Amount")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Editable = false;
                }
                field("Starting date"; "Starting date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Starting time"; "Starting time")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Ending date"; "Ending date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Ending time"; "Ending time")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Created the"; "Created the")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Last Date Modified"; "Last Date Modified")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field(Lot; Lot)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Unit price incl VAT"; "Unit price incl VAT")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
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

                trigger OnAction()
                var
                    DimMgt: Codeunit DimensionManagement;
                begin
                end;
            }
        }
    }
}

