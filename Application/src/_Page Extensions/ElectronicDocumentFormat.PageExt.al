pageextension 6014434 "NPR Electronic Document Format" extends "Electronic Document Format"
{
    // NPR5.55/THRO/20200504 CASE 380787 Added "Delivery Endpoint"
    layout
    {
        addafter("Delivery Codeunit Caption")
        {
            field("NPR Delivery Endpoint"; "NPR Delivery Endpoint")
            {
                ApplicationArea = All;
            }
        }
    }
}

