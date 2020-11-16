codeunit 6014473 "NPR PDF2NAV Subscribers"
{
    // NPR5.39/THRO/20180222 CASE 304256 Added Subscriber for "Pay-to Vendor No."
    // NPR5.42/THRO/20180516 CASE 308179 Added subscribers for Pdf2Nav Page actions
    // NPR5.46/TS  /20180918  CASE 302770 Added Subscirber Action for Page POS Entry List


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterValidateEvent', 'Bill-to Customer No.', true, true)]
    local procedure OnAfterValidateEventBillToCustomerNo(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    var
        Customer: Record Customer;
    begin
        //-NPR5.39 [304256]
        if Customer.Get(Rec."Bill-to Customer No.") then begin
            Rec."NPR Bill-to E-mail" := Customer."E-Mail";
            Rec."NPR Document Processing" := Customer."NPR Document Processing";
        end;
        //+NPR5.39 [304256]
    end;

    [EventSubscriber(ObjectType::Table, 38, 'OnAfterValidateEvent', 'Pay-to Vendor No.', true, true)]
    local procedure OnAfterValidateEventPayToVendorNo(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header"; CurrFieldNo: Integer)
    var
        Vendor: Record Vendor;
    begin
        //-NPR5.39 [304256]
        if Vendor.Get(Rec."Pay-to Vendor No.") then begin
            Rec."NPR Pay-to E-mail" := Vendor."E-Mail";
            Rec."NPR Document Processing" := Vendor."NPR Document Processing";
        end;
        //+NPR5.39 [304256]
    end;

    local procedure "-- Page Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Page, 21, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page21OnActionSendAsPDF(var Rec: Record Customer)
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.SendReport(Rec, false);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 21, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page21OnActionEmailLog(var Rec: Record Customer)
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.RunEmailLog(Rec);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 22, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page22OnActionSendAsPDF(var Rec: Record Customer)
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.SendReport(Rec, false);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 22, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page22OnActionEmailLog(var Rec: Record Customer)
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.RunEmailLog(Rec);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 41, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page41OnActionSendAsPDF(var Rec: Record "Sales Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.SendReport(Rec, false);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 41, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page41OnActionEmailLog(var Rec: Record "Sales Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.RunEmailLog(Rec);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 42, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page42OnActionSendAsPDF(var Rec: Record "Sales Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.SendReport(Rec, false);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 42, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page42OnActionEmailLog(var Rec: Record "Sales Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.RunEmailLog(Rec);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 49, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page49OnActionSendAsPDF(var Rec: Record "Purchase Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.SendReport(Rec, false);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 49, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page49OnActionEmailLog(var Rec: Record "Purchase Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.RunEmailLog(Rec);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 50, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page50OnActionSendAsPDF(var Rec: Record "Purchase Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.SendReport(Rec, false);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 50, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page50OnActionEmailLog(var Rec: Record "Purchase Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.RunEmailLog(Rec);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 130, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page130OnActionSendAsPDF(var Rec: Record "Sales Shipment Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.SendReport(Rec, false);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 130, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page130OnActionEmailLog(var Rec: Record "Sales Shipment Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.RunEmailLog(Rec);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 132, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page132OnActionSendAsPDF(var Rec: Record "Sales Invoice Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.SendReport(Rec, false);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 132, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page132OnActionEmailLog(var Rec: Record "Sales Invoice Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.RunEmailLog(Rec);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 134, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page134OnActionSendAsPDF(var Rec: Record "Sales Cr.Memo Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.SendReport(Rec, false);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 134, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page134OnActionEmailLog(var Rec: Record "Sales Cr.Memo Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.RunEmailLog(Rec);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 136, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page136OnActionSendAsPDF(var Rec: Record "Purch. Rcpt. Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.SendReport(Rec, false);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 136, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page136OnActionEmailLog(var Rec: Record "Purch. Rcpt. Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.RunEmailLog(Rec);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 138, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page138OnActionSendAsPDF(var Rec: Record "Purch. Inv. Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.SendReport(Rec, false);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 138, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page138OnActionEmailLog(var Rec: Record "Purch. Inv. Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.RunEmailLog(Rec);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 140, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page140OnActionSendAsPDF(var Rec: Record "Purch. Cr. Memo Hdr.")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.SendReport(Rec, false);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 140, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page140OnActionEmailLog(var Rec: Record "Purch. Cr. Memo Hdr.")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.RunEmailLog(Rec);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 143, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page143OnActionEmailLog(var Rec: Record "Sales Invoice Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.RunEmailLog(Rec);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 144, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page144OnActionSendAsPDF(var Rec: Record "Sales Cr.Memo Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.SendReport(Rec, false);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 144, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page144OnActionEmailLog(var Rec: Record "Sales Cr.Memo Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.RunEmailLog(Rec);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 438, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page438OnActionSendAsPDF(var Rec: Record "Issued Reminder Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.SendReport(Rec, false);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 438, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page438OnActionEmailLog(var Rec: Record "Issued Reminder Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.RunEmailLog(Rec);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 450, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page450OnActionSendAsPDF(var Rec: Record "Issued Fin. Charge Memo Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.SendReport(Rec, false);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 450, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page450OnActionEmailLog(var Rec: Record "Issued Fin. Charge Memo Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.RunEmailLog(Rec);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 5900, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page5900OnActionSendAsPDF(var Rec: Record "Service Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.SendReport(Rec, false);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 5900, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page5900OnActionEmailLog(var Rec: Record "Service Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.RunEmailLog(Rec);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 5964, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page5964OnActionSendAsPDF(var Rec: Record "Service Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.SendReport(Rec, false);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 5964, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page5964OnActionEmailLog(var Rec: Record "Service Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.RunEmailLog(Rec);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 5975, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page5975OnActionSendAsPDF(var Rec: Record "Service Shipment Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.SendReport(Rec, false);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 5975, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page5975OnActionEmailLog(var Rec: Record "Service Shipment Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.RunEmailLog(Rec);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 5978, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page5978OnActionSendAsPDF(var Rec: Record "Service Invoice Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.SendReport(Rec, false);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 5978, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page5978OnActionEmailLog(var Rec: Record "Service Invoice Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.RunEmailLog(Rec);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 6630, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page6630OnActionSendAsPDF(var Rec: Record "Sales Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.SendReport(Rec, false);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 6630, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page6630OnActionEmailLog(var Rec: Record "Sales Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.RunEmailLog(Rec);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 6640, 'OnAfterActionEvent', 'NPR SendAsPDF', true, true)]
    local procedure Page6640OnActionSendAsPDF(var Rec: Record "Purchase Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.SendReport(Rec, false);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 6640, 'OnAfterActionEvent', 'NPR EmailLog', true, true)]
    local procedure Page6640OnActionEmailLog(var Rec: Record "Purchase Header")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.RunEmailLog(Rec);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 6014432, 'OnAfterActionEvent', 'SendAsPDF', true, true)]
    local procedure Page6014432OnActionSendAsPDF(var Rec: Record "NPR Audit Roll")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.SendReport(Rec, false);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 6014432, 'OnAfterActionEvent', 'EmailLog', true, true)]
    local procedure Page6014432OnActionEmailLog(var Rec: Record "NPR Audit Roll")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.42 [308179]
        EmailDocMgt.RunEmailLog(Rec);
        //+NPR5.42 [308179]
    end;

    [EventSubscriber(ObjectType::Page, 6150652, 'OnAfterActionEvent', 'SendAsPDF', true, true)]
    local procedure Page6150652OnActionSendAsPDF(var Rec: Record "NPR POS Entry")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.46 [302770]
        EmailDocMgt.SendReport(Rec, false);
        //+NPR5.46 [302770]
    end;

    [EventSubscriber(ObjectType::Page, 6150652, 'OnAfterActionEvent', 'EmailLog', true, true)]
    local procedure Page6150652OnActionEmailLog(var Rec: Record "NPR POS Entry")
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        //-NPR5.46 [302770]
        EmailDocMgt.RunEmailLog(Rec);
        //+NPR5.46 [302770]
    end;
}

