pageextension 6014434 pageextension6014434 extends "Electronic Document Format"
{
    // NPR5.55/THRO/20200504 CASE 380787 Added "Delivery Endpoint"
    layout
    {
        addafter("Delivery Codeunit Caption")
        {
            field("Delivery Endpoint"; "Delivery Endpoint")
            {
                ApplicationArea = All;
            }
        }
    }
}

