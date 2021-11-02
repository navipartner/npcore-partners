codeunit 6014473 "NPR PDF2NAV Subscribers"
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Bill-to Customer No.', true, true)]
    local procedure OnAfterValidateEventBillToCustomerNo(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    var
        Customer: Record Customer;
    begin
        if Customer.Get(Rec."Bill-to Customer No.") then begin
            Rec."NPR Bill-to E-mail" := Customer."E-Mail";
        end;
    end;
}