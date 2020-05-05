pageextension 6014477 pageextension6014477 extends "Warehouse Worker Activities" 
{
    // NPR5.54/YAHA /20201102  CASE 383626 Added field  Posting buffer
    layout
    {
        addafter("My User Tasks")
        {
            cuegroup(Control6014400)
            {
                Caption = 'My User Tasks';
                field(PostingBuffer;PostingBuffer)
                {
                    Caption = 'Posting Buffer';
                    DrillDownPageID = "CS Posting Buffer";
                    Image = Checklist;
                }
            }
        }
    }
}

