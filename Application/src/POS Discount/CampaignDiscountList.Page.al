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

                    Editable = false;
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Date"; Rec."Starting Date")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Starting Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Ending Date"; Rec."Ending Date")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Closing Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Period Type"; Rec."Period Type")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Period Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Period Description"; Rec."Period Description")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Period Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Comment; Rec.Comment)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Comment field';
                    ApplicationArea = NPRRetail;
                }
                field("Created Date"; Rec."Created Date")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Created Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Modified Date field';
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
                RunPageLink = "Table ID" = CONST(6014413),
                              "No." = FIELD(Code);
                ShortCutKey = 'Shift+Ctrl+D';

                ToolTip = 'Executes the Dimensions action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

