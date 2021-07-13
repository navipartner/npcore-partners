pageextension 6014421 "NPR Chart of Accounts" extends "Chart of Accounts"
{
    layout
    {
        addafter("Default IC Partner G/L Acc. No")
        {
            field(NPRRetailPayment; NPRAuxGLAccount."Retail Payment")
            {
                Caption = 'Retail Payment';

                ToolTip = 'Specifies the value of the NPR Retail Payment field';
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

