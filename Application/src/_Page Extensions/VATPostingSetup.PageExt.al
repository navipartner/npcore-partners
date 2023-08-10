pageextension 6014472 "NPR VAT Posting Setup" extends "VAT Posting Setup"
{
    layout
    {
        addafter("VAT Identifier")
        {
            field("NPR Base % For Full VAT"; Rec."NPR Base % For Full VAT")
            {
                ApplicationArea = NPRRSLocal;
                ToolTip = 'Specifies the value of the Base % For Full VAT field.';
                BlankZero = true;
            }
            field("NPR VAT Report Mapping"; Rec."NPR VAT Report Mapping")
            {
                ApplicationArea = NPRRSLocal;
                ToolTip = 'Specifies the value of the VAT Report Mapping field.';
            }
        }
    }
}