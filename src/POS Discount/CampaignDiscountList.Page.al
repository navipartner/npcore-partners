page 6014455 "NPR Campaign Discount List"
{
    // NPR4.14/TS/20150818 CASE 220971 Action Card removed from Actions
    // NPR5.29/TJ  /20170123 CASE 263787 Commented out code under action Dimensions-Multiple and set Visible property to FALSE
    // NPR5.42/MHA /20180521  CASE 315554 Added Period Fields to enable Weekly Condition
    // NPR5.51/SARA/20190826  CASE 365799 Able to delete more than one lines at a time
    // NPR5.55/TJ  /20200421  CASE 400524 Removed Name from Dimensions-Single action so it defaults to page name
    //                                    Removed group Dimensions and unused Dimensions-Multiple

    Caption = 'Period Discount List';
    CardPageID = "NPR Campaign Discount";
    Editable = true;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Period Discount";
    SourceTableView = SORTING("Starting Date", "Starting Time", "Ending Date", "Ending Time");
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
                    Editable = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Ending Date"; "Ending Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Period Type"; "Period Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Period Description"; "Period Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Created Date"; "Created Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Last Date Modified"; "Last Date Modified")
                {
                    ApplicationArea = All;
                    Editable = false;
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
                RunPageLink = "Table ID" = CONST(6014413),
                              "No." = FIELD(Code);
                ShortCutKey = 'Shift+Ctrl+D';
                ApplicationArea=All;
            }
        }
    }

    local procedure CodeOnActivate()
    begin
        SetCurrentKey(Code);
        CurrPage.Update;
    end;

    local procedure DescriptionOnActivate()
    begin
        SetCurrentKey(Description);
        CurrPage.Update;
    end;
}

