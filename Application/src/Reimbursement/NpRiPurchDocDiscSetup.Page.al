page 6151107 "NPR NpRi Purch.Doc.Disc. Setup"
{
    UsageCategory = None;
    Caption = 'Purchase Document Discount Reimbursement Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "NPR NpRi Purch.Doc.Disc. Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014410)
                {
                    ShowCaption = false;
                    field("Discount %"; Rec."Discount %")
                    {

                        ToolTip = 'Specifies the value of the Discount % field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Bal. Account No."; Rec."Bal. Account No.")
                    {

                        ToolTip = 'Specifies the value of the Bal. Account No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Bal. Gen. Prod. Posting Group"; Rec."Bal. Gen. Prod. Posting Group")
                    {

                        ToolTip = 'Specifies the value of the Bal. Gen. Prod. Posting Group field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Bal. VAT Prod. Posting Group"; Rec."Bal. VAT Prod. Posting Group")
                    {

                        ToolTip = 'Specifies the value of the Bal. VAT Prod. Posting Group field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }
}

