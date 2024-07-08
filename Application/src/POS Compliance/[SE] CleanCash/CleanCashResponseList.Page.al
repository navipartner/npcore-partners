page 6014542 "NPR CleanCash Response List"
{
    Extensible = False;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR CleanCash Trans. Response";
    Editable = false;
    DeleteAllowed = false;
    Caption = 'CleanCash Response List';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field("Request Entry No."; Rec."Request Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specfies the request entry number, this response belongs to.';
                    ApplicationArea = NPRRetail;
                }
                field("Response No."; Rec."Response No.")
                {

                    ToolTip = 'Multiple responses gave individual numbers.';
                    ApplicationArea = NPRRetail;
                }
                field("Response Datetime"; Rec."Response Datetime")
                {

                    ToolTip = 'Specifies date and time response was created.';
                    ApplicationArea = NPRRetail;
                }
                field("Fault Code"; Rec."Fault Code")
                {

                    ToolTip = 'Specifies the reported fault code, in case there was an error when the transaction was processed.';
                    ApplicationArea = NPRRetail;
                }
                field("CleanCash Code"; Rec."CleanCash Code")
                {

                    ToolTip = 'Specifies base-32 encoded string to be printed on the receipt and stored in the POS terminal journal.';
                    ApplicationArea = NPRRetail;
                }
                field("CleanCash Firmware"; Rec."CleanCash Firmware")
                {

                    ToolTip = 'Specifies the CleanCash units firmware.';
                    ApplicationArea = NPRRetail;
                }
                field("CleanCash Storage Status"; Rec."CleanCash Storage Status")
                {

                    ToolTip = 'Specifies CleanCash Storage Status.';
                    ApplicationArea = NPRRetail;
                }
                field("CleanCash Main Status"; Rec."CleanCash Main Status")
                {

                    ToolTip = 'Specifies CleanCash Main Status.';
                    ApplicationArea = NPRRetail;
                }

                field("CleanCash Type"; Rec."CleanCash Type")
                {

                    ToolTip = 'Specifies the CleanCash Unit Type. Options include. -1: Unknown, 0: Type A, 1: Reserved, 2: MultiUser C5/C10/C20/C20+, 3: C1 (Single user USB), 4: MultiUser C1/F (Single pos id, multiple org.no:s)';
                    ApplicationArea = NPRRetail;
                }
                field("CleanCash Unit Id"; Rec."CleanCash Unit Id")
                {

                    ToolTip = 'The CleanCash manufacturing id code.';
                    ApplicationArea = NPRRetail;
                }
                field("Installed Licenses"; Rec."Installed Licenses")
                {

                    ToolTip = 'Specifies licenses installed in CleanCash.';
                    ApplicationArea = NPRRetail;
                }
                field("Fault Short Description"; Rec."Fault Short Description")
                {

                    ToolTip = 'Specifies a short description of the fault.';
                    ApplicationArea = NPRRetail;
                }
                field("Fault Description"; Rec."Fault Description")
                {

                    ToolTip = 'Specifies a full description of the fault.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
