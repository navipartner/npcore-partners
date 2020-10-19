page 6014542 "NPR CleanCash Response List"
{
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR CleanCash Trans. Response";
    Editable = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field("Request Entry No."; Rec."Request Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specfies the request entry number, this response belongs to.';
                }
                field("Response No."; Rec."Response No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Multiple responses gave individual numbers.';
                }
                field("Response Datetime"; Rec."Response Datetime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies date and time response was created.';
                }
                field("Fault Code"; Rec."Fault Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the reported fault code, in case there was an error when the transaction was processed.';
                }
                field("CleanCash Code"; Rec."CleanCash Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies base-32 encoded string to be printed on the receipt and stored in the POS terminal journal.';
                }
                field("CleanCash Firmware"; Rec."CleanCash Firmware")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the CleanCash units firmware.';
                }
                field("CleanCash Storage Status"; Rec."CleanCash Storage Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies CleanCash Storage Status.';
                }
                field("CleanCash Main Status"; Rec."CleanCash Main Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies CleanCash Main Status.';
                }

                field("CleanCash Type"; Rec."CleanCash Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the CleanCash Unit Type. Options include. -1: Unknown, 0: Type A, 1: Reserved, 2: MultiUser C5/C10/C20/C20+, 3: C1 (Single user USB), 4: MultiUser C1/F (Single pos id, multiple org.no:s)';
                }
                field("CleanCash Unit Id"; Rec."CleanCash Unit Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'The CleanCash manufacturing id code.';
                }
                field("Installed Licenses"; Rec."Installed Licenses")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies licenses installed in CleanCash.';
                }
                field("Fault Short Description"; Rec."Fault Short Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a short description of the fault.';
                }
                field("Fault Description"; Rec."Fault Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a full description of the fault.';
                }
            }
        }
    }

}