pageextension 6014412 "NPR Sales Credit Memo" extends "Sales Credit Memo"
{
    layout
    {
        addafter(Status)
        {
            field("NPR Correction"; Rec.Correction)
            {
                ApplicationArea = NPRRetail;
                Importance = Additional;
                ToolTip = 'Specifies whether this credit memo is to be posted as a corrective entry.';
            }
        }
        addlast("Credit Memo Details")
        {
            field("NPR Magento Payment Amount"; SalesHeaderAdditionalFields."Magento Payment Amount")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the sum of Payment Lines attached to the Sales Credit Memo';
            }
        }
    }
    var
        SalesHeaderAdditionalFields: Record "NPR Sales Header Add. Fields";

    trigger OnAfterGetCurrRecord()
    begin
        Rec.GetSalesHeaderAdditionalFields(SalesHeaderAdditionalFields);
    end;
}