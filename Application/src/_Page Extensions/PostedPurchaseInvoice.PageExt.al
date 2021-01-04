pageextension 6014411 "NPR Posted Purchase Invoice" extends "Posted Purchase Invoice"
{
    layout
    {
        addafter("Pay-to")
        {
            field("NPR Pay-to E-mail"; "NPR Pay-to E-mail")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Pay-to E-mail field';
            }
            field("NPR Document Processing"; "NPR Document Processing")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the value of the NPR Document Processing field';
            }
        }
    }
}

