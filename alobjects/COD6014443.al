codeunit 6014443 "NPR Event Subscriber (GLAcc)"
{
    // --Table 15 G/L Account--
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                OnInsert()
    //                                OnModify()
    //                                OnDelete()
    //                                Blocked Field : Added Code to check Retail License
    // NPR5.22.01/TJ/20160517 CASE 241673 Rearranged code and created new events


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 15, 'OnAfterModifyEvent', '', true, false)]
    local procedure OnAfterModifyEvent(var Rec: Record "G/L Account";var xRec: Record "G/L Account";RunTrigger: Boolean)
    var
        PaymentTypePOS: Record "Payment Type POS";
    begin
        //-NPR5.22.01
        /*
        IF RunTrigger THEN
        //-NPR-3.0
          RetailCode.FinansOnModify(Rec,xRec);
        //+NPR-3.0
        */
        if not RunTrigger then
          exit;
        
        with Rec do begin
          PaymentTypePOS.SetRange("G/L Account No.",xRec."No.");
          PaymentTypePOS.SetRange(Status,PaymentTypePOS.Status::Active);
          if PaymentTypePOS.FindSet then
            repeat
              PaymentTypePOS."G/L Account No." := "No.";
              PaymentTypePOS.Modify;
            until PaymentTypePOS.Next = 0;
          PaymentTypePOS.SetRange("Cost Account No.",xRec."No.");
          if PaymentTypePOS.FindSet then
            repeat
              PaymentTypePOS."Cost Account No." := "No.";
              PaymentTypePOS.Modify;
            until PaymentTypePOS.Next = 0;
        end;
        //+NPR5.22.01

    end;

    [EventSubscriber(ObjectType::Table, 15, 'OnBeforeDeleteEvent', '', true, false)]
    local procedure OnBeforeDeleteEvent(var Rec: Record "G/L Account";RunTrigger: Boolean)
    var
        PaymentTypePOS: Record "Payment Type POS";
        Text001: Label 'You can''t delete GL Account %1 as there are active payment choices that post to it.';
        Text002: Label 'You can''t delete GL Account %1 as there are active payment choices that post cost to it.';
    begin
        //-NPR5.22.01
        /*
        IF RunTrigger THEN
        //-NPR-3.0
          RetailCode.FinansOnDelete(Rec);
        //+NPR-3.0
        */
        if not RunTrigger then
          exit;
        
        with Rec do begin
          PaymentTypePOS.SetRange("G/L Account No.","No.");
          PaymentTypePOS.SetRange(Status,PaymentTypePOS.Status::Active);
          if PaymentTypePOS.FindFirst then
            Error(Text001,"No.");
          PaymentTypePOS.SetRange("Cost Account No.","No.");
          if PaymentTypePOS.FindFirst then
            Error(Text002,"No.");
        end;
        //+NPR5.22.01

    end;

    [EventSubscriber(ObjectType::Table, 15, 'OnBeforeValidateEvent', 'Blocked', false, false)]
    local procedure OnBeforeValidateEventBlocked(var Rec: Record "G/L Account";var xRec: Record "G/L Account";CurrFieldNo: Integer)
    var
        PaymentTypePOS: Record "Payment Type POS";
        Text001: Label 'You can''t block GL Account %1 as there are one or more active payment choices %2, \ ';
        Text002: Label 'that post to it.';
        Text003: Label 'that post cost to it.';
    begin
        //-NPR5.22.01
        with Rec do begin
          if Blocked then begin
            PaymentTypePOS.SetRange("G/L Account No.","No.");
            PaymentTypePOS.SetRange(Status,PaymentTypePOS.Status::Active);
            if PaymentTypePOS.FindFirst then
              Error(Text001 + Text002,"No.",PaymentTypePOS.Description); //needs to be translated to english

            PaymentTypePOS.SetRange("Cost Account No.","No.");
            if PaymentTypePOS.FindFirst then
              Error(Text001 + Text003,"No.",PaymentTypePOS.Description); //needs to be translated to english
          end;
        end;
        //+NPR5.22.01
    end;
}

