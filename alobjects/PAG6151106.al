page 6151106 "NpRi Provision Setup"
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement

    Caption = 'Reimbursement Provision Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "NpRi Provision Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014410)
                {
                    ShowCaption = false;
                    field("Provision %";"Provision %")
                    {
                    }
                    field("Account No.";"Account No.")
                    {
                    }
                    field("Gen. Prod. Posting Group";"Gen. Prod. Posting Group")
                    {
                    }
                    field("VAT Prod. Posting Group";"VAT Prod. Posting Group")
                    {
                    }
                }
                group(Control6014411)
                {
                    ShowCaption = false;
                    field("Source Code";"Source Code")
                    {
                    }
                    field("Bal. Account No.";"Bal. Account No.")
                    {
                    }
                    field("Bal. Gen. Prod. Posting Group";"Bal. Gen. Prod. Posting Group")
                    {
                    }
                    field("Bal. VAT Prod. Posting Group";"Bal. VAT Prod. Posting Group")
                    {
                    }
                }
            }
        }
    }

    actions
    {
    }
}

