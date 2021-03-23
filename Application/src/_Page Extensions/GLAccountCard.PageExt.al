pageextension 6014422 "NPR G/L Account Card" extends "G/L Account Card"
{
    layout
    {
        addafter("Default IC Partner G/L Acc. No")
        {
            field("NPR Retail Payment"; RetailPayment)
            {
                Caption = 'Retail Payment';
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Is Retail Payment field';

                trigger OnValidate()
                var
                    AuxGLAccount: Record "NPR Aux. G/L Account";
                begin
                    if not AuxGLAccount.Get(Rec."No.") then begin
                        AuxGLAccount.Init();
                        AuxGLAccount.TransferFields(Rec);
                        AuxGLAccount."Retail Payment" := RetailPayment;
                        AuxGLAccount.Insert();
                    end else begin
                        AuxGLAccount."Retail Payment" := RetailPayment;
                        AuxGLAccount.Modify();
                    end;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("NPR Is Retail Payment");
        RetailPayment := Rec."NPR Is Retail Payment";
    end;

    var
        RetailPayment: Boolean;
}

