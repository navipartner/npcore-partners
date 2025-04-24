codeunit 6151093 "NPR SaaS Import CSV Parser"
{
    Access = Internal;
    TableNo = "NPR Saas Import Chunk";
    Permissions = TableData "G/L Account" = rimd,
                  TableData "G/L Entry" = rimd,
                  TableData "Cust. Ledger Entry" = rimd,
                  tabledata "Customer Posting Group" = rimd,
                  TableData "Vendor Ledger Entry" = rimd,
                  tabledata "Vendor Posting Group" = rimd,
                  TableData "G/L Register" = rimd,
                  TableData "G/L Entry - VAT Entry Link" = rimd,
                  TableData "VAT Entry" = rimd,
                  TableData "Bank Account Ledger Entry" = rimd,
                  TableData "Check Ledger Entry" = rimd,
                  TableData "Detailed Cust. Ledg. Entry" = rimd,
                  TableData "Detailed Vendor Ledg. Entry" = rimd,
                  TableData "Line Fee Note on Report Hist." = rim,
                  TableData "Employee Ledger Entry" = rimd,
                  TableData "Detailed Employee Ledger Entry" = rimd,
                  tabledata "Source Code Setup" = rimd,
                  tabledata "Sales & Receivables Setup" = rimd,
                  tabledata "Purchases & Payables Setup" = rimd,
                  TableData "FA Ledger Entry" = rimd,
                  TableData "FA Register" = rimd,
                  TableData "Sales Line" = rimd,
                  TableData "Purchase Header" = rimd,
                  TableData "Purchase Line" = rimd,
                  TableData "Sales Shipment Header" = rimd,
                  TableData "Sales Shipment Line" = rimd,
                  TableData "Sales Invoice Header" = rimd,
                  TableData "Sales Invoice Line" = rimd,
                  TableData "Sales Cr.Memo Header" = rimd,
                  TableData "Sales Cr.Memo Line" = rimd,
                  TableData "Purch. Rcpt. Header" = rimd,
                  TableData "Purch. Rcpt. Line" = rimd,
                  TableData "Purch. Inv. Header" = rimd,
                  TableData "Purch. Inv. Line" = rimd,
                  TableData "Purch. Cr. Memo Hdr." = rimd,
                  TableData "Purch. Cr. Memo Line" = rimd,
                  TableData "Drop Shpt. Post. Buffer" = rimd,
                  TableData "General Posting Setup" = rimd,
                  TableData "Posted Assemble-to-Order Link" = rimd,
                  TableData "Service Item" = rimd,
                  TableData "Value Entry" = rimd,
                  TableData "Item Entry Relation" = rimd,
                  TableData "Value Entry Relation" = rimd,
                  TableData "Return Receipt Header" = rimd,
                  TableData "Return Receipt Line" = rimd,
                  TableData "Return Shipment Header" = rimd,
                  TableData "Return Shipment Line" = rimd,
                  TableData "Item Ledger Entry" = rimd,
                  TableData "G/L - Item Ledger Relation" = rimd,
                  TableData "Maintenance Ledger Entry" = rimd,
                  TableData "Phys. Inventory Ledger Entry" = rimd,
                  TableData "Dimension Set Entry" = rimd,
                  TableData "Dimension Set Tree Node" = rimd,
                  TableData "Tenant Media Thumbnails" = rimd,
                  TableData "Tenant Media" = rimd,
                  TableData "Item Application Entry" = rimd,
                  TableData "Item Register" = rimd,
                  TableData "Batch Processing Parameter" = rimd,
                  TableData "Approval Entry" = rimd,
                  TableData "Posted Approval Entry" = rimd,
                  TableData "Posted Approval Comment Line" = rimd,
                  TableData "Workflow Step Instance Archive" = rimd,
                  TableData "Workflow Step Argument Archive" = rimd,
                  TableData "Warehouse Entry" = rimd,
                  TableData "Warehouse Register" = rimd,
                  TableData "Res. Ledger Entry" = rmid,
                  TableData "Bank Account Statement" = rmid,
                  TableData "Bank Account Statement Line" = rmid,
                  TableData "Issued Reminder Header" = rmid,
                  TableData "Issued Reminder Line" = rmid,
                  TableData "Reminder/Fin. Charge Entry" = rmid,
                  TableData "Field Monitoring Setup" = rmid,
                  TableData "Cancelled Document" = rmid,
                  TableData "Retention Period" = rmid,
                  TableData "Retention Policy Setup" = rmid,
#IF NOT (BC17 or BC18 or BC19 or BC20 or BC21)
                  TableData "Email Outbox" = rmid,
                  TableData "Email Related Record" = rmid,
                  TableData "Sent Email" = rmid,
#endif
                  TableData "Retention Policy Setup Line" = rmid;

    trigger OnRun()
    var
        IStream: InStream;
        DataLogManagement: Codeunit "NPR Data Log Management";
    begin
        LockTimeout(false);
        DataLogManagement.DisableDataLog(true);

        Rec.Chunk.CreateInStream(IStream, TextEncoding::UTF8);
        Import(IStream);
    end;

    procedure Import(var IStream: InStream)
    var
        RecRef: RecordRef;
        FieldReference: FieldRef;
        TableId: Integer;
        Line: Text;
        TextField: Text;
        TextList: List of [Text];
        FieldList: List of [Integer];
        IntBuffer: Integer;
        i: Integer;
        FormattedValue: Text;
    begin
        IStream.ReadText(Line);
        Evaluate(TableId, Line);

        IStream.ReadText(Line);
        TextList := Line.Split('|');
        foreach TextField in TextList do begin
            Evaluate(IntBuffer, TextField);
            FieldList.Add(IntBuffer);
        end;

        RecRef.Open(TableId);

        while (not IStream.EOS) do begin
            IStream.ReadText(Line);
            //Remove starting and ending " and split 
            TextList := Line.Substring(2, StrLen(Line) - 2).Split('"|"');

            RecRef.Init();
            i := 0;
            foreach FormattedValue in TextList do begin
                i += 1;
                FieldReference := RecRef.Field(FieldList.Get(i));
                //De-escape after our split
                FormattedValueToFieldRef(FormattedValue.Replace('\|', '|').Replace('\"', '"'), FieldReference);
            end;
            if not RecRef.Insert(false, true) then
                RecRef.Modify();
        end;

        RecRef.Close();
    end;

    local procedure FormattedValueToFieldRef(FormattedValue: Text; var FieldReference: FieldRef)
    var
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        OutStr: OutStream;
        ValueDate: Date;
        ValueTime: Time;
        ValueDateTime: DateTime;
        ValueDateFormula: DateFormula;
        ValueDuration: Duration;
        ValueGUID: Guid;
        ValueRecordID: RecordID;
        ValueBigInt: BigInteger;
        ValueDecimal: Decimal;
        ValueInt: Integer;
        ValueBool: Boolean;
        IStream: InStream;
        MediaId: Guid;
        TextValue: Text;
        ClosingDateVar: Date;
        SaaSImportMediaBuffer: Record "NPR SaaS Import Media Buffer";
    begin
        case FieldReference.Type of
            FieldType::Text,
            FieldType::Code:
                FieldReference.Value := FormattedValue;
            FieldType::Integer,
            FieldType::Option:
                begin
                    Evaluate(ValueInt, FormattedValue, 9);
                    FieldReference.Value := ValueInt;
                end;
            FieldType::Boolean:
                begin
                    Evaluate(ValueBool, FormattedValue, 9);
                    FieldReference.Value := ValueBool;
                end;
            FieldType::Blob:
                begin
                    TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
                    Base64Convert.FromBase64(FormattedValue, OutStr);
                    TempBlob.ToFieldRef(FieldReference);
                end;
            FieldType::Media:
                begin
                    TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
                    Base64Convert.FromBase64(FormattedValue, OutStr);
                    TempBlob.CreateInStream(IStream, TextEncoding::UTF8);

                    SaaSImportMediaBuffer.Init();
                    MediaId := SaaSImportMediaBuffer."Media Buffer".ImportStream(IStream, 'Auto imported media via saas data migration tool');
                    FieldReference.Value := MediaId;
                end;
            FieldType::MediaSet:
                begin
                    TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
                    Base64Convert.FromBase64(FormattedValue, OutStr);
                    TempBlob.CreateInStream(IStream, TextEncoding::UTF8);

                    SaaSImportMediaBuffer.Init();
                    MediaId := SaaSImportMediaBuffer."Media Set Buffer".ImportStream(IStream, 'Auto imported mediaset via saas data migration tool');
                    FieldReference.Value := MediaId;
                end;
            FieldType::Decimal:
                begin
                    Evaluate(ValueDecimal, FormattedValue, 9);
                    FieldReference.Value := ValueDecimal;
                end;
            FieldType::BigInteger:
                begin
                    Evaluate(ValueBigInt, FormattedValue, 9);
                    FieldReference.Value := ValueBigInt;
                end;
            FieldType::Date:
                begin
                    if FormattedValue[1] = 'C' then begin
                        TextValue := FormattedValue.TrimStart('C');
                        Evaluate(ClosingDateVar, TextValue, 9);
                        FieldReference.Value := ClosingDate(ClosingDateVar);
                    end else begin
                        Evaluate(ValueDate, FormattedValue, 9);
                        FieldReference.Value := ValueDate;
                    end;
                end;
            FieldType::DateTime:
                begin
                    Evaluate(ValueDateTime, FormattedValue, 9);
                    FieldReference.Value := ValueDateTime;
                end;
            FieldType::Time:
                begin
                    Evaluate(ValueTime, FormattedValue, 9);
                    FieldReference.Value := ValueTime;
                end;
            FieldType::DateFormula:
                begin
                    Evaluate(ValueDateFormula, FormattedValue, 9);
                    FieldReference.Value := ValueDateFormula;
                end;
            FieldType::Duration:
                begin
                    Evaluate(ValueDuration, FormattedValue, 9);
                    FieldReference.Value := ValueDuration;
                end;
            FieldType::Guid:
                begin
                    Evaluate(ValueGUID, FormattedValue, 9);
                    FieldReference.Value := ValueGUID;
                end;
            FieldType::RecordId:
                begin
                    if not Evaluate(ValueRecordID, FormattedValue, 9) then
                        if not Evaluate(ValueRecordID, 'NPR ' + FormattedValue, 9) then
                            if not Evaluate(ValueRecordID, RecordIDValueFromCALName(FormattedValue), 9) then
                                Evaluate(ValueRecordID, FormattedValue, 9);
                    FieldReference.Value := ValueRecordID;
                end;
            else
                Error('Unsupported type %1 on field %2', Format(FieldReference.Type), FieldReference.Number);
        end;
    end;

    local procedure RecordIDValueFromCALName(RecordIDValue: Text): Text
    var
        NewRecordIDValue: Text;
        TableName: Text;
        ValueRecordID: RecordID;
        Position: Integer;
        Handled: Boolean;
    begin
        Position := StrPos(RecordIDValue, ': ');
        if Position > 0 then begin
            TableName := CopyStr(RecordIDValue, 1, Position - 1);
            NewRecordIDValue := FindCALName(TableName) + CopyStr(RecordIDValue, Position);
            if Evaluate(ValueRecordID, NewRecordIDValue, 9) then
                exit(NewRecordIDValue);
        end;
        NewRecordIDValue := '';
        OnTranslateRecordIDValue(RecordIDValue, NewRecordIDValue, Handled);
        if Handled then
            exit(NewRecordIDValue)
        else
            exit(RecordIDValue);
    end;

    local procedure FindCALName(TableName: Text): Text
    begin
        case TableName of
            'Sale POS':
                exit('NPR POS Sale');
            'Sale Line POS':
                exit('NPR POS Sale Line');
            'Mixed Discount Time Interval':
                exit('NPR Mixed Disc. Time Interv.');
            'Mixed Discount Priority Buffer':
                exit('NPR Mixed Disc. Prio. Buffer');
            'Posted Document Buffer':
                exit('NPR Posted Doc. Buffer');
            'NPR - TEMP Buffer':
                exit('NPR TEMP Buffer');
            'Pacsoft Shipment Document':
                exit('NPR Shipping Provider Document');
            'E-mail Template Report':
                exit('NPR E-mail Templ. Report');
            'E-mail Template Line':
                exit('NPR E-mail Templ. Line');
            'Sales-Post and Pdf2Nav Setup':
                exit('NPR SalesPost Pdf2Nav Setup');
            'Pacsoft Shipment Doc. Services':
                exit('NPR Pacsoft Shipm. Doc. Serv.');
            'Item Replenishment by Store':
                exit('NPR Item Repl. by Store');
            'Archive POS Info Transaction':
                exit('NPR Archive POS Info Trx');
            'Archive NpRv SL POS Voucher':
                exit('NPR Archive NpRv SL POS Vouch.');
            'Archive NpRv SL POS Reference':
                exit('NPR Arch. NpRv SL POS Ref.');
            'Archive NpIa SL POS AddOn':
                exit('NPR Arch. NpIa SL POS AddOn');
            'Archive Retail Cross Reference':
                exit('NPR Arch. Retail Cross Ref.');
            'Archive NpDc SL POS New Coupon':
                exit('NPR Arch.NpDc SL POS NewCoupon');
            'Package Module Configuration':
                exit('NPR Package Module Config.');
            'RP Data Item Constraint':
                exit('NPR RP Data Item Constr.');
            'RP Data Item Constraint Links':
                exit('NPR RP Data Item Constr. Links');
            'RP Data Join Record ID Buffer':
                exit('NPR RP DataJoin Rec.ID Buffer');
            'RP Import Worksheet':
                exit('NPR RP Imp. Worksh.');
            'Pacsoft Setup':
                exit('NPR Shipping Provider Setup');
            'Sales Statistics Time Period':
                exit('NPR Sales Stats Time Period');
            'Tax Free Handler Parameters':
                exit('NPR Tax Free Handler Param.');
            'Tax Free GB I2 Parameter':
                exit('NPR Tax Free GB I2 Param.');
            'Tax Free GB I2 Info Capture':
                exit('NPR TaxFree GB I2 Info Capt.');
            'Tax Free GB Blocked Country':
                exit('NPR TaxFree GB BlockedCountry');
            'Sales Price Maintenance Setup':
                exit('NPR Sales Price Maint. Setup');
            'Transactional Email Setup':
                exit('NPR Trx Email Setup');
            'Transactional Email Log':
                exit('NPR Trx Email Log');
            'Transactional JSON Result':
                exit('NPR Trx JSON Result');
            'MCS Webcam Argument Table':
                exit('NPR MCS Webcam Arg. Table');
            'MCS Person Business Entities':
                exit('NPR MCS Person Bus. Entit.');
            'Item Worksheet Template':
                exit('NPR Item Worksh. Template');
            'Item Worksheet Variant Line':
                exit('NPR Item Worksh. Variant Line');
            'Item Worksheet Variety Value':
                exit('NPR Item Worksh. Variety Value');
            'Registered Item Worksheet':
                exit('NPR Registered Item Works.');
            'Registered Item Worksheet Line':
                exit('NPR Regist. Item Worksh Line');
            'Reg. Item Wsht Variant Line':
                exit('NPR Reg. Item Wsht Var. Line');
            'Reg. Item Wsht Variety Value':
                exit('NPR Reg. Item Wsht Var. Value');
            'Item Worksheet Excel Column':
                exit('NPR Item Worksh. Excel Column');
            'Item Worksheet Field Setup':
                exit('NPR Item Worksh. Field Setup');
            'Item Worksheet Field Change':
                exit('NPR Item Worksh. Field Change');
            'Item Worksheet Field Mapping':
                exit('NPR Item Worksh. Field Mapping');
            'Inventory Overview Line':
                exit('NPR Inv. Overview Line');
            'Item Worksheet Variety Mapping':
                exit('NPR Item Worksh. Vrty Mapping');
            'MCS Recommendations Model':
                exit('NPR MCS Recomm. Model');
            'MCS Rec. Business Rule':
                exit('NPR MCS Rec. Bus. Rule');
            'MM Admission Service Setup':
                exit('NPR MM Admis. Service Setup');
            'MM Admission Service Entry':
                exit('NPR MM Admis. Service Entry');
            'MM Admission Service Log':
                exit('NPR MM Admis. Service Log');
            'MM Recurring Payment Setup':
                exit('NPR MM Recur. Paym. Setup');
            'MM Payment Reconciliation':
                exit('NPR MM Payment Reconci.');
            'MM Admission Scanner Stations':
                exit('NPR MM Admis. Scanner Stations');
            'TM Offline Ticket Validation':
                exit('NPR TM Offline Ticket Valid.');
            'TM Ticket Notification Entry':
                exit('NPR TM Ticket Notif. Entry');
            'TM Ticket Participant Wks.':
                exit('NPR TM Ticket Particpt. Wks.');
            'TM Ticket Access Statistics':
                exit('NPR TM Ticket Access Stats');
            'TM Ticket Reservation Request':
                exit('NPR TM Ticket Reservation Req.');
            'TM Ticket Reservation Response':
                exit('NPR TM Ticket Reserv. Resp.');
            'TM Admission Schedule':
                exit('NPR TM Admis. Schedule');
            'TM Admission Schedule Lines':
                exit('NPR TM Admis. Schedule Lines');
            'TM Admission Schedule Entry':
                exit('NPR TM Admis. Schedule Entry');
            'TM Det. Ticket Access Entry':
                exit('NPR TM Det. Ticket AccessEntry');
            'MM Membership Sales Setup':
                exit('NPR MM Members. Sales Setup');
            'MM Membership Points Entry':
                exit('NPR MM Members. Points Entry');
            'MM Membership Admission Setup':
                exit('NPR MM Members. Admis. Setup');
            'MM Membership Alteration Setup':
                exit('NPR MM Members. Alter. Setup');
            'MM Member Notification Setup':
                exit('NPR MM Member Notific. Setup');
            'MM Membership Notification':
                exit('NPR MM Membership Notific.');
            'MM Member Notification Entry':
                exit('NPR MM Member Notific. Entry');
            'MM Loyalty Points Setup':
                exit('NPR MM Loyalty Point Setup');
            'MM Loyalty Item Point Setup':
                exit('NPR MM Loy. Item Point Setup');
            'MM Foreign Membership Setup':
                exit('NPR MM Foreign Members. Setup');
            'MM Membership Limitation Setup':
                exit('NPR MM Membership Lim. Setup');
            'MM Member Arrival Log Entry':
                exit('NPR MM Member Arr. Log Entry');
            'MM NPR Remote Endpoint Setup':
                exit('NPR MM NPR Remote Endp. Setup');
            'RC Membership Burndown Setup':
                exit('NPR RC Members. Burndown Setup');
            'Event Attribute Row Template':
                exit('NPR Event Att. Row Templ.');
            'Event Attribute Col. Template':
                exit('NPR Event Attr. Col. Template');
            'Event Attribute Row Value':
                exit('NPR Event Attr. Row Value');
            'Event Attribute Column Value':
                exit('NPR Event Attr. Column Value');
            'Event Planning Line Buffer':
                exit('NPR Event Plan. Line Buffer');
            'Event Exch. Int. Temp. Entry':
                exit('NPR Event Exch.Int.Temp.Entry');
            'Event Attribute Temp. Filter':
                exit('NPR Event Attr. Temp. Filter');
            'Event Exc. Int. Summary Buffer':
                exit('NPR Event Exc.Int.Summ. Buffer');
            'POS Sales Line':
                exit('NPR POS Entry Sales Line');
            'POS Payment Line':
                exit('NPR POS Entry Payment Line');
            'POS Entry Comment Line':
                exit('NPR POS Entry Comm. Line');
            'POS Payment Bin Checkpoint':
                exit('NPR POS Payment Bin Checkp.');
            'POS Tax Amount Line':
                exit('NPR POS Entry Tax Line');
            'POS Workshift Tax Checkpoint':
                exit('NPR POS Worksh. Tax Checkp.');
            'POS Payment Bin Eject Param.':
                exit('NPR POS Paym. Bin Eject Param.');
            'POS Payment Bin Denomination':
                exit('NPR POS Paym. Bin Denomin.');
            'POS Unit Receipt Text Profile':
                exit('NPR POS Unit Rcpt.Txt Profile');
            'POS NPRE Restaurant Profile':
                exit('NPR POS NPRE Rest. Profile');
            'NPRE Seating - Waiter Pad Link':
                exit('NPR NPRE Seat.: WaiterPadLink');
            'NPRE Print/Prod. Category':
                exit('NPR NPRE Print/Prod. Cat.');
            'NPRE Print Template':
                exit('NPR NPRE Print Templ.');
            'NPRE Assigned Print Category':
                exit('NPR NPRE Assign. Print Cat.');
            'NPRE W.Pad Line Prnt Log Entry':
                exit('NPR NPRE W.Pad Prnt LogEntry');
            'NPRE W.Pad Line Output Buffer':
                exit('NPR NPRE W.Pad.Line Outp.Buf.');
            'NPRE Service Flow Profile':
                exit('NPR NPRE Serv.Flow Profile');
            'NPRE Kitchen Req. Source Link':
                exit('NPR NPRE Kitchen Req.Src. Link');
            'NPRE Kitchen Request Station':
                exit('NPR NPRE Kitchen Req. Station');
            'NPRE Kitchen Station Selection':
                exit('NPR NPRE Kitchen Station Slct.');
            'Data Model Upgrade Log Entry':
                exit('NPR Data Model Upg. Log Entry');
            'POS Data Source (Discovery)':
                exit('NPR POS Data Source Discovery');
            'POS Sales Workflow Set Entry':
                exit('NPR POS Sales WF Set Entry');
            'HC Payment Type Posting Setup':
                exit('NPR HC Paym.Type Post.Setup');
            'NPR Upgrade History':
                exit('NPR Upgrade History');
            'POS Quote Entry':
                exit('NPR POS Saved Sale Entry');
            'POS Quote Line':
                exit('NPR POS Saved Sale Line');
            'NpRv Return Voucher Type':
                exit('NPR NpRv Ret. Vouch. Type');
            'NpRv Sales Line Reference':
                exit('NPR NpRv Sales Line Ref.');
            'NpRv Global Voucher Setup':
                exit('NPR NpRv Global Vouch. Setup');
            'POS Payment View Log Entry':
                exit('NPR POS Paym. View Log Entry');
            'POS Payment View Event Setup':
                exit('NPR POS Paym. View Event Setup');
            'Distribution Group':
                exit('NPR Distrib. Group');
            'Distribution Group Members':
                exit('NPR Distrib. Group Members');
            'Retai Repl. Demand Line':
                exit('NPR Retail Repl. Demand Line');
            'RIS Retail Inventory Set':
                exit('NPR RIS Retail Inv. Set');
            'RIS Retail Inventory Set Entry':
                exit('NPR RIS Retail Inv. Set Entry');
            'RIS Retail Inventory Buffer':
                exit('NPR RIS Retail Inv. Buffer');
            'NpRi Reimbursement Template':
                exit('NPR NpRi Reimbursement Templ.');
            'NpRi Purch. Doc. Disc. Setup':
                exit('NPR NpRi Purch.Doc.Disc. Setup');
            'NpIa Sale Line POS AddOn':
                exit('NPR NpIa SaleLinePOS AddOn');
            'NpIa Item AddOn Line Option':
                exit('NPR NpIa ItemAddOn Line Opt.');
            'NpIa Item AddOn Line Setup':
                exit('NPR NpIa ItemAddOn Line Setup');
            'TM Seating Attr. Definition':
                exit('NPR TM Seating Attr. Defin.');
            'TM Seating Reservation Entry':
                exit('NPR TM Seating Reserv. Entry');
            'TM Concurrent Admission Setup':
                exit('NPR TM Concurrent Admis. Setup');
            'TM Ticket Waiting List':
                exit('NPR TM Ticket Wait. List');
            'M2 Price Calculation Buffer':
                exit('NPR M2 Price Calc. Buffer');
            'MM Register Sales Buffer':
                exit('NPR MM Reg. Sales Buffer');
            'MM Loyalty Ledger Entry (Srvr)':
                exit('NPR MM Loy. LedgerEntry (Srvr)');
            'MM Loyalty Alter Membership':
                exit('NPR MM Loyalty Alter Members.');
            'MM Membership Points Summary':
                exit('NPR MM Members. Points Summary');
            'NpGp Detailed POS Sales Entry':
                exit('NPR NpGp Det. POS Sales Entry');
            'MM Sponsorship Ticket Setup':
                exit('NPR MM Sponsors. Ticket Setup');
            'MM Sponsorship Ticket Entry':
                exit('NPR MM Sponsors. Ticket Entry');
            'MM Member Communication Setup':
                exit('NPR MM Member Comm. Setup');
            'NpCs Store Workflow Relation':
                exit('NPR NpCs Store Workflow Rel.');
            'NpCs Arch. Document Log Entry':
                exit('NPR NpCs Arch. Doc. Log Entry');
            'NpCs Sale Line POS Reference':
                exit('NPR NpCs Sale Line POS Ref.');
            'NpCs Store Inventory Buffer':
                exit('NPR NpCs Store Inv. Buffer');
            'NpCs Open. Hour Calendar Entry':
                exit('NPR NpCs Open. Hour Cal. Entry');
            'Magento Generic Setup Buffer':
                exit('NPR Magento Gen. Setup Buffer');
            'Magento VAT Business Group':
                exit('NPR Magento VAT Bus. Group');
            'Magento VAT Product Group':
                exit('NPR Magento VAT Prod. Group');
            'Magento Inventory Company':
                exit('NPR Magento Inv. Company');
            'Magento Custom Option Value':
                exit('NPR Magento Custom Optn. Value');
            'Magento Item Custom Opt. Value':
                exit('NPR Magento Itm Cstm Opt.Value');
            'Magento Attribute Label':
                exit('NPR Magento Attr. Label');
            'Magento Attribute Set Value':
                exit('NPR Magento Attr. Set Value');
            'Magento Item Attribute':
                exit('NPR Magento Item Attr.');
            'Magento Item Attribute Value':
                exit('NPR Magento Item Attr. Value');
            'Magento Contact Pmt. Method':
                exit('NPR Magento Contact Pmt.Meth.');
            'Magento Contact Shpt. Method':
                exit('NPR Magento Contact Shpt.Meth.');
            'Magento Contact Ship-to Adrs.':
                exit('NPR Magento Contact ShipToAdr.');
            'Magento Post on Import Setup':
                exit('NPR Magento PostOnImport Setup');
            'NpXml Template Trigger Link':
                exit('NPR NpXml Templ.Trigger Link');
            'NpXml Custom Value Buffer':
                exit('NPR NpXml Custom Val. Buffer');
            'NpXml Field Value Buffer':
                exit('NPR NpXml Field Val. Buffer');
            'NpXml Template Archive':
                exit('NPR NpXml Template Arch.');
            'AF Arguments - Spire Barcode':
                exit('NPR AF Args: Spire Barcode');
            'AF Arguments - NotificationHub':
                exit('NPR AF Arguments - Notific.Hub');
            'NpDc Sale Line POS Coupon':
                exit('NPR NpDc SaleLinePOS Coupon');
            'NpDc Arch. Coupon Entry':
                exit('NPR NpDc Arch.Coupon Entry');
            'NpDc Issue On-Sale Setup':
                exit('NPR NpDc Iss.OnSale Setup');
            'NpDc Issue On-Sale Setup Line':
                exit('NPR NpDc Iss.OnSale Setup Line');
            'NpDc Sale Line POS New Coupon':
                exit('NPR NpDc SaleLinePOS NewCoupon');
            'NpDc Ext. Coupon Reservation':
                exit('NPR NpDc Ext. Coupon Reserv.');
            'EFT Type Payment BLOB Param.':
                exit('NPR EFTType Paym. BLOB Param.');
            'EFT Type POS Unit BLOB Param.':
                exit('NPR EFTType POSUnit BLOBParam.');
            'EFT Type Payment Gen. Param.':
                exit('NPR EFT Type Pay. Gen. Param.');
            'EFT Type POS Unit Gen. Param.':
                exit('NPR EFTType POSUnit Gen.Param.');
            'Pepper EFT Transaction Subtype':
                exit('NPR Pepper EFT Trx Subtype');
            'Pepper EFT Transaction Type':
                exit('NPR Pepper EFT Trx Type');
            'Pepper Configuration':
                exit('NPR Pepper Config.');
            'EFT Transaction Async Response':
                exit('NPR EFT Trx Async Resp.');
            'EFT Adyen Payment Type Setup':
                exit('NPR EFT Adyen Paym. Type Setup');
            'EFT BIN Group Payment Link':
                exit('NPR EFT BIN Group Paym. Link');
            'EFT Verifone Payment Parameter':
                exit('NPR EFT Verifone Paym. Param.');
            'EFT Verifone Unit Parameter':
                exit('NPR EFT Verifone Unit Param.');
            'EFT Transaction Async Request':
                exit('NPR EFT Trx Async Req.');
            'EFT NETS Cloud Payment Setup':
                exit('NPR EFT NETS Cloud Paym. Setup');
            'EFT NETS BAXI Payment Setup':
                exit('NPR EFT NETS BAXI Paym. Setup');
            'EFT NETS Cloud POS Unit Setup':
                exit('NPR EFT NETSCloud Unit Setup');
            else
                exit(TableName);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnTranslateRecordIDValue(RecordIDValue: Text; var NewRecordIDValue: Text; var Handled: Boolean)
    begin
    end;
}