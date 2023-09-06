pageextension 6014472 "NPR VAT Posting Setup" extends "VAT Posting Setup"
{
    layout
    {
        addafter("VAT Calculation Type")
        {
            field("NPR Sales Prep. VAT Account"; RSVATPostingSetup."Sales Prep. VAT Account")
            {
                ApplicationArea = NPRRSLocal;
                Caption = 'Sales Prepayment VAT Account';
                ToolTip = 'Specifies the value of the Sales Prepayment VAT Account field.';
                ShowMandatory = true;
                TableRelation = "G/L Account";
                trigger OnValidate()
                begin
                    Rec.TestNotSalesTax(CopyStr(RSVATPostingSetup.FieldCaption("Sales Prep. VAT Account"), 1, 100));

                    Rec.CheckGLAcc(RSVATPostingSetup."Sales Prep. VAT Account");
                    RSVATPostingSetup.Save();
                end;
            }
        }
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

    trigger OnAfterGetCurrRecord()
    begin
        RSVATPostingSetup.Read(Rec.SystemId);
    end;

    var
        RSVATPostingSetup: Record "NPR RS VAT Posting Setup";
}