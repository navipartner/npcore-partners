codeunit 6014443 "NPR Event Subscriber (GLAcc)"
{

    
    [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnBeforeDeleteEvent', '', true, false)]
    local procedure GLAccountOnBeforeDeleteEvent(var Rec: Record "G/L Account"; RunTrigger: Boolean)
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        DeleteGLAcc1Err: Label 'You can''t delete GL Account %1 as there are active payment choices that post cost to it.', Comment = '%1 = GL Account';
    begin
        if not RunTrigger then
            exit;

        POSPaymentMethod.SetRange("Account Type", POSPaymentMethod."Account Type"::"G/L Account");
        POSPaymentMethod.SetRange("Account No.", Rec."No.");
        POSPaymentMethod.SetRange("Block POS Payment", false);
        if POSPaymentMethod.FindFirst() then
            Error(DeleteGLAcc1Err, Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnBeforeValidateEvent', 'Blocked', false, false)]
    local procedure GLAccountOnBeforeValidateEventBlocked(var Rec: Record "G/L Account"; var xRec: Record "G/L Account"; CurrFieldNo: Integer)
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        BlockGLAcc2Err: Label 'that post to it.';
        BlockGLAcc1Err: Label 'You can''t block GL Account %1 as there are one or more active payment choices %2, \ ', Comment = '%1 = GL Account, %2 = Payment Method';
    begin
        if Rec.Blocked then begin
            POSPaymentMethod.SetRange("Account Type", POSPaymentMethod."Account Type"::"G/L Account");
            POSPaymentMethod.SetRange("Account No.", Rec."No.");
            POSPaymentMethod.SetRange("Block POS Payment", false);
            if POSPaymentMethod.FindFirst() then
                Error(BlockGLAcc1Err + BlockGLAcc2Err, Rec."No.", POSPaymentMethod.Description);
        end;
    end;
}

