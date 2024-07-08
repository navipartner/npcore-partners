pageextension 6014422 "NPR G/L Account Card" extends "G/L Account Card"
{
    layout
    {
        addafter("Default IC Partner G/L Acc. No")
        {
            field("NPR Retail Payment"; NPRAuxGLAccountGlobal."Retail Payment")
            {
                Caption = 'Retail Payment';

                ToolTip = 'Specifies if the Retail Payment is included on the account';
                ApplicationArea = NPRRetail;

                trigger OnValidate()
                var
                    NPRAuxGLAccount: Record "NPR Aux. G/L Account";
                begin
                    Rec.TestField("No.");
                    CurrPage.SaveRecord();
                    Rec.NPRGetGLAccAdditionalFields(NPRAuxGLAccount); //need to reread --> related to codeunit 6014626 "NPR Replication Counter Mgmt." --> UpdateReplicationCounterOnBeforeModifyGLAccount
                    NPRAuxGLAccount.Validate("Retail Payment", NPRAuxGLAccountGlobal."Retail Payment");
                    Rec.NPRSetGLAccAdditionalFields(NPRAuxGLAccount);
                    Rec.NPRSaveGLAccAdditionalFields();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        NPRAuxGLAccountGlobal: Record "NPR Aux. G/L Account";

    trigger OnAfterGetCurrRecord()
    begin
        Rec.NPRGetGLAccAdditionalFields(NPRAuxGLAccountGlobal);
    end;
}