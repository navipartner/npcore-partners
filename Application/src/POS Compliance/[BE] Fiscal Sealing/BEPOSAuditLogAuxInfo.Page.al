page 6059874 "NPR BE POS Audit Log Aux. Info"
{
    ApplicationArea = NPRRetail;
    Caption = 'BE POS Audit Log Aux. Info';
    Editable = false;
    Extensible = false;
    PageType = List;
    SourceTable = "NPR BE POS Audit Log Aux. Info";
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the POS Entry record related to this record.';
                }
                field("Previous Seal No."; Rec."Previous Seal No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the previous seal number value.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the posting date value.';
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the POS store code value.';
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the POS unit number value.';
                }
                field("Seal Serial No."; Rec."Seal Serial No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the seal serial number value.';
                }
                field("Amount Incl. Tax"; Rec."Amount Incl. Tax")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the amount including tax.';
                }
                field("Seal No."; Rec."Seal No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the seal number value.';
                }
            }
        }
    }
}
