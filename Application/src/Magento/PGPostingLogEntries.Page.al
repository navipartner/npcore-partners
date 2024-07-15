page 6184701 "NPR PG Posting Log Entries"
{
    PageType = List;
    Editable = false;
    SourceTable = "NPR PG Posting Log Entry";
    Caption = 'Payment Gateways Posting Log Entries';
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    Extensible = false;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the unique auto-increment value of the Payment Line Posting Log table';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Line System Id"; Rec."Payment Line System Id")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Payment Line System Id field';
                }
                field(Success; Rec.Success)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Success';
                }
                field("Error Description"; Rec."Error Description")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Provides a description of the error, if any.';
                }
                field("Posting Timestamp"; Rec."Posting Timestamp")
                {
                    ToolTip = 'Specifies the value of the Posting Timestamp field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}