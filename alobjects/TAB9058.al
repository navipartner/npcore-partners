tableextension 6014453 tableextension6014453 extends "Warehouse Worker WMS Cue" 
{
    // NPR5.54/YAHA /20201102  CASE 383626 Added field  Posting buffer
    // NPR5.55/YAHA /20200511  CASE 383626 Changing Id PostingBuffer to 6014400
    fields
    {
        field(6014400;PostingBuffer;Integer)
        {
            CalcFormula = Count ("CS Posting Buffer" WHERE ("Job Queue Status" = FILTER (Error)));
            Caption = 'Posting Buffer';
            Description = 'NPR5.55';
            FieldClass = FlowField;
        }
    }
}

