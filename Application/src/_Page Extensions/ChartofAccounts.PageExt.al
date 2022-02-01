pageextension 6014421 "NPR Chart of Accounts" extends "Chart of Accounts"
{
    layout
    {
        addafter("Default IC Partner G/L Acc. No")
        {
            field("NPR NPRRetailPayment"; NPRAuxGLAccount."Retail Payment")
            {
                Caption = 'Retail Payment';

                ToolTip = 'Specifies if the Retail Payment is included on the account';
                ApplicationArea = NPRRetail;

                trigger OnValidate()
                begin
                    NPRAuxGLAccount.Validate("Retail Payment");
                    Rec.NPRSetGLAccAdditionalFields(NPRAuxGLAccount);
                    Rec.NPRSaveGLAccAdditionalFields();
                end;
            }
        }
    }

    var
        NPRAuxGLAccount: Record "NPR Aux. G/L Account";


    trigger OnAfterGetRecord()
    begin
        Rec.NPRGetGLAccAdditionalFields(NPRAuxGLAccount);
    end;
}

