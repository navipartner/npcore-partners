codeunit 6014473 "NPR PDF2NAV Subscribers"
{
    [EventSubscriber(ObjectType::Table, 36, 'OnAfterValidateEvent', 'Bill-to Customer No.', true, true)]
    local procedure OnAfterValidateEventBillToCustomerNo(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    var
        Customer: Record Customer;
    begin
        if Customer.Get(Rec."Bill-to Customer No.") then begin
            Rec."NPR Bill-to E-mail" := Customer."E-Mail";
        end;
    end;

    [EventSubscriber(ObjectType::Page, 21, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page21OnActionSendAsPDF(var Rec: Record Customer)
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        EmailDocMgt.SendReport(Rec, false);
    end;

    [EventSubscriber(ObjectType::Page, 21, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page21OnActionEmailLog(var Rec: Record Customer)
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        EmailDocMgt.RunEmailLog(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 42, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page42OnActionSendAsPDF(var Rec: Record "Sales Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        EmailDocMgt.SendReport(Rec, false);
    end;

    [EventSubscriber(ObjectType::Page, 42, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page42OnActionEmailLog(var Rec: Record "Sales Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        EmailDocMgt.RunEmailLog(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 49, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page49OnActionSendAsPDF(var Rec: Record "Purchase Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        EmailDocMgt.SendReport(Rec, false);
    end;

    [EventSubscriber(ObjectType::Page, 49, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page49OnActionEmailLog(var Rec: Record "Purchase Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        EmailDocMgt.RunEmailLog(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 50, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page50OnActionSendAsPDF(var Rec: Record "Purchase Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        EmailDocMgt.SendReport(Rec, false);
    end;

    [EventSubscriber(ObjectType::Page, 50, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page50OnActionEmailLog(var Rec: Record "Purchase Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        EmailDocMgt.RunEmailLog(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 130, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page130OnActionSendAsPDF(var Rec: Record "Sales Shipment Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        EmailDocMgt.SendReport(Rec, false);
    end;

    [EventSubscriber(ObjectType::Page, 130, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page130OnActionEmailLog(var Rec: Record "Sales Shipment Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        EmailDocMgt.RunEmailLog(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 132, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page132OnActionSendAsPDF(var Rec: Record "Sales Invoice Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        EmailDocMgt.SendReport(Rec, false);
    end;

    [EventSubscriber(ObjectType::Page, 132, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page132OnActionEmailLog(var Rec: Record "Sales Invoice Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        EmailDocMgt.RunEmailLog(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 143, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page143OnActionEmailLog(var Rec: Record "Sales Invoice Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        EmailDocMgt.RunEmailLog(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 144, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page144OnActionSendAsPDF(var Rec: Record "Sales Cr.Memo Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        EmailDocMgt.SendReport(Rec, false);
    end;

    [EventSubscriber(ObjectType::Page, 144, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page144OnActionEmailLog(var Rec: Record "Sales Cr.Memo Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        EmailDocMgt.RunEmailLog(Rec);
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

    [EventSubscriber(ObjectType::Page, 6150652, 'OnAfterActionEvent', 'SendAsPDF', true, true)]
    local procedure Page6150652OnActionSendAsPDF(var Rec: Record "NPR POS Entry")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        EmailDocMgt.SendReport(Rec, false);
    end;

    [EventSubscriber(ObjectType::Page, 6150652, 'OnAfterActionEvent', 'EmailLog', true, true)]
    local procedure Page6150652OnActionEmailLog(var Rec: Record "NPR POS Entry")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        EmailDocMgt.RunEmailLog(Rec);
    end;
}