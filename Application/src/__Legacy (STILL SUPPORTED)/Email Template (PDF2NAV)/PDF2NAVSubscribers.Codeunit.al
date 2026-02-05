codeunit 6014473 "NPR PDF2NAV Subscribers"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Bill-to Customer No.', true, true)]
    local procedure OnAfterValidateEventBillToCustomerNo(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    var
        Customer: Record Customer;
    begin
        if Customer.Get(Rec."Bill-to Customer No.") then begin
            Rec."NPR Bill-to E-mail" := Customer."E-Mail";
            Rec."NPR Bill-to Phone No." := Customer."Phone No.";
        end;
    end;
}
