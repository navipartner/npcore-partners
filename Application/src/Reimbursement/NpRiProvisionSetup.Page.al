page 6151106 "NPR NpRi Provision Setup"
{
    UsageCategory = None;
    Caption = 'Reimbursement Provision Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "NPR NpRi Provision Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014410)
                {
                    ShowCaption = false;
                    field("Provision %"; Rec."Provision %")
                    {

                        ToolTip = 'Specifies the value of the Provision % field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Account No."; Rec."Account No.")
                    {

                        ToolTip = 'Specifies the value of the Account No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                    {

                        ToolTip = 'Specifies the value of the Gen. Prod. Posting Group field';
                        ApplicationArea = NPRRetail;
                    }
                    field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                    {

                        ToolTip = 'Specifies the value of the VAT Prod. Posting Group field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014411)
                {
                    ShowCaption = false;
                    field("Source Code"; Rec."Source Code")
                    {

                        ToolTip = 'Specifies the value of the Source Code field';
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

