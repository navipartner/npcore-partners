tableextension 6014452 tableextension6014452 extends "Warehouse Worker WMS Cue" 
{
    // NPR5.54/YAHA /20201102  CASE 383626 Added field  Posting buffer
    fields
    {
        field(25;PostingBuffer;Integer)
        {
            CalcFormula = Count("CS Posting Buffer" WHERE ("Job Queue Status"=FILTER(Error)));
            FieldClass = FlowField;
        }
    }
}

