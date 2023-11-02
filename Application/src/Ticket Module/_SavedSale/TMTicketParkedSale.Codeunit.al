codeunit 6150817 "NPR TM TicketParkedSale"
{
    Access = Internal;

    var
        _NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Saved Sale Mgt.", 'OnPOSSale2Xml', '', true, true)]
    local procedure OnPOSSale2Xml(SalePOS: Record "NPR POS Sale"; XmlRoot: XmlElement)
    begin
        ConfirmTicketCancel(SalePOS);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Saved Sale Mgt.", 'OnPOSSaleLine2Xml', '', true, true)]
    local procedure OnPOSSaleLine2Xml(SaleLinePOS: Record "NPR POS Sale Line"; var XmlElement: XmlElement)
    begin
        ParkSaleLine(SaleLinePOS, XmlElement);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Saved Sale Mgt.", 'OnXml2POSSaleLine', '', true, true)]
    local procedure OnXml2POSSaleLine(XmlElement: XmlElement; SaleLinePOS: Record "NPR POS Sale Line")
    begin
        UnParkSaleLine(SaleLinePOS, XmlElement);
    end;

    //----------------------------
    local procedure UnParkSaleLine(SaleLinePOS: Record "NPR POS Sale Line"; Element: XmlElement)
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketRequestNode, AdmissionNode : XmlNode;
        Admissions: XmlNodeList;
        TicketRequestElement, AdmissionRequestElement : XmlElement;
        ExternalAdmissionScheduleEntryNo: Integer;
        Token: Text[100];
        ResponseMessage: Text;
        ResponseCode: Integer;
    begin

        if (not Element.SelectSingleNode('ticket_request', TicketRequestNode)) then
            exit;

        TicketRequestElement := TicketRequestNode.AsXmlElement();
        Token := GetXmlAttributeText100(TicketRequestElement, 'token', true);

        TicketRequestElement.SelectNodes('admissions/admission', Admissions);
        foreach AdmissionNode in Admissions do begin
            AdmissionRequestElement := AdmissionNode.AsXmlElement();
            Evaluate(ExternalAdmissionScheduleEntryNo, GetXmlText20(AdmissionRequestElement, 'external_schedule_entry_code', true));
            TicketRequestManager.POS_AppendToReservationRequest2(
                Token,
                SaleLinePOS."Sales Ticket No.",
                SaleLinePOS."Line No.",
                SaleLinePOS."No.",
                SaleLinePOS."Variant Code",
                GetXmlAttributeText20(AdmissionRequestElement, 'code', true),
                SaleLinePOS.Quantity,
                ExternalAdmissionScheduleEntryNo,
                GetXmlText20(TicketRequestElement, 'member_no', false),
                GetXmlText20(TicketRequestElement, 'external_order_no', false),
                GetXmlText20(TicketRequestElement, 'customer_no', false),
                GetXmlText20(AdmissionRequestElement, 'notification_address', false),
                SaleLinePOS."Line No.");
        end;

        ResponseCode := TicketRequestManager.IssueTicketFromReservationToken(Token, false, ResponseMessage);
        if (ResponseCode <> 0) then begin
            SaleLinePOS."Unit Price" := 0;
            SaleLinePOS.Quantity := 0;
            SaleLinePOS.UpdateAmounts(SaleLinePOS);

            SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Comment;
            SaleLinePOS.Description := CopyStr(StrSubstNo('Item %1 failed: %2', SaleLinePOS."No.", ResponseMessage), 1, MaxStrLen(SaleLinePOS.Description));
            SaleLinePOS."No." := '';

            SaleLinePOS.Modify();
        end
    end;

    //----------------------------
    local procedure ConfirmTicketCancel(SalePOS: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        Item: Record "Item";
        CancelTicketReservation: Label 'This sales contains ticket items! When sale is parked, the tickets will be cancelled to release capacity. Do you want to continue?';
        HasTicketItem: Boolean;
    begin
        if (not GuiAllowed()) then
            exit;

        HasTicketItem := false;
        SaleLinePOS.SetFilter("Register No.", '=%1', SalePOS."Register No.");
        SaleLinePOS.SetFilter("Sales Ticket No.", '=%1', SalePOS."Sales Ticket No.");
        SaleLinePOS.SetFilter("Line Type", '=%1', SaleLinePOS."Line Type"::Item);
        if (SaleLinePOS.FindSet()) then begin
            repeat
                if (Item.Get(SaleLinePOS."No.")) then
                    HasTicketItem := (Item."NPR Ticket Type" <> '');
            until ((SaleLinePOS.Next() = 0) or HasTicketItem);
        end;

        if (HasTicketItem) then
            if (not Confirm(CancelTicketReservation, true)) then
                Error('');
    end;

    local procedure ParkSaleLine(SaleLinePOS: Record "NPR POS Sale Line"; var Element: XmlElement)
    var
        Item: Record "Item";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";

        TicketRequestElement, AdmissionGroupRequestElement, AdmissionRequestElement : XmlElement;
        Token: Text[100];
    begin
        if (not (SaleLinePOS."Line Type" = SaleLinePOS."Line Type"::Item)) then
            exit;

        if (not Item.Get(SaleLinePOS."No.")) then
            exit;

        if (Item."NPR Ticket Type" = '') then
            exit;

        if (not TicketRequestManager.GetTokenFromReceipt(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token)) then
            exit;

        TicketRequest.SetCurrentKey("Session Token ID");
        TicketRequest.SetFilter("Session Token ID", '=%1', Token);
        if (not TicketRequest.FindSet()) then
            exit;

        TicketRequestElement := XmlElement.Create('ticket_request');
        TicketRequestElement.SetAttribute('token', Token);
        TicketRequestElement.Add(AddElement('item_no', TicketRequest."Item No."));
        TicketRequestElement.Add(AddElement('variant_code', TicketRequest."Variant Code"));
        TicketRequestElement.Add(AddElement('external_item_no', TicketRequest."External Item Code"));
        TicketRequestElement.Add(AddElement('external_order_no', TicketRequest."External Order No."));
        TicketRequestElement.Add(AddElement('customer_no', TicketRequest."Customer No."));
        TicketRequestElement.Add(AddElement('member_no', TicketRequest."External Member No."));
        AdmissionGroupRequestElement := XmlElement.Create('admissions');
        repeat
            AdmissionRequestElement := XmlElement.Create('admission');
            AdmissionRequestElement.SetAttribute('code', TicketRequest."Admission Code");
            AdmissionRequestElement.Add(AddElement('external_schedule_entry_code', Format(TicketRequest."External Adm. Sch. Entry No.", 0, 9)));
            AdmissionRequestElement.Add(AddElement('notification_address', TicketRequest."Notification Address"));
            AdmissionRequestElement.Add(AddElement('quantity', Format(TicketRequest.Quantity, 0, 9)));
            AdmissionGroupRequestElement.Add(AdmissionRequestElement);
        until (TicketRequest.Next() = 0);

        TicketRequestElement.Add(AdmissionGroupRequestElement);
        Element.Add(TicketRequestElement);

        TicketRequestManager.DeleteReservationTokenRequest(Token);
    end;

    local procedure AddElement(Name: Text; ElementValue: Text): XmlElement
    var
        Element: XmlElement;
    begin
        Element := XmlElement.Create(Name);
        Element.Add(ElementValue);
        exit(Element);
    end;

    // ---------------------------------------------
#pragma warning disable AA0139
    local procedure GetXmlText20(Element: XmlElement; NodePath: Text; Required: Boolean): Text[20]
    begin
        exit(_NpXmlDomMgt.GetXmlText(Element, NodePath, 20, Required));
    end;

    local procedure GetXmlAttributeText20(Element: XmlElement; AttributeName: Text; Required: Boolean): Text[20]
    begin
        exit(CopyStr(_NpXmlDomMgt.GetXmlAttributeText(Element, AttributeName, Required), 1, 20));
    end;

    local procedure GetXmlAttributeText100(Element: XmlElement; AttributeName: Text; Required: Boolean): Text[100]
    begin
        exit(CopyStr(_NpXmlDomMgt.GetXmlAttributeText(Element, AttributeName, Required), 1, 100));
    end;
#pragma warning restore
}