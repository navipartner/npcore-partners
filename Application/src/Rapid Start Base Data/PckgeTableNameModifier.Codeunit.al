codeunit 6014596 "NPR Pckge Table Name Modifier"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Config. XML Exchange", 'OnBeforeGetElementName', '', false, false)]
    local procedure AdjustXMLElementName(var NameIn: Text[250])
    begin
        NameIn := GetLegacyNPRTableFieldName(NameIn);
    end;

    [EventSubscriber(ObjectType::Table, database::"Config. Package", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SetMinCountForAsyncImport(var Rec: Record "Config. Package")
    begin
        Rec."Min. Count For Async Import" := 2147483647;
    end;

    procedure GetLegacyNPRTableFieldName(NewName: Text[250]): Text[250]
    begin
        if (CopyStr(NewName, 1, 4) <> 'NPR ') or (StrLen(NewName) < 5) then
            exit(NewName);

        case NewName of
            //Tables
            'NPR Mixed Disc. Time Interv.':
                exit('Mixed Discount Time Interval');
            'NPR Mixed Disc. Prio. Buffer':
                exit('Mixed Discount Priority Buffer');
            'NPR Line Dimension':
                exit('NPR Line Dimension');
            'NPR Posted Doc. Buffer':
                exit('Posted Document Buffer');
            'NPR TM Adm. Dependency':
                exit('Touch Screen - Menu Lines');
            'NPR Touch Screen: Meta Func.':
                exit('Touch Screen - Meta Functions');
            'NPR TM Adm. Dependency Line':
                exit('NPR TM Adm. Dependency Line');
            'NPR CleanCash Trans. Request':
                exit('NPR CleanCash Trans. Request');
            'NPR Touch Screen: MetaTriggers':
                exit('Touch Screen - MetaTriggers');
            'Touch Screen - Meta F. Trans':
                exit('Touch Screen - Meta F. Trans');
            'NPR Scanner: Field Setup':
                exit('Scanner - Field Setup');
            'NPR TEMP Buffer':
                exit('NPR - TEMP Buffer');
            'NPR Imp. Exp. Media Buffer':
                exit('Import Export Media Buffer');
            'NPR Pakke Foreign Shipm. Map.':
                exit('Pakke Foreign Shipment Mapping');
            'NPR CleanCash Trans. VAT':
                exit('Shoe Shelves');
            'NPR CleanCash Trans. Response':
                exit('Shelves / Item Grp. Relation');
            'NPR E-mail Templ. Report':
                exit('E-mail Template Report');
            'NPR E-mail Templ. Line':
                exit('E-mail Template Line');
            'NPR SalesPost Pdf2Nav Setup':
                exit('Sales-Post and Pdf2Nav Setup');
            'NPR Pacsoft Shipm. Doc. Serv.':
                exit('Pacsoft Shipment Doc. Services');
            'NPR Pacsoft Package Code':
                exit('Shipping Package Code');
            'NPR Item Repl. by Store':
                exit('Item Replenishment by Store');
            'NPR Archive POS Info Trx':
                exit('Archive POS Info Transaction');
            'NPR Archive NpRv SL POS Vouch.':
                exit('Archive NpRv SL POS Voucher');
            'NPR Arch. NpRv SL POS Ref.':
                exit('Archive NpRv SL POS Reference');
            'NPR Arch. NpIa SL POS AddOn':
                exit('Archive NpIa SL POS AddOn');
            'NPR Arch. Retail Cross Ref.':
                exit('Archive Retail Cross Reference');
            'NPR Arch.NpDc SL POS NewCoupon':
                exit('Archive NpDc SL POS New Coupon');
            'NPR Retail Contr. Setup':
                exit('Retail Contract Setup');
            'NPR Report Selection: Contract':
                exit('Report Selection - Contract');
            'NPR BTF Service Setup':
                exit('BC Webhook Logger');
            'NPR BTF Service EndPoint':
                exit('BC Webhook Setup');
            'NPR BTF EndPoint Error Log':
                exit('Shipmondo Shipping Agent');
            'NPR Package Module Config.':
                exit('Package Module Configuration');
            'NPR Attribute':
                exit('NPR Attribute');
            'NPR Attribute Translation':
                exit('NPR Attribute Translation');
            'NPR Attribute ID':
                exit('NPR Attribute ID');
            'NPR Attribute Value Set':
                exit('NPR Attribute Value Set');
            'NPR Attribute Key':
                exit('NPR Attribute Key');
            'NPR Attribute Lookup Value':
                exit('NPR Attribute Lookup Value');
            'NPR RP Data Item Constr.':
                exit('RP Data Item Constraint');
            'NPR RP Data Item Constr. Links':
                exit('RP Data Item Constraint Links');
            'NPR RP DataJoin Rec.ID Buffer':
                exit('RP Data Join Record ID Buffer');
            'NPR RP Imp. Worksh.':
                exit('RP Import Worksheet');
            'NPR Sales Stats Time Period':
                exit('Sales Statistics Time Period');
            'NPR Dependency Mgt. Setup':
                exit('Dependency Management Setup');
            'NPR Tax Free Handler Param.':
                exit('Tax Free Handler Parameters');
            'NPR Tax Free GB I2 Param.':
                exit('Tax Free GB I2 Parameter');
            'NPR TaxFree GB I2 Info Capt.':
                exit('Tax Free GB I2 Info Capture');
            'NPR TaxFree GB BlockedCountry':
                exit('Tax Free GB Blocked Country');
            'NPR Member Card Trx Log':
                exit('Member Card Transaction Log');
            'NPR Part. Sync Fields Prof.':
                exit('Partial Sync Fields Profile');
            'NPR Sales Price Maint. Setup':
                exit('Sales Price Maintenance Setup');
            'NPR Sales Price Maint. Groups':
                exit('Sales Price Maintenance Groups');
            'NPR Ticket Access Cap. Slots':
                exit('Ticket Access Capacity Slots');
            'NPR Ticket Access Reserv.':
                exit('Ticket Access Reservation');
            'NPR Trx Email Setup':
                exit('Transactional Email Setup');
            'NPR Trx Email Log':
                exit('Transactional Email Log');
            'NPR Trx JSON Result':
                exit('Transactional JSON Result');
            'NPR Data Log Setup (Field)':
                exit('NPR Data Log Setup (Field)');
            'NPR Facial Recognition':
                exit('NPR Facial Recognition');
            'NPR Facial Recogn. Setup':
                exit('NPR Facial Recogn. Setup');
            'NPR RSS Feed Channel Sub.':
                exit('RSS Feed Channel Subscription');
            'NPR MCS Webcam Arg. Table':
                exit('MCS Webcam Argument Table');
            'NPR MCS Person Bus. Entit.':
                exit('MCS Person Business Entities');
            'NPR Item Worksh. Template':
                exit('Item Worksheet Template');
            'NPR Item Worksh. Variant Line':
                exit('Item Worksheet Variant Line');
            'NPR Item Worksh. Variety Value':
                exit('Item Worksheet Variety Value');
            'NPR Registered Item Works.':
                exit('Registered Item Worksheet');
            'NPR Regist. Item Worksh Line':
                exit('Registered Item Worksheet Line');
            'NPR Reg. Item Wsht Var. Line':
                exit('Reg. Item Wsht Variant Line');
            'NPR Reg. Item Wsht Var. Value':
                exit('Reg. Item Wsht Variety Value');
            'NPR Item Worksh. Excel Column':
                exit('Item Worksheet Excel Column');
            'NPR Item Worksh. Field Setup':
                exit('Item Worksheet Field Setup');
            'NPR Item Worksh. Field Change':
                exit('Item Worksheet Field Change');
            'NPR Item Worksh. Field Mapping':
                exit('Item Worksheet Field Mapping');
            'NPR Inv. Overview Line':
                exit('Inventory Overview Line');
            'NPR Item Worksh. Vrty Mapping':
                exit('Item Worksheet Variety Mapping');
            'NPR MCS Recomm. Model':
                exit('MCS Recommendations Model');
            'NPR MCS Rec. Bus. Rule':
                exit('MCS Rec. Business Rule');
            'NPR MM Admis. Service Setup':
                exit('MM Admission Service Setup');
            'NPR MM Admis. Service Entry':
                exit('MM Admission Service Entry');
            'NPR MM Admis. Service Log':
                exit('MM Admission Service Log');
            'NPR MM Recur. Paym. Setup':
                exit('MM Recurring Payment Setup');
            'NPR MM Payment Reconci.':
                exit('MM Payment Reconciliation');
            'NPR MM Admis. Scanner Stations':
                exit('MM Admission Scanner Stations');
            'NPR TM Offline Ticket Valid.':
                exit('TM Offline Ticket Validation');
            'NPR TM Ticket Notif. Entry':
                exit('TM Ticket Notification Entry');
            'NPR TM Ticket Particpt. Wks.':
                exit('TM Ticket Participant Wks.');
            'NPR TM Ticket Access Stats':
                exit('TM Ticket Access Statistics');
            'NPR TM Ticket Reservation Req.':
                exit('TM Ticket Reservation Request');
            'NPR TM Ticket Reserv. Resp.':
                exit('TM Ticket Reservation Response');
            'NPR TM Admis. Schedule':
                exit('TM Admission Schedule');
            'NPR TM Admis. Schedule Lines':
                exit('TM Admission Schedule Lines');
            'NPR TM Admis. Schedule Entry':
                exit('TM Admission Schedule Entry');
            'NPR TM Det. Ticket AccessEntry':
                exit('TM Det. Ticket Access Entry');
            'NPR MM Members. Sales Setup':
                exit('MM Membership Sales Setup');
            'NPR MM Members. Points Entry':
                exit('MM Membership Points Entry');
            'NPR MM Members. Admis. Setup':
                exit('MM Membership Admission Setup');
            'NPR MM Members. Alter. Setup':
                exit('MM Membership Alteration Setup');
            'NPR MM Member Notific. Setup':
                exit('MM Member Notification Setup');
            'NPR MM Membership Notific.':
                exit('MM Membership Notification');
            'NPR MM Member Notific. Entry':
                exit('MM Member Notification Entry');
            'NPR MM Loyalty Point Setup':
                exit('MM Loyalty Points Setup');
            'NPR MM Loy. Item Point Setup':
                exit('MM Loyalty Item Point Setup');
            'NPR MM Foreign Members. Setup':
                exit('MM Foreign Membership Setup');
            'NPR MM Membership Lim. Setup':
                exit('MM Membership Limitation Setup');
            'NPR MM Member Arr. Log Entry':
                exit('MM Member Arrival Log Entry');
            'NPR MM NPR Remote Endp. Setup':
                exit('MM NPR Remote Endpoint Setup');
            'NPR RC Members. Burndown Setup':
                exit('RC Membership Burndown Setup');
            'NPR Event Att. Row Templ.':
                exit('Event Attribute Row Template');
            'NPR Event Attr. Col. Template':
                exit('Event Attribute Col. Template');
            'NPR Event Attr. Row Value':
                exit('Event Attribute Row Value');
            'NPR Event Attr. Column Value':
                exit('Event Attribute Column Value');
            'NPR Event Plan. Line Buffer':
                exit('Event Planning Line Buffer');
            'NPR Event Exch.Int.Temp.Entry':
                exit('Event Exch. Int. Temp. Entry');
            'NPR Event Attr. Temp. Filter':
                exit('Event Attribute Temp. Filter');
            'NPR Event Exc.Int.Summ. Buffer':
                exit('Event Exc. Int. Summary Buffer');
            'NPR POS Entry Comm. Line':
                exit('POS Entry Comment Line');
            'NPR POS Payment Bin Checkp.':
                exit('POS Payment Bin Checkpoint');
            'NPR POS Worksh. Tax Checkp.':
                exit('POS Workshift Tax Checkpoint');
            'NPR POS Paym. Bin Eject Param.':
                exit('POS Payment Bin Eject Param.');
            'NPR POS Paym. Bin Denomin.':
                exit('POS Payment Bin Denomination');
            'NPR POS Unit Rcpt.Txt Profile':
                exit('POS Unit Receipt Text Profile');
            'NPR POS NPRE Rest. Profile':
                exit('POS NPRE Restaurant Profile');
            'NPR NPRE Seat.: WaiterPadLink':
                exit('NPRE Seating - Waiter Pad Link');
            'NPR NPRE Print/Prod. Cat.':
                exit('NPRE Print/Prod. Category');
            'NPR NPRE Print Templ.':
                exit('NPRE Print Template');
            'NPR NPRE Assign. Print Cat.':
                exit('NPRE Assigned Print Category');
            'NPR NPRE W.Pad Prnt LogEntry':
                exit('NPRE W.Pad Line Prnt Log Entry');
            'NPR NPRE W.Pad.Line Outp.Buf.':
                exit('NPRE W.Pad Line Output Buffer');
            'NPR NPRE Serv.Flow Profile':
                exit('NPRE Service Flow Profile');
            'NPR NPRE Kitchen Req.Src. Link':
                exit('NPRE Kitchen Req. Source Link');
            'NPR NPRE Kitchen Req. Station':
                exit('NPRE Kitchen Request Station');
            'NPR NPRE Kitchen Station Slct.':
                exit('NPRE Kitchen Station Selection');
            'NPR Audit Roll 2 POSEntry Link':
                exit('Audit Roll to POS Entry Link');
            'NPR Data Model Upg. Log Entry':
                exit('Data Model Upgrade Log Entry');
            'NPR POS Data Source Discovery':
                exit('POS Data Source (Discovery)');
            'NPR POS Stargate Pckg. Method':
                exit('POS Stargate Package Method');
            'NPR POS Keyboard Bind. Setup':
                exit('POS Keyboard Binding Setup');
            'NPR POS Stargate Assem. Map':
                exit('POS Stargate Assembly Map');
            'NPR POS Sales WF Set Entry':
                exit('POS Sales Workflow Set Entry');
            'NPR POS Admin. Template':
                exit('POS Administrative Template');
            'NPR HC Paym.Type Post.Setup':
                exit('HC Payment Type Posting Setup');
            'NPR Upgrade History':
                exit('NPR Upgrade History');
            'NPR NpRv Ret. Vouch. Type':
                exit('NpRv Return Voucher Type');
            'NPR NpRv Sales Line Ref.':
                exit('NpRv Sales Line Reference');
            'NPR NpRv Global Vouch. Setup':
                exit('NpRv Global Voucher Setup');
            'NPR POS Paym. View Log Entry':
                exit('POS Payment View Log Entry');
            'NPR POS Paym. View Event Setup':
                exit('POS Payment View Event Setup');
            'NPR Distrib. Group':
                exit('Distribution Group');
            'NPR Distrib. Group Members':
                exit('Distribution Group Members');
            'NPR Retail Repl. Demand Line':
                exit('Retai Repl. Demand Line');
            'NPR RIS Retail Inv. Set':
                exit('RIS Retail Inventory Set');
            'NPR RIS Retail Inv. Set Entry':
                exit('RIS Retail Inventory Set Entry');
            'NPR RIS Retail Inv. Buffer':
                exit('RIS Retail Inventory Buffer');
            'NPR Nc RapidConnect Trig.Table':
                exit('Nc RapidConnect Trigger Table');
            'NPR Nc RapidConn. Endpoint':
                exit('Nc RapidConnect Endpoint');
            'NPR Nc RapidConnect Trig.Field':
                exit('Nc RapidConnect Trigger Field');
            'NPR NpRi Reimbursement Templ.':
                exit('NpRi Reimbursement Template');
            'NPR NpRi Purch.Doc.Disc. Setup':
                exit('NpRi Purch. Doc. Disc. Setup');
            'NPR NpIa SaleLinePOS AddOn':
                exit('NpIa Sale Line POS AddOn');
            'NPR NpIa ItemAddOn Line Opt.':
                exit('NpIa Item AddOn Line Option');
            'NPR NpIa ItemAddOn Line Setup':
                exit('NpIa Item AddOn Line Setup');
            'NPR TM Seating Attr. Defin.':
                exit('TM Seating Attr. Definition');
            'NPR TM Seating Reserv. Entry':
                exit('TM Seating Reservation Entry');
            'NPR TM Concurrent Admis. Setup':
                exit('TM Concurrent Admission Setup');
            'NPR TM Ticket Wait. List':
                exit('TM Ticket Waiting List');
            'NPR M2 Price Calc. Buffer':
                exit('M2 Price Calculation Buffer');
            'NPR MM Reg. Sales Buffer':
                exit('MM Register Sales Buffer');
            'NPR MM Loy. LedgerEntry (Srvr)':
                exit('MM Loyalty Ledger Entry (Srvr)');
            'NPR MM Loyalty Alter Members.':
                exit('MM Loyalty Alter Membership');
            'NPR MM Members. Points Summary':
                exit('MM Membership Points Summary');
            'NPR NpGp Det. POS Sales Entry':
                exit('NpGp Detailed POS Sales Entry');
            'NPR Retail Cross Ref. Setup':
                exit('Retail Cross Reference Setup');
            'NPR MM Sponsors. Ticket Setup':
                exit('MM Sponsorship Ticket Setup');
            'NPR MM Sponsors. Ticket Entry':
                exit('MM Sponsorship Ticket Entry');
            'NPR MM Member Comm. Setup':
                exit('MM Member Communication Setup');
            'NPR NpCs Store Workflow Rel.':
                exit('NpCs Store Workflow Relation');
            'NPR NpCs Arch. Doc. Log Entry':
                exit('NpCs Arch. Document Log Entry');
            'NPR NpCs Sale Line POS Ref.':
                exit('NpCs Sale Line POS Reference');
            'NPR NpCs Store Inv. Buffer':
                exit('NpCs Store Inventory Buffer');
            'NPR NpCs Open. Hour Cal. Entry':
                exit('NpCs Open. Hour Calendar Entry');
            'NPR Web Sales':
                exit('NPR Web Sales');
            'NPR POS Entry Cue.':
                exit('NPR POS Entry Cue.');
            'NPR NP Retail Admin Cue':
                exit('NPR NP Retail Admin Cue');
            'NPR Trail. Purch. Orders Setup':
                exit('NPR Trail. Purch. Orders Setup');
            'NPR Retail Entertainment Cue':
                exit('NPR Retail Entertainment Cue');
            'NPR Restaurant Cue':
                exit('NPR Restaurant Cue');
            'NPR CS Wareh. Activ. Setup':
                exit('CS Warehouse Activity Setup');
            'NPR CS Transf. Handl. Rfid':
                exit('CS Transfer Handling Rfid');
            'NPR CS Comm. Log':
                exit('CS Communication Log');
            'NPR CS Wareh. Activ. Handling':
                exit('CS Warehouse Activity Handling');
            'NPR CS Wareh. Receipt Handl.':
                exit('CS Warehouse Receipt Handling');
            'NPR CS Transf. Order Handl.':
                exit('CS Transfer Order Handling');
            'NPR CS Price Check Handl.':
                exit('CS Price Check Handling');
            'NPR CS Item Search Handl.':
                exit('CS Item Seach Handling');
            'NPR CS Rfid Item Handl.':
                exit('CS Rfid Item Handling');
            'NPR CS Stock-Take Handl. Rfid':
                exit('CS Stock-Take Handling Rfid');
            'NPR CS Warehouse Shipm. Handl.':
                exit('CS Warehouse Shipment Handling');
            'NPR CS Phys. Inv. Handl.':
                exit('CS Phys. Inventory Handling');
            'NPR Magento Gen. Setup Buffer':
                exit('Magento Generic Setup Buffer');
            'NPR Magento VAT Bus. Group':
                exit('Magento VAT Business Group');
            'NPR Magento VAT Prod. Group':
                exit('Magento VAT Product Group');
            'NPR Magento Inv. Company':
                exit('Magento Inventory Company');
            'NPR Magento Custom Optn. Value':
                exit('Magento Custom Option Value');
            'NPR Magento Itm Cstm Opt.Value':
                exit('Magento Item Custom Opt. Value');
            'NPR Magento Attr. Label':
                exit('Magento Attribute Label');
            'NPR Magento Attr. Set Value':
                exit('Magento Attribute Set Value');
            'NPR Magento Item Attr.':
                exit('Magento Item Attribute');
            'NPR Magento Item Attr. Value':
                exit('Magento Item Attribute Value');
            'NPR Magento Contact Pmt.Meth.':
                exit('Magento Contact Pmt. Method');
            'NPR Magento Contact Shpt.Meth.':
                exit('Magento Contact Shpt. Method');
            'NPR Magento Contact ShipToAdr.':
                exit('Magento Contact Ship-to Adrs.');
            'NPR Text Editor Dialog Option':
                exit('NPR Text Editor Dialog Option');
            'NPR Magento PostOnImport Setup':
                exit('Magento Post on Import Setup');
            'NPR Nc Collector Req. Filter':
                exit('Nc Collector Request Filter');
            'NPR NpXml Templ.Trigger Link':
                exit('NpXml Template Trigger Link');
            'NPR NpXml Custom Val. Buffer':
                exit('NpXml Custom Value Buffer');
            'NPR NpXml Field Val. Buffer':
                exit('NpXml Field Value Buffer');
            'NPR NpXml Template Arch.':
                exit('NpXml Template Archive');
            'NPR AF Args: Spire Barcode':
                exit('AF Arguments - Spire Barcode');
            'NPR AF Arguments - Notific.Hub':
                exit('AF Arguments - NotificationHub');
            'NPR NpDc SaleLinePOS Coupon':
                exit('NpDc Sale Line POS Coupon');
            'NPR NpDc Arch.Coupon Entry':
                exit('NpDc Arch. Coupon Entry');
            'NPR NpDc Iss.OnSale Setup':
                exit('NpDc Issue On-Sale Setup');
            'NPR NpDc Iss.OnSale Setup Line':
                exit('NpDc Issue On-Sale Setup Line');
            'NPR NpDc SaleLinePOS NewCoupon':
                exit('NpDc Sale Line POS New Coupon');
            'NPR NpDc Ext. Coupon Reserv.':
                exit('NpDc Ext. Coupon Reservation');
            'NPR EFTType Paym. BLOB Param.':
                exit('EFT Type Payment BLOB Param.');
            'NPR EFTType POSUnit BLOBParam.':
                exit('EFT Type POS Unit BLOB Param.');
            'NPR EFT Type Pay. Gen. Param.':
                exit('EFT Type Payment Gen. Param.');
            'NPR EFTType POSUnit Gen.Param.':
                exit('EFT Type POS Unit Gen. Param.');
            'NPR Pepper EFT Trx Subtype':
                exit('Pepper EFT Transaction Subtype');
            'NPR Pepper EFT Trx Type':
                exit('Pepper EFT Transaction Type');
            'NPR Pepper Config.':
                exit('Pepper Configuration');
            'NPR EFT Trx Async Resp.':
                exit('EFT Transaction Async Response');
            'NPR EFT Adyen Paym. Type Setup':
                exit('EFT Adyen Payment Type Setup');
            'NPR EFT BIN Group Paym. Link':
                exit('EFT BIN Group Payment Link');
            'NPR EFT Verifone Paym. Param.':
                exit('EFT Verifone Payment Parameter');
            'NPR EFT Verifone Unit Param.':
                exit('EFT Verifone Unit Parameter');
            'NPR EFT Trx Async Req.':
                exit('EFT Transaction Async Request');
            'NPR EFT NETS Cloud Paym. Setup':
                exit('EFT NETS Cloud Payment Setup');
            'NPR EFT NETS BAXI Paym. Setup':
                exit('EFT NETS BAXI Payment Setup');
            'NPR EFT NETSCloud Unit Setup':
                exit('EFT NETS Cloud POS Unit Setup');
            'NPR Azure Storage Cogn. Search':
                exit('Azure Storage Cognitive Search');
            'NPR Storage Operation Param.':
                exit('Storage Operation Parameter');

            //Fields
            'NPR Version':
                exit('NPR Version');

            //General conversion rule
            else
                exit(CopyStr(NewName, 5, 250));
        end;
    end;
}
