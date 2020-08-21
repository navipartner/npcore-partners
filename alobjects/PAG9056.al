pageextension 6014482 pageextension6014482 extends "Warehouse Worker Activities"
{
    // NPR5.54/YAHA /20201102  CASE 383626 Added field  Posting buffer
    layout
    {
        addafter("My User Tasks")
        {
            cuegroup(Control6014400)
            {
                Caption = 'My User Tasks';
                field(PostingBuffer; PostingBuffer)
                {
                    ApplicationArea = All;
                    Caption = 'Posting Buffer';
                    DrillDownPageID = "CS Posting Buffer";
                    Image = Checklist;
                }
            }
        }
    }
}

