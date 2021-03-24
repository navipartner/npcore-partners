tableextension 6014419 "NPR G/L Account" extends "G/L Account"
{
    fields
    {
        modify(Blocked)
        {
            trigger OnBeforeValidate()
            var
                POSPaymentMethod: Record "NPR POS Payment Method";
                BlockGLAcc2Err: Label 'that post to it.';
                BlockGLAcc1Err: Label 'You can''t block GL Account %1 as there are one or more active payment choices %2, \ ', Comment = '%1 = GL Account, %2 = Payment Method';
            begin
                if Rec.Blocked then begin
                    POSPaymentMethod.SetRange("Account Type", POSPaymentMethod."Account Type"::"G/L Account");
                    POSPaymentMethod.SetRange("Account No.", Rec."No.");
                    POSPaymentMethod.SetRange("Block POS Payment", false);
                    if not POSPaymentMethod.IsEmpty() then
                        Error(BlockGLAcc1Err + BlockGLAcc2Err, Rec."No.", POSPaymentMethod.Description);
                end;
            end;
        }
        field(6014400; "NPR Retail Payment"; Boolean)
        {
            Caption = 'NPR payment';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to "NPR Aux. G/L Account."';
        }
        field(6014402; "NPR Auto"; Boolean)
        {
            Caption = 'Auto';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            InitValue = true;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014403; "NPR Register Filter"; Code[10])
        {
            Caption = 'Register Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014404; "NPR Sales Ticket No. Filter"; Code[10])
        {
            Caption = 'Sales Ticket No. Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014405; "NPR Is Retail Payment"; Boolean)
        {
            Caption = 'Retail Payment';
            FieldClass = FlowField;
            CalcFormula = lookup("NPR Aux. G/L Account"."Retail Payment" where("No." = field("No.")));
        }
    }

    trigger OnBeforeDelete()
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        DeleteGLAcc1Err: Label 'You can''t delete GL Account %1 as there are active payment choices that post cost to it.', Comment = '%1 = GL Account';
    begin
        POSPaymentMethod.SetRange("Account Type", POSPaymentMethod."Account Type"::"G/L Account");
        POSPaymentMethod.SetRange("Account No.", Rec."No.");
        POSPaymentMethod.SetRange("Block POS Payment", false);
        if not POSPaymentMethod.IsEmpty() then
            Error(DeleteGLAcc1Err, Rec."No.");
    end;

}