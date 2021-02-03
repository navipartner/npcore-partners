codeunit 6014443 "NPR Event Subscriber (GLAcc)"
{

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnAfterModifyEvent', '', true, false)]
    local procedure GLAccountOnAfterModifyEvent(var Rec: Record "G/L Account"; var xRec: Record "G/L Account"; RunTrigger: Boolean)
    var
        PaymentTypePOS: Record "NPR Payment Type POS";
    begin
        if not RunTrigger then
            exit;

        PaymentTypePOS.SetRange("G/L Account No.", xRec."No.");
        PaymentTypePOS.SetRange(Status, PaymentTypePOS.Status::Active);
        if PaymentTypePOS.FindSet() then
            repeat
                PaymentTypePOS."G/L Account No." := Rec."No.";
                PaymentTypePOS.Modify();
            until PaymentTypePOS.Next = 0;
        PaymentTypePOS.SetRange("Cost Account No.", xRec."No.");
        if PaymentTypePOS.FindSet() then
            repeat
                PaymentTypePOS."Cost Account No." := Rec."No.";
                PaymentTypePOS.Modify();
            until PaymentTypePOS.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnBeforeDeleteEvent', '', true, false)]
    local procedure GLAccountOnBeforeDeleteEvent(var Rec: Record "G/L Account"; RunTrigger: Boolean)
    var
        PaymentTypePOS: Record "NPR Payment Type POS";
        DeleteGLAcc1Err: Label 'You can''t delete GL Account %1 as there are active payment choices that post cost to it.', Comment = '%1 = GL Account';
        DeleteGLAcc2Err: Label 'You can''t delete GL Account %1 as there are active payment choices that post to it.', Comment = '%1 = GL Account';
    begin
        if not RunTrigger then
            exit;

        PaymentTypePOS.SetRange("G/L Account No.", Rec."No.");
        PaymentTypePOS.SetRange(Status, PaymentTypePOS.Status::Active);
        if PaymentTypePOS.FindFirst() then
            Error(DeleteGLAcc1Err, Rec."No.");
        PaymentTypePOS.SetRange("Cost Account No.", Rec."No.");
        if PaymentTypePOS.FindFirst() then
            Error(DeleteGLAcc2Err, Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnBeforeValidateEvent', 'Blocked', false, false)]
    local procedure GLAccountOnBeforeValidateEventBlocked(var Rec: Record "G/L Account"; var xRec: Record "G/L Account"; CurrFieldNo: Integer)
    var
        PaymentTypePOS: Record "NPR Payment Type POS";
        BlockGLAcc3Err: Label 'that post cost to it.';
        BlockGLAcc2Err: Label 'that post to it.';
        BlockGLAcc1Err: Label 'You can''t block GL Account %1 as there are one or more active payment choices %2, \ ', Comment = '%1 = GL Account, %2 = Payment type';
    begin
        if Rec.Blocked then begin
            PaymentTypePOS.SetRange("G/L Account No.", Rec."No.");
            PaymentTypePOS.SetRange(Status, PaymentTypePOS.Status::Active);
            if PaymentTypePOS.FindFirst() then
                Error(BlockGLAcc1Err + BlockGLAcc2Err, Rec."No.", PaymentTypePOS.Description);

            PaymentTypePOS.SetRange("Cost Account No.", Rec."No.");
            if PaymentTypePOS.FindFirst() then
                Error(BlockGLAcc1Err + BlockGLAcc3Err, Rec."No.", PaymentTypePOS.Description);
        end;
    end;
}

