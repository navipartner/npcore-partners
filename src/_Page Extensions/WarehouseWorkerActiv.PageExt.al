pageextension 6014482 "NPR Warehouse Worker Activ." extends "Warehouse Worker Activities"
{
    // NPR5.54/YAHA /20201102  CASE 383626 Added field  Posting buffer
    layout
    {
        addafter("My User Tasks")
        {
            cuegroup("NPR Tasks")
            {
                Caption = 'My User Tasks';
                field("NPR PostingBuffer"; "NPR Posting Buffer")
                {
                    ApplicationArea = All;
                    Caption = 'Posting Buffer';
                    DrillDownPageID = "NPR CS Posting Buffer";
                    Image = Checklist;
                }
            }
        }
    }
}

