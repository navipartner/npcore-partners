pageextension 6014476 "NPR VAT Posting Setup Card" extends "VAT Posting Setup Card"
{
    layout
    {
        addbefore("Sales VAT Account")
        {
            field("NPR Sales Prep. VAT Account"; RSVATPostingSetup."Sales Prep. VAT Account")
            {
                ApplicationArea = NPRRSLocal;
                ToolTip = 'Specifies the value of the Sales Prepayment VAT Account field.';
                ShowMandatory = true;
                TableRelation = "NPR VAT Report Mapping";
                trigger OnValidate()
                begin
                    RSVATPostingSetup.Save();
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        RSVATPostingSetup.Read(Rec.SystemId);
    end;

    var
        RSVATPostingSetup: Record "NPR RS VAT Posting Setup";
}