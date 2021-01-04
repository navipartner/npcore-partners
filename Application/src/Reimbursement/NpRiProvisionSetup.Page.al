page 6151106 "NPR NpRi Provision Setup"
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement

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
                    field("Provision %"; "Provision %")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Provision % field';
                    }
                    field("Account No."; "Account No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Account No. field';
                    }
                    field("Gen. Prod. Posting Group"; "Gen. Prod. Posting Group")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Gen. Prod. Posting Group field';
                    }
                    field("VAT Prod. Posting Group"; "VAT Prod. Posting Group")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the VAT Prod. Posting Group field';
                    }
                }
                group(Control6014411)
                {
                    ShowCaption = false;
                    field("Source Code"; "Source Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Source Code field';
                    }
                    field("Bal. Account No."; "Bal. Account No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bal. Account No. field';
                    }
                    field("Bal. Gen. Prod. Posting Group"; "Bal. Gen. Prod. Posting Group")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bal. Gen. Prod. Posting Group field';
                    }
                    field("Bal. VAT Prod. Posting Group"; "Bal. VAT Prod. Posting Group")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bal. VAT Prod. Posting Group field';
                    }
                }
            }
        }
    }

    actions
    {
    }
}

