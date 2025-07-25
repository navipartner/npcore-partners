page 6185082 "NPR POS Customer Input Entries"
{
    Extensible = false;
    Editable = false;
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    Caption = 'Customer Input Entries';
    PageType = List;
    SourceTable = "NPR POS Customer Input Entry";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    Caption = 'POS Entry No.';
                    ToolTip = 'Specifies the POS Entry that the input relates to.';
                    ApplicationArea = NPRRetail;
                }
                field("Date & Time"; Rec."Date & Time")
                {
                    Caption = 'Date & Time';
                    ToolTip = 'Specifies the date and time when the customer input was collected.';
                    ApplicationArea = NPRRetail;
                }
                field(Context; Rec.Context)
                {
                    Caption = 'Customer Input Context';
                    ToolTip = 'Specifies the value of the Context field.';
                    ApplicationArea = NPRRetail;
                }
                field("Information Collected"; Rec."Information Collected")
                {
                    Caption = 'Information Collected';
                    ToolTip = 'Specifies the value of the Information Collected field.';
                    ApplicationArea = NPRRetail;
                }
                field("Information Value"; Rec."Information Value")
                {
                    Caption = 'Information Value';
                    ToolTip = 'Specifies the value of the Information Value field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(FactBoxes)
        {
            part(SignatureViewer; "NPR Signature Viewer")
            {
                SubPageLink = "Entry No." = field("Entry No.");
                ApplicationArea = NPRRetail;
            }

        }
    }
}
