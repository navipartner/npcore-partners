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
                    AuxTablesMgt.NPRSetGLAccAdditionalFields(NPRAuxGLAccount);
                end;
            }
        }
    }

    var
        NPRAuxGLAccount: Record "NPR Aux. G/L Account";
        AuxTablesMgt: Codeunit "NPR Aux. Tables Mgt.";


    trigger OnAfterGetRecord()
    begin
        AuxTablesMgt.NPRGetGLAccAdditionalFields(NPRAuxGLAccount, Rec."No.");
    end;
}

