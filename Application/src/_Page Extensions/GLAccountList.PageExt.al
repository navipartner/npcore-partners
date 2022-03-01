pageextension 6014423 "NPR G/L Account List" extends "G/L Account List"
{
    layout
    {
        addafter("Reconciliation Account")
        {
            field("NPR Retail Payment"; AuxGLAccount."Retail Payment")
            {
                Caption = 'Retail Payment';
                ToolTip = 'Specifies if the Retail Payment is included on the account';
                Editable = false;
                ApplicationArea = NPRRetail;
            }
        }
    }

    var
        AuxGLAccount: Record "NPR Aux. G/L Account";
        AuxTablesMgt: Codeunit "NPR Aux. Tables Mgt.";

    trigger OnAfterGetRecord()
    begin
        AuxTablesMgt.NPRGetGLAccAdditionalFields(AuxGLAccount, Rec."No.");
    end;
}