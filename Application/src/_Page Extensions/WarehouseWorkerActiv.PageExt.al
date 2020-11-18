pageextension 6014482 "NPR Warehouse Worker Activ." extends "Warehouse Worker Activities"
{
    layout
    {
        addafter("Internal")
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

