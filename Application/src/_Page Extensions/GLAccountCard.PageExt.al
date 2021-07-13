pageextension 6014422 "NPR G/L Account Card" extends "G/L Account Card"
{
    layout
    {
        addafter("Default IC Partner G/L Acc. No")
        {
            field("NPR Retail Payment"; NPRAuxGLAccount."Retail Payment")
            {
                Caption = 'Retail Payment';

                ToolTip = 'Specifies the value of the NPR Is Retail Payment field';
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


    trigger OnAfterGetCurrRecord()
    begin
        Rec.NPRGetGLAccAdditionalFields(NPRAuxGLAccount);
    end;
}