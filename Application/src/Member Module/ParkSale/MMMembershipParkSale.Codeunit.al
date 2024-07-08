codeunit 6150825 "NPR MM MembershipParkSale"
{
    Access = Internal;

    var
        _NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";

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

    local procedure ParkSaleLine(SaleLinePOS: Record "NPR POS Sale Line"; var Element: XmlElement)
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipElement, MemberElement : XmlElement;
    begin
        MemberInfoCapture.SetFilter("Receipt No.", '=%1', SaleLinePOS."Sales Ticket No.");
        MemberInfoCapture.SetFilter("Line No.", '=%1', SaleLinePOS."Line No.");
        if (MemberInfoCapture.FindSet()) then begin
            MembershipElement := XmlElement.Create('membership');
            repeat
                // Park sale track tracks the original member info capture record (shallow copy)
                MemberElement := XmlElement.Create('member_info_capture');
                MemberElement.SetAttribute('entry_no', Format(MemberInfoCapture."Entry No.", 0, 9));
                MembershipElement.Add(MemberElement);
            until (MemberInfoCapture.Next() = 0);
            Element.Add(MembershipElement);
        end;
    end;

    local procedure UnParkSaleLine(SaleLinePOS: Record "NPR POS Sale Line"; var Element: XmlElement)
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberNode: XmlNode;
        MemberNodes: XmlNodeList;
        EntryNo: Integer;
    begin
        // Restore the shallow copy to this sale.
        Element.SelectNodes('membership/member_info_capture', MemberNodes);
        foreach MemberNode in MemberNodes do begin
            if (Evaluate(EntryNo, _NpXmlDomMgt.GetXmlAttributeText(MemberNode.AsXmlElement(), 'entry_no', true), 9)) then begin
                if (MemberInfoCapture.Get(EntryNo)) then begin
                    MemberInfoCapture."Receipt No." := SaleLinePOS."Sales Ticket No.";
                    MemberInfoCapture."Line No." := SaleLinePOS."Line No.";
                    MemberInfoCapture.Modify(true);
                end
            end;
        end;
    end;
}