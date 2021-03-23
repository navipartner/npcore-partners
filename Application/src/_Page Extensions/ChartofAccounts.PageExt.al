pageextension 6014421 "NPR Chart of Accounts" extends "Chart of Accounts"
{
    layout
    {
        addafter("Default IC Partner G/L Acc. No")
        {
            field("NPR Retail Payment"; RetailPayment)
            {
                Caption = 'Retail Payment';
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Retail Payment field';

                trigger OnValidate()
                var
                    AuxGLAccount: Record "NPR Aux. G/L Account";
                begin
                    AuxGLAccount.Get(Rec."No.");
                    AuxGLAccount."Retail Payment" := RetailPayment;
                    AuxGLAccount.Modify();
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

