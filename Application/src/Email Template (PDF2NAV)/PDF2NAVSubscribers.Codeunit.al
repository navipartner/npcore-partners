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

    [EventSubscriber(ObjectType::Page, Page::"NPR POS Entries", 'OnAfterActionEvent', 'SendAsPDF', true, true)]
    local procedure OnActionSendAsPDF(var Rec: Record "NPR POS Entry")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        EmailDocMgt.SendReport(Rec, false);
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR POS Entries", 'OnAfterActionEvent', 'EmailLog', true, true)]
    local procedure OnActionEmailLog(var Rec: Record "NPR POS Entry")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        EmailDocMgt.RunEmailLog(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR POS Entry List", 'OnAfterActionEvent', 'SendAsPDF', true, true)]
    local procedure Page6150652OnActionSendAsPDF(var Rec: Record "NPR POS Entry")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        EmailDocMgt.SendReport(Rec, false);
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR POS Entry List", 'OnAfterActionEvent', 'EmailLog', true, true)]
    local procedure Page6150652OnActionEmailLog(var Rec: Record "NPR POS Entry")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        EmailDocMgt.RunEmailLog(Rec);
    end;
}