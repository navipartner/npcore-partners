codeunit 6150904 "NPR HC Audit Roll Mgt."
{
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    var
        Document: XmlDocument;
    begin
        if Rec.LoadXmlDoc(Document) then
            UpdateAuditRolls(Document);
    end;

    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";

    local procedure UpdateAuditRolls(Document: XmlDocument)
    var
        Element: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin
        Document.GetRoot(Element);

        if Element.IsEmpty then
            exit;

        if not NpXmlDomMgt.FindNodes(Element.AsXmlNode(), 'insertauditrollline', NodeList) then
            exit;

        foreach Node in NodeList do
            UpdateAuditRoll(Node.AsXmlElement())
    end;

    local procedure UpdateAuditRoll(Element: XmlElement) DocumentNoFilter: Text
    var
        NodeList: XmlNodeList;
        Node: XmlNode;
        DirectPost: Boolean;
        DocumentNo: Text;
    begin
        if not NpXmlDomMgt.FindNodes(Element.AsXmlNode(), 'auditrollline', NodeList) then
            exit;

        foreach Node in NodeList do begin
            DocumentNo := UpdateAuditRollLine(Node.AsXmlElement());
            AppendDocumentNoFilter(DocumentNo, DocumentNoFilter);
        end;

        Commit();
        if DocumentNoFilter = '' then
            exit;
        if not Evaluate(DirectPost, NpXmlDomMgt.GetXmlAttributeText(Element, 'direct_posting', false), 9) then
            exit;

        if DirectPost then
            PostAuditRoll(DocumentNoFilter);
    end;

    local procedure UpdateAuditRollLine(ItemXmlElement: XmlElement): Text
    var
        HCAuditRoll: Record "NPR HC Audit Roll";
    begin
        if ItemXmlElement.IsEmpty then
            exit('');

        InsertAuditRollLine(ItemXmlElement, HCAuditRoll);

        exit(HCAuditRoll."Sales Ticket No.");
    end;

    local procedure PreprocessAuditRollLine(var HCAuditRoll: Record "NPR HC Audit Roll")
    begin
        HCAuditRoll.Posted := false;
        HCAuditRoll."Item Entry Posted" := false;
        HCAuditRoll."Dimension Set ID" := 0;
        HCAuditRoll."Shortcut Dimension 1 Code" := '';
        HCAuditRoll."Shortcut Dimension 2 Code" := '';

        //Mark lines as posted under certain conditions
        if HCAuditRoll.Type = HCAuditRoll.Type::Cancelled then
            HCAuditRoll.Posted := true;
        if HCAuditRoll.Type = HCAuditRoll.Type::Comment then
            HCAuditRoll.Posted := true;
        if (HCAuditRoll.Type = HCAuditRoll.Type::"Open/Close") and (HCAuditRoll."Sale Type" = HCAuditRoll."Sale Type"::Comment) then
            if HCAuditRoll."No." = '' then
                HCAuditRoll.Posted := true;
        if (HCAuditRoll."Allocated No." <> '') then
            HCAuditRoll.Posted := true;
        if HCAuditRoll.Offline then
            HCAuditRoll.Posted := true;
    end;

    local procedure AppendDocumentNoFilter(DocumentNo: Text; var DocumentNoFilter: Text)
    begin
        if DocumentNo = '' then
            exit;

        if DocumentNoFilter <> '' then
            DocumentNoFilter += '|';

        DocumentNoFilter += DocumentNo;
    end;

    local procedure PostAuditRoll(DocumentNoFilter: Text)
    var
        HCAuditRoll: Record "NPR HC Audit Roll";
    begin
        HCAuditRoll.SetFilter("Sales Ticket No.", DocumentNoFilter);
        CODEUNIT.Run(CODEUNIT::"NPR HC Post Audit Roll", HCAuditRoll);
    end;

    local procedure InsertAuditRollLine(Element: XmlElement; var HCAuditRoll: Record "NPR HC Audit Roll")
    var
        TempHCAuditRoll: Record "NPR HC Audit Roll" temporary;
    begin
        Evaluate(TempHCAuditRoll."Register No.", NpXmlDomMgt.GetXmlText(Element, 'registerno', 0, false), 9);
        Evaluate(TempHCAuditRoll."Sales Ticket No.", NpXmlDomMgt.GetXmlText(Element, 'salesticketno', 0, false), 9);
        Evaluate(TempHCAuditRoll."Sale Type", NpXmlDomMgt.GetXmlText(Element, 'saletype', 0, false), 9);
        Evaluate(TempHCAuditRoll."Line No.", NpXmlDomMgt.GetXmlText(Element, 'lineno', 0, false), 9);
        Evaluate(TempHCAuditRoll.Type, NpXmlDomMgt.GetXmlText(Element, 'type', 0, false), 9);
        Evaluate(TempHCAuditRoll."No.", NpXmlDomMgt.GetXmlText(Element, 'no', 0, false), 9);
        Evaluate(TempHCAuditRoll.Lokationskode, NpXmlDomMgt.GetXmlText(Element, 'lokationskode', 0, false), 9);
        Evaluate(TempHCAuditRoll.Description, NpXmlDomMgt.GetXmlText(Element, 'description', 0, false), 9);
        Evaluate(TempHCAuditRoll.Unit, NpXmlDomMgt.GetXmlText(Element, 'unit', 0, false), 9);
        Evaluate(TempHCAuditRoll.Quantity, NpXmlDomMgt.GetXmlText(Element, 'quantity', 0, false), 9);
        Evaluate(TempHCAuditRoll."VAT %", NpXmlDomMgt.GetXmlText(Element, 'vatperc', 0, false), 9);
        Evaluate(TempHCAuditRoll."Line Discount %", NpXmlDomMgt.GetXmlText(Element, 'linediscountperc', 0, false), 9);
        Evaluate(TempHCAuditRoll."Line Discount Amount", NpXmlDomMgt.GetXmlText(Element, 'linediscountamount', 0, false), 9);
        Evaluate(TempHCAuditRoll."Sale Date", NpXmlDomMgt.GetXmlText(Element, 'saledate', 0, false), 9);
        Evaluate(TempHCAuditRoll."Posted Doc. No.", NpXmlDomMgt.GetXmlText(Element, 'posteddocno', 0, false), 9);
        Evaluate(TempHCAuditRoll.Amount, NpXmlDomMgt.GetXmlText(Element, 'amount', 0, false), 9);
        Evaluate(TempHCAuditRoll."Amount Including VAT", NpXmlDomMgt.GetXmlText(Element, 'amountinclvat', 0, false), 9);
        Evaluate(TempHCAuditRoll."Department Code", NpXmlDomMgt.GetXmlText(Element, 'departmentcode', 0, false), 9);
        Evaluate(TempHCAuditRoll."Serial No.", NpXmlDomMgt.GetXmlText(Element, 'serialno', 0, false), 9);
        Evaluate(TempHCAuditRoll."Customer/Item Discount %", NpXmlDomMgt.GetXmlText(Element, 'customeritemdiscount', 0, false), 9);
        Evaluate(TempHCAuditRoll."Gen. Bus. Posting Group", NpXmlDomMgt.GetXmlText(Element, 'genbuspostinggroup', 0, false), 9);
        Evaluate(TempHCAuditRoll."Gen. Prod. Posting Group", NpXmlDomMgt.GetXmlText(Element, 'genprodpostinggroup', 0, false), 9);
        Evaluate(TempHCAuditRoll."VAT Bus. Posting Group", NpXmlDomMgt.GetXmlText(Element, 'vatbuspostinggroup', 0, false), 9);
        Evaluate(TempHCAuditRoll."VAT Prod. Posting Group", NpXmlDomMgt.GetXmlText(Element, 'vatprodpostinggroup', 0, false), 9);
        Evaluate(TempHCAuditRoll."Currency Code", NpXmlDomMgt.GetXmlText(Element, 'currencycode', 0, false), 9);
        Evaluate(TempHCAuditRoll.Cost, NpXmlDomMgt.GetXmlText(Element, 'cost', 0, false), 9);
        Evaluate(TempHCAuditRoll."Shortcut Dimension 1 Code", NpXmlDomMgt.GetXmlText(Element, 'shortcutdimension1', 0, false), 9);
        Evaluate(TempHCAuditRoll."Shortcut Dimension 2 Code", NpXmlDomMgt.GetXmlText(Element, 'shortcutdimension2', 0, false), 9);
        Evaluate(TempHCAuditRoll."Bin Code", NpXmlDomMgt.GetXmlText(Element, 'bincode', 0, false), 9);
        Evaluate(TempHCAuditRoll."Tax Area Code", NpXmlDomMgt.GetXmlText(Element, 'taxareacode', 0, false), 9);
        Evaluate(TempHCAuditRoll."Tax Liable", NpXmlDomMgt.GetXmlText(Element, 'taxliable', 0, false), 9);
        Evaluate(TempHCAuditRoll."Tax Group Code", NpXmlDomMgt.GetXmlText(Element, 'taxgroupcode', 0, false), 9);
        Evaluate(TempHCAuditRoll."Use Tax", NpXmlDomMgt.GetXmlText(Element, 'usetax', 0, false), 9);
        Evaluate(TempHCAuditRoll."Return Reason Code", NpXmlDomMgt.GetXmlText(Element, 'returnreasoncode', 0, false), 9);
        Evaluate(TempHCAuditRoll."Clustered Key", NpXmlDomMgt.GetXmlText(Element, 'clusteredkey', 0, false), 9);
        Evaluate(TempHCAuditRoll."Unit Cost", NpXmlDomMgt.GetXmlText(Element, 'unitcost', 0, false), 9);
        Evaluate(TempHCAuditRoll."System-Created Entry", NpXmlDomMgt.GetXmlText(Element, 'systemcreatedentry', 0, false), 9);
        Evaluate(TempHCAuditRoll."Variant Code", NpXmlDomMgt.GetXmlText(Element, 'variantcode', 0, false), 9);
        Evaluate(TempHCAuditRoll."Allocated No.", NpXmlDomMgt.GetXmlText(Element, 'allocatedno', 0, false), 9);
        Evaluate(TempHCAuditRoll."Document Type", NpXmlDomMgt.GetXmlText(Element, 'documenttype', 0, false), 9);
        Evaluate(TempHCAuditRoll."Retail Document Type", NpXmlDomMgt.GetXmlText(Element, 'retaildocumenttype', 0, false), 9);
        Evaluate(TempHCAuditRoll."Retail Document No.", NpXmlDomMgt.GetXmlText(Element, 'retaildocumentno', 0, false), 9);
        Evaluate(TempHCAuditRoll."Sales Document Type", NpXmlDomMgt.GetXmlText(Element, 'salesdocumenttype', 0, false), 9);
        Evaluate(TempHCAuditRoll."Sales Document No.", NpXmlDomMgt.GetXmlText(Element, 'salesdocumentno', 0, false), 9);
        Evaluate(TempHCAuditRoll."Sales Document Prepayment", NpXmlDomMgt.GetXmlText(Element, 'salesdocumentprepayment', 0, false), 9);
        Evaluate(TempHCAuditRoll."Sales Doc. Prepayment %", NpXmlDomMgt.GetXmlText(Element, 'salesdocprepaymentperc', 0, false), 9);
        Evaluate(TempHCAuditRoll."Sales Document Invoice", NpXmlDomMgt.GetXmlText(Element, 'salesdocumentinvoice', 0, false), 9);
        Evaluate(TempHCAuditRoll."Sales Document Ship", NpXmlDomMgt.GetXmlText(Element, 'salesdocumentship', 0, false), 9);
        Evaluate(TempHCAuditRoll."POS Sale ID", NpXmlDomMgt.GetXmlText(Element, 'possaleid', 0, false), 9);
        Evaluate(TempHCAuditRoll."Salesperson Code", NpXmlDomMgt.GetXmlText(Element, 'salespersoncode', 0, false), 9);
        Evaluate(TempHCAuditRoll."Discount Type", NpXmlDomMgt.GetXmlText(Element, 'discounttype', 0, false), 9);
        Evaluate(TempHCAuditRoll."Dimension Set ID", NpXmlDomMgt.GetXmlText(Element, 'dimensionsetid', 0, false), 9);
        Evaluate(TempHCAuditRoll."Cash Terminal Approved", NpXmlDomMgt.GetXmlText(Element, 'cashterminalapproved', 0, false), 9);
        Evaluate(TempHCAuditRoll."Drawer Opened", NpXmlDomMgt.GetXmlText(Element, 'draweropened', 0, false), 9);
        Evaluate(TempHCAuditRoll."Starting Time", NpXmlDomMgt.GetXmlText(Element, 'startingtime', 0, false), 9);
        Evaluate(TempHCAuditRoll."Closing Time", NpXmlDomMgt.GetXmlText(Element, 'closingtime', 0, false), 9);
        Evaluate(TempHCAuditRoll."Receipt Type", NpXmlDomMgt.GetXmlText(Element, 'receipttype', 0, false), 9);
        Evaluate(TempHCAuditRoll."Closing Cash", NpXmlDomMgt.GetXmlText(Element, 'closingcash', 0, false), 9);
        Evaluate(TempHCAuditRoll."Opening Cash", NpXmlDomMgt.GetXmlText(Element, 'openingcash', 0, false), 9);
        Evaluate(TempHCAuditRoll."Transferred to Balance Account", NpXmlDomMgt.GetXmlText(Element, 'transferredtobalanceaccount', 0, false), 9);
        Evaluate(TempHCAuditRoll.Difference, NpXmlDomMgt.GetXmlText(Element, 'difference', 0, false), 9);
        Evaluate(TempHCAuditRoll."Change Register", NpXmlDomMgt.GetXmlText(Element, 'changeregister', 0, false), 9);
        Evaluate(TempHCAuditRoll.Posted, NpXmlDomMgt.GetXmlText(Element, 'posted', 0, false), 9);
        Evaluate(TempHCAuditRoll."Posting Date", NpXmlDomMgt.GetXmlText(Element, 'postingdate', 0, false), 9);
        Evaluate(TempHCAuditRoll."Internal Posting No.", NpXmlDomMgt.GetXmlText(Element, 'internalpostingno', 0, false), 9);
        Evaluate(TempHCAuditRoll.Color, NpXmlDomMgt.GetXmlText(Element, 'color', 0, false), 9);
        Evaluate(TempHCAuditRoll.Size, NpXmlDomMgt.GetXmlText(Element, 'size', 0, false), 9);
        Evaluate(TempHCAuditRoll."Serial No. not Created", NpXmlDomMgt.GetXmlText(Element, 'serialnonotcreated', 0, false), 9);
        Evaluate(TempHCAuditRoll."Customer No.", NpXmlDomMgt.GetXmlText(Element, 'customerno', 0, false), 9);
        Evaluate(TempHCAuditRoll."Customer Type", NpXmlDomMgt.GetXmlText(Element, 'customertype', 0, false), 9);
        Evaluate(TempHCAuditRoll."Payment Type No.", NpXmlDomMgt.GetXmlText(Element, 'paymenttypeno', 0, false), 9);
        Evaluate(TempHCAuditRoll."N3 Debit Sale Conversion", NpXmlDomMgt.GetXmlText(Element, 'n3debitsaleconversion', 0, false), 9);
        Evaluate(TempHCAuditRoll."Buffer Document Type", NpXmlDomMgt.GetXmlText(Element, 'bufferdocumenttype', 0, false), 9);
        Evaluate(TempHCAuditRoll."Buffer ID", NpXmlDomMgt.GetXmlText(Element, 'bufferid', 0, false), 9);
        Evaluate(TempHCAuditRoll."Buffer Invoice No.", NpXmlDomMgt.GetXmlText(Element, 'bufferinvoiceno', 0, false), 9);
        Evaluate(TempHCAuditRoll."Reason Code", NpXmlDomMgt.GetXmlText(Element, 'reasoncode', 0, false), 9);
        Evaluate(TempHCAuditRoll."Description 2", NpXmlDomMgt.GetXmlText(Element, 'description2', 0, false), 9);
        Evaluate(TempHCAuditRoll."Money bag no.", NpXmlDomMgt.GetXmlText(Element, 'moneybagno', 0, false), 9);
        Evaluate(TempHCAuditRoll."External Document No.", NpXmlDomMgt.GetXmlText(Element, 'externaldocumentno', 0, false), 9);
        Evaluate(TempHCAuditRoll.LineCounter, NpXmlDomMgt.GetXmlText(Element, 'linecounter', 0, false), 9);
        Evaluate(TempHCAuditRoll.Balancing, NpXmlDomMgt.GetXmlText(Element, 'balancing', 0, false), 9);
        Evaluate(TempHCAuditRoll.Vendor, NpXmlDomMgt.GetXmlText(Element, 'vendor', 0, false), 9);
        Evaluate(TempHCAuditRoll."Invoiz Guid", NpXmlDomMgt.GetXmlText(Element, 'invoizguid', 0, false), 9);
        Evaluate(TempHCAuditRoll."No. Printed", NpXmlDomMgt.GetXmlText(Element, 'noprinted', 0, false), 9);
        Evaluate(TempHCAuditRoll.Offline, NpXmlDomMgt.GetXmlText(Element, 'offline', 0, false), 9);
        Evaluate(TempHCAuditRoll."Customer Post Code", NpXmlDomMgt.GetXmlText(Element, 'customerpostcode', 0, false), 9);
        Evaluate(TempHCAuditRoll."Currency Amount", NpXmlDomMgt.GetXmlText(Element, 'currencyamount', 0, false), 9);
        Evaluate(TempHCAuditRoll."Item Entry Posted", NpXmlDomMgt.GetXmlText(Element, 'itementryposted', 0, false), 9);
        Evaluate(TempHCAuditRoll.Send, NpXmlDomMgt.GetXmlText(Element, 'send', 0, false), 9);
        Evaluate(TempHCAuditRoll."Offline receipt no.", NpXmlDomMgt.GetXmlText(Element, 'offlinereceiptno', 0, false), 9);
        TempHCAuditRoll.Reference := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'reference', MaxStrLen(TempHCAuditRoll.Reference), false), 1, 50);
        PreprocessAuditRollLine(TempHCAuditRoll);

        //Record insert
        if not HCAuditRoll.Get(TempHCAuditRoll."Register No.", TempHCAuditRoll."Sales Ticket No.", TempHCAuditRoll."Sale Type", TempHCAuditRoll."Line No.", TempHCAuditRoll."No.", TempHCAuditRoll."Sale Date") then begin
            HCAuditRoll.Init();
            HCAuditRoll := TempHCAuditRoll;
            HCAuditRoll.Insert();
        end;
    end;
}

