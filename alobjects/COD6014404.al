codeunit 6014404 "NPR Event Subscriber"
{
    // 
    // ???
    // Check code marked with ToCheck
    // ???
    // 
    // --Table 13 Salesperson/Purchaser--
    // NPR7.100.000/LS/220114  : Retail Merge
    //                           OnDelete()
    // NPR-3.0
    // 
    // --Table 23 Vendor--
    // NPR4.14/RMT/20150824
    // 
    // --Table 37 Sales Line--
    // NPR5.22/TJ/20160406 CASE 236840 Moved code from standard table to here
    // 
    // --Table 81 Gen. Journal Line--
    // NPR-3.0
    // 
    // --Table 5050 Contact--
    // NPR7.100.000/LS/220114  : Retail Merge
    // 
    // --Codeunit 1 ApplicationManagement--
    // Following comments are from Codeunit 40 LoginManagement but are moved to standard events in C1:
    // NPR70.00.00.01/TS/20150126  CASE 205063 Added code to check if Do no use hot keys at start is set to FALSE for it to be running
    // NPR70.00.00.02/MH/20150226  CASE 206977 Updated Hotkey Management
    // NPR4.14/BHR/20150624 CASE 216714 Check if licence is a retail license to execute code
    // NPR4.16/JDH/20151022 CASE 225652 If "Register Time" is activated, an error occurs if a change company is done
    // NPR5.00/JDH/20160113 CASE 231550 Hotkey management removed (will be part of the Windows app)
    // 
    // Following comments are from Codeunit 42 CaptionManagement but are moved to standard events in C1:
    // NPR5.22/RMT/20150401 Case 209946 - captions for custom record fields
    // 
    // --Codeunit 11 Gen. Jnl.-Check Line--
    // NPR7.100.000/LS/220114  : Retail Merge
    // 
    // --Codeunit 21 Item Jnl.-Check Line--
    // NPR7.100.000/LS/220114  : Retail Merge
    // 
    // --Codeunit 22 Item Jnl.-Post Line--
    // NPR7.100.000/LS/220114  : Retail Merge:
    //                                        Function Modified : LOCAL UpdateUnitCost
    //                                                            InsertTransferEntry
    //                                                            InitItemLedgEntry
    //                                                            InsertItemReg
    //                                                            InitValueEntry
    // --Codeunit 80 Sales-Post--
    // NPR7.100.000/LS/220114  : Retail Merge
    // PS1.01/LS/20141216   CASE 200974 Allow automatic creation of Pacsoft Shipment Document when shipment created
    //                                  Added codes + Local Variables
    // 
    // --Page 30 Item Card--
    // NPR4.10/TSA/20150422 CASE 209946 - Shortcut Attributes
    // NPR4.11/TSA/20150625 CASE 209946 - Shortcut Attributes
    // 
    // --Page 40 Item Journal--
    // NPR7.100.000
    // 
    // --Page 52 Purchase Credit Memo--
    // NPR4.18/TS/20151109  CASE 222241 Added Action Import From Text
    // 
    // --Page 130 Posted Sales Shipment--
    // PS1.00/LS/20140509  CASE 190533
    // 
    // --Page 291 Req. Worksheet--
    // NPR4.04/TS/20150218  CASE 206013 Added FUnction Read From Scanner
    // 
    // --Page 5740 Transfer Order--
    // NPR4.04/TS/20150218 CASE 206013 Added Function Read from Scanner
    // NPR4.18/TS/20151109 CASE 222241 Added Action Import From Text
    // 
    // --Page 9506 Session List--
    // NPR70.00.00.00/TS/20150126 CASE 205355  Added Kill Session
    // 
    // NPR5.22/RA/20160420  CASE 237639 Consignor on post
    // NPR5.23/THRO/20160509 CASE 240777 Subscriber for Item Journal Line Cross Reference No
    // NPR5.23/JDH /20160525 CASE 241673 Moved Item, GL, Purchase and customer to individual subscriber CU's
    // NPR5.22.01/JDH /20160530 CASE 242940 moved Variety functionality to Variety Wrapper codeunit
    // NPR5.23/TSA/20160603 CASE 242867 tooke out C1OnAfterCaptionClassTranslate and moved it to codeunit 6014555
    // NPR5.23/THRO/20160603 CASE 236043 Removed call to NaviDocs
    // NPR5.23/TS/20160609  CASE 243598 Added Events Function P42OnAferActionEventImportFromScanner
    // NPR5.26/MHA /20160922  CASE 252881 Functions deleted - replaced by Local Subscriber function in Codeunit 6014437 Phone Lookup: T23OnBeforeInsertEvent(), T5050OnBeforeInsertEvent(), P5050OnInsertRecordEvent()
    // NPR5.26/BHR/20160831 CASE 248912 Creation of Pakklabels
    // NPR5.29/BHR/20160831 CASE 248912 Code commented
    // NPR5.29/MMV /20170111 CASE 261097 Cleaned up OnAfterCompanyOpen/Close subscriber: Exit out as soon as possible based on the client type.
    // NPR5.30/TJ  /20170221 CASE 266258 Removed subscriber P40OnAfterActionEventImportFromScanner
    // NPR5.30/TJ  /20170222 CASE 266874 Removed subscribers T81OnAfterValidateEventGiftVoucher, T81OnAfterValidateEventCreditNote and C11OnAfterCheckGenJnlLine
    // NPR5.30/TJ  /20170303 CASE 267710 Added subscriber to codeunit 1, function OnAfterFindPrinter
    // NPR5.31/BR  /20170424 CASE 272843 Added subscriber OnActionInsertLinewithVendorItem
    // NPR5.32/JDH /20170511 CASE 249432 Changed login and logout From "OnAfterCompanyOpen" to "OnBeforeCompanyOpen" - same for Closing Company to avoid COMMIT
    //                                   moved code from a lot of sub functions to this codeunit
    // NPR5.33/TR  /20170602 CASE 264324 Added code in eventsubscriber C22OnBeforeInsertValueEntry such that Item Group is inserted, if blank, on Value Entries.
    // NPR5.33/BR  /20170616 CASE 272843 Keep adding lines until the user presses cancel, validate qty. 1
    // NPR5.34/BR  /20170703 CASE 282922 Prompt for Quantity
    // NPR5.38/CLVA/20171109 CASE 293179 Collecting client-side information
    // NPR5.38/BR  /20171123 CASE 295074 Show POS Action Parameter login Page
    // NPR5.38/TS  /20171128 CASE 296801 Added Action Import From Scanner P50OnAfterActionEventImportFromScannerFile
    // NPR5.38/BR  /20171201 CASE 298368 Added subscriber P42OnAfterActionInsertLinewithItem
    // NPR5.38/CLVA/20171211 CASE 293179 Added subscriber P6014651OnOpenPageEvent and P6150700OnOpenPageEvent
    // NPR5.38/LS  /20171218 CASE 300124 Set property OnMissingLicense to Skip for function C1OnBeforeCompanyClose
    // NPR5.38/MMV /20180119 CASE 300683 Skip subscriber when installing extension
    // NPR5.39/TJ  /20180208 CASE 302634 Updated EventPublisherElement property on subscriber P291OnAfterActionEventReadFromScanner since the name changed on page 291
    // NPR5.39/MMV /20180212 CASE 299114 Rolling back previous parameter upgrade approach
    // NPR5.40/MHA /20180328 CASE 308907 Deleted functions P6014651OnOpenPageEvent(),P6150700OnOpenPageEvent(),C1OnBeforeCompanyClose()
    // NPR5.40.01  /20180410 CASE 309599 Deleted IC functionality call that was discontinued in 5.40
    // NPR5.43/ZESO/20182906 CASE 312575 Added field Item Category Code
    // NPR5.44/JDH /20180726 CASE 323366 Fixed 2 subscribers that was not triggered due to an update of the publisher
    // NPR5.45/TS  /20180829 CASE 324592 Added Action Import from Scanner
    // TM1.39/THRO/20181126 CASE 334644 Replaced Coudeunit 1 by Wrapper Codeunit
    // NPR5.49/BHR /20171128 CASE 296801 Rename P43OnAfterActionEventImportFromScannerFile to P49OnAfterActionEventImportFromScannerFile
    //                                   Added Action Import From Scanner P43OnAfterActionEventImportFromScannerFile


    trigger OnRun()
    begin
    end;

    var
        RegisterCodeAlreadyUsed: Label 'Register Code %1 already exists.';
        SalesPersonDeleteError: Label 'you cannot delete Salesperson/purchaser %1 before the sale is posted in the Audit roll!';

    local procedure "--Table 13 Salesperson/Purchaser--"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 13, 'OnAfterDeleteEvent', '', true, false)]
    local procedure T13OnAfterDeleteEvent(var Rec: Record "Salesperson/Purchaser"; RunTrigger: Boolean)
    var
        AuditRoll: Record "Audit Roll";
    begin
        //-NPR5.32 [249432]
        //IF RunTrigger THEN
        //-NPR7.100.000
        //  RetailCode.SIOnDelete(Rec);
        //+NPR7.100.000

        if RunTrigger then begin
            with Rec do begin
                AuditRoll.SetRange(Posted, false);
                AuditRoll.SetRange("Salesperson Code", Code);
                if not AuditRoll.IsEmpty then
                    Error(SalesPersonDeleteError, Code);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 13, 'OnAfterValidateEvent', 'Register Password', true, false)]
    local procedure T13OnAfterValidateEventRegisterPassword(var Rec: Record "Salesperson/Purchaser"; var xRec: Record "Salesperson/Purchaser"; CurrFieldNo: Integer)
    begin
        //-NPR5.32 [249432]
        //-NPR-3.0
        //RetailCode.SIKassekodeOV(Rec);
        //+NPR-3.0
        with Rec do begin
            SetRange("Register Password", "Register Password");
            if not IsEmpty then
                Error(RegisterCodeAlreadyUsed, "Register Password");
        end;
        //+NPR5.32 [249432]
    end;

    local procedure "--Table 83 Item Journal Line--"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 83, 'OnAfterValidateEvent', 'Cross-Reference No.', false, false)]
    local procedure T83OnAfterValidateEventCrossReferenceNo(var Rec: Record "Item Journal Line"; var xRec: Record "Item Journal Line"; CurrFieldNo: Integer)
    var
        StdTableCode: Codeunit "Std. Table Code";
    begin
        //-240777
        StdTableCode.ItemJnlLineCrossReferenceOV(Rec, xRec);
        //+240777
    end;

    local procedure "--Table 352 Default Dimension--"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 352, 'OnAfterInsertEvent', '', false, false)]
    local procedure T352OnAfterInsertEvent(var Rec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        StdTableCode: Codeunit "Std. Table Code";
        GLSetup: Record "General Ledger Setup";
    begin
        if RunTrigger then begin
            GLSetup.Get;
            if Rec."Dimension Code" = GLSetup."Global Dimension 1 Code" then
                StdTableCode.UpdateGlobalDimCode(1, Rec."Table ID", Rec."No.", Rec."Dimension Value Code");
            if Rec."Dimension Code" = GLSetup."Global Dimension 2 Code" then
                StdTableCode.UpdateGlobalDimCode(2, Rec."Table ID", Rec."No.", Rec."Dimension Value Code");
        end;
    end;

    [EventSubscriber(ObjectType::Table, 352, 'OnAfterModifyEvent', '', false, false)]
    local procedure T352OnAfterModifyEvent(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        StdTableCode: Codeunit "Std. Table Code";
        GLSetup: Record "General Ledger Setup";
    begin
        if RunTrigger then begin
            GLSetup.Get;
            if Rec."Dimension Code" = GLSetup."Global Dimension 1 Code" then
                StdTableCode.UpdateGlobalDimCode(1, Rec."Table ID", Rec."No.", Rec."Dimension Value Code");
            if Rec."Dimension Code" = GLSetup."Global Dimension 2 Code" then
                StdTableCode.UpdateGlobalDimCode(2, Rec."Table ID", Rec."No.", Rec."Dimension Value Code");
        end;
    end;

    [EventSubscriber(ObjectType::Table, 352, 'OnAfterDeleteEvent', '', false, false)]
    local procedure T352OnAfterDeleteEvent(var Rec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        StdTableCode: Codeunit "Std. Table Code";
        GLSetup: Record "General Ledger Setup";
    begin
        if RunTrigger then begin
            GLSetup.Get;
            if Rec."Dimension Code" = GLSetup."Global Dimension 1 Code" then
                StdTableCode.UpdateGlobalDimCode(1, Rec."Table ID", Rec."No.", '');
            if Rec."Dimension Code" = GLSetup."Global Dimension 2 Code" then
                StdTableCode.UpdateGlobalDimCode(2, Rec."Table ID", Rec."No.", '');
        end;
    end;

    local procedure "--Codeunit 1 ApplicationManagement--"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnBeforeCompanyOpen', '', true, false)]
    local procedure C1OnBeforeCompanyOpen()
    var
        ServiceTierUserManagement: Codeunit "Service Tier User Management";
        NPRetailSetup: Record "NP Retail Setup";
        NavAppMgt: Codeunit "Nav App Mgt";
    begin
        //-NPR5.38 [300683]
        if NavAppMgt.NavAPP_IsInstalling then
            exit;
        //+NPR5.38 [300683]

        if not (CurrentClientType in [CLIENTTYPE::Windows, CLIENTTYPE::Web, CLIENTTYPE::Tablet, CLIENTTYPE::Phone, CLIENTTYPE::Desktop]) then
            exit;

        //-NPR5.40 [308907]
        //ServiceTierUserManagement.UseAction := 'Login';
        //IF ServiceTierUserManagement.RUN() THEN;
        //
        ////-NPR5.38
        //IF (CURRENTCLIENTTYPE IN [CLIENTTYPE::Web,CLIENTTYPE::Tablet,CLIENTTYPE::Phone]) THEN
        //  IF NPRetailSetup.FINDFIRST THEN
        //    IF NPRetailSetup."Enable Client Diagnostics" THEN
        //      IF (NPRetailSetup."Environment Type" IN [NPRetailSetup."Environment Type"::PROD,NPRetailSetup."Environment Type"::DEMO]) THEN
        //          PAGE.RUNMODAL(6059999);
        ////+NPR5.38
        if ServiceTierUserManagement.Run then;
        //+NPR5.40 [308907]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnAfterFindPrinter', '', false, false)]
    local procedure C1OnAfterFindPrinter(ReportID: Integer; var PrinterName: Text[250])
    var
        Printer: Record Printer;
        ObjectOutputMgt: Codeunit "Object Output Mgt.";
    begin
        //-NPR5.30 [267710]
        if PrinterName = '' then
            exit;
        Printer.SetRange(Name, PrinterName);
        if not Printer.IsEmpty then
            exit;
        PrinterName := ObjectOutputMgt.ResolvePrinterName(PrinterName);
        //+NPR5.30 [267710]
    end;

    local procedure "--Codeunit 22 Item Jnl.-Post Line--"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 22, 'OnBeforeInsertTransferEntry', '', true, false)]
    local procedure C22OnBeforeInsertTransferEntry(var NewItemLedgerEntry: Record "Item Ledger Entry"; var OldItemLedgerEntry: Record "Item Ledger Entry"; var ItemJournalLine: Record "Item Journal Line")
    var
        RetailCodeunitCode: Codeunit "Std. Codeunit Code";
        RetailSetup: Record "Retail Setup";
    begin
        //-NPR5.32 [249432]
        //ToCheck: Originally code was like this:
        //-NPR7.000.000
        //IF ApplicationManagement.CheckLicenseRetail THEN RetailCodeunitCode.Inds�tOverf�rselPost( NewItemLedgEntry, ItemLedgEntry );
        //+NPR7.000.000
        // but since we don't have a standard event with those parameters we can completelly remove this or try to use standard event:
        //-NPR7.000.000
        //RetailCodeunitCode.Inds�tOverf�rselPost(NewItemLedgerEntry,OldItemLedgerEntry);
        //+NPR7.000.000

        //Inds�tOverf�rselPost
        RetailSetup.Get;
        NewItemLedgerEntry."Vendor No." := OldItemLedgerEntry."Vendor No.";
        NewItemLedgerEntry."Item Group No." := OldItemLedgerEntry."Item Group No.";
        NewItemLedgerEntry."Register Number" := OldItemLedgerEntry."Register Number";
        NewItemLedgerEntry."Salesperson Code" := OldItemLedgerEntry."Salesperson Code";
        if RetailSetup."Transfer SeO Item Entry" then
            NewItemLedgerEntry."Cross-Reference No." := OldItemLedgerEntry."Cross-Reference No.";
        //+NPR5.32 [249432]
    end;

    [EventSubscriber(ObjectType::Codeunit, 22, 'OnBeforePostItemJnlLine', '', false, false)]
    local procedure C22OnBeforePostItemJnlLine(var ItemJournalLine: Record "Item Journal Line")
    var
        Item: Record Item;
    begin
        //-NPR5.33 [264324]
        if (ItemJournalLine."Vendor No." <> '') and (ItemJournalLine."Item Group No." <> '') then
            exit;
        if not Item.Get(ItemJournalLine."Item No.") then
            exit;

        if ItemJournalLine."Vendor No." = '' then
            ItemJournalLine."Vendor No." := Item."Vendor No.";
        if ItemJournalLine."Item Group No." = '' then
            ItemJournalLine."Item Group No." := Item."Item Group";
        //+NPR5.33 [264324]
    end;

    [EventSubscriber(ObjectType::Codeunit, 22, 'OnAfterInitItemLedgEntry', '', true, false)]
    local procedure C22OnAfterInitItemLedgEntry(var NewItemLedgEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line"; var ItemLedgEntryNo: Integer)
    var
        Item: Record Item;
    begin
        //-NPR5.32 [249432]

        //-NPR7.000.000
        //RetailCodeunitCode.Ops�tVarePost(NewItemLedgEntry,ItemJournalLine);
        //+NPR7.000.000

        with NewItemLedgEntry do begin
            //Ops�tning.GET;
            "Vendor No." := ItemJournalLine."Vendor No.";
            "Item Group No." := ItemJournalLine."Item Group No.";
            //not needed - its a standard field that is always transferred by CU22
            //IF Ops�tning."Transfer SeO Item Entry" THEN
            //  Varepost2."Cross-Reference No." := "Cross-Reference No.";
            "Discount Type" := ItemJournalLine."Discount Type";
            "Discount Code" := ItemJournalLine."Discount Code";
            "Register Number" := ItemJournalLine."Register Number";
            "Group Sale" := ItemJournalLine."Group Sale";
            "Salesperson Code" := ItemJournalLine."Salespers./Purch. Code";
            "Document Time" := ItemJournalLine."Document Time";

            //-NPR5.33 [264324]
            //  IF ("Vendor No." = '') OR ("Item Group No." = '') THEN
            //    IF Item.GET("Item No.") THEN BEGIN
            //      IF "Vendor No." = '' THEN
            //        "Vendor No." := Item."Vendor No.";
            //      IF "Item Group No." = '' THEN
            //        "Item Group No." := Item."Item Group";
            //    END;
            //+NPR5.33 [264324]
        end;
        //+NPR5.32 [249432]
    end;

    [EventSubscriber(ObjectType::Codeunit, 22, 'OnBeforeInsertValueEntry', '', false, false)]
    local procedure C22OnBeforeInsertValueEntry(var ValueEntry: Record "Value Entry"; ItemJournalLine: Record "Item Journal Line")
    var
        Item: Record Item;
    begin
        //-NPR5.32 [249432]
        //-NPR7.000.000
        //NFRetailCode.CS22InitValueEntry2(ValueEntry,ItemJournalLine);
        //+NPR7.000.000

        with ValueEntry do begin
            "Item Group No." := ItemJournalLine."Item Group No.";
            "Vendor No." := ItemJournalLine."Vendor No.";
            "Discount Type" := ItemJournalLine."Discount Type";
            "Discount Code" := ItemJournalLine."Discount Code";
            "Register No." := ItemJournalLine."Register Number";
            "Group Sale" := ItemJournalLine."Group Sale";
            "Salesperson Code" := ItemJournalLine."Salespers./Purch. Code";
            //- NPR5.43 [312575]
            "Item Category Code" := ItemJournalLine."Item Category Code";

            //+ NPR5.43 [312575]
            //-NPR5.33 [264324]
            //   IF ("Vendor No." = '') OR ("Item Group No." = '') THEN
            //    IF Item.GET("Item No.") THEN BEGIN
            //      IF "Vendor No." = '' THEN
            //        "Vendor No." := Item."Vendor No.";
            //      IF "Item Group No." = '' THEN
            //        "Item Group No." := Item."Item Group";
            //    END;
            //  //+264324 [264324]
        end;
    end;

    local procedure "--Codeunit 80 Sales-Post--"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnBeforePostSalesDoc', '', true, false)]
    local procedure C80OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header")
    var
        RetailSetup: Record "Retail Setup";
    begin
        //-NPR5.32 [249432]
        //+NPR7.000.000
        //RetailCodeunitCode.C80OnRun1(SalesHeader);
        //-NPR7.000.000

        RetailSetup.Get;
        if RetailSetup."Salespersoncode on Salesdoc." = RetailSetup."Salespersoncode on Salesdoc."::Forced then
            SalesHeader.TestField("Salesperson Code");
        //+NPR5.32 [249432]
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', false, false)]
    local procedure C80OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
    var
        RecRef: RecordRef;
        SalesInvHeader: Record "Sales Invoice Header";
        "NaviDocs Management": Codeunit "NaviDocs Management";
        SalesShptHeader: Record "Sales Shipment Header";
        SalesSetup: Record "Sales & Receivables Setup";
        ShipmentDocument: Record "Pacsoft Shipment Document";
        RecRefShipment: RecordRef;
        PacsoftSetup: Record "Pacsoft Setup";
        ConsignorEntry: Record "Consignor Entry";
    begin
        SalesSetup.Get;

        //+NPR5.40.01
        //+NPR7.000.000
        //IF SalesHeader.Invoice THEN BEGIN
        //  IF SalesHeader."Document Type" IN [SalesHeader."Document Type"::Order,SalesHeader."Document Type"::Invoice] THEN
        //    ICFunctions.CreateOrderQueue(SalesHeader,1,SalesInvHdrNo)
        //  ELSE
        //    ICFunctions.CreateOrderQueue(SalesHeader,2,SalesCrMemoHdrNo);
        //-NPR5.23 [236043]
        //  IF SalesInvHeader.GET(SalesInvHdrNo) THEN BEGIN
        //    RecRef.GETTABLE(SalesInvHeader);
        //    "NaviDocs Management".AddEntry(RecRef,2);
        //  END;
        //+NPR5.23 [236043]
        //END;
        //-NPR7.000.000
        //-NPR5.40.01

        if SalesHeader.Ship then
            if (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) or
                ((SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice) and SalesSetup."Shipment on Invoice") then
                if SalesShptHeader.Get(SalesShptHdrNo) then begin
                    //-PS1.01
                    if (PacsoftSetup.Get) and (PacsoftSetup."Create Pacsoft Document") then begin
                        RecRefShipment.GetTable(SalesShptHeader);
                        ShipmentDocument.AddEntry(RecRefShipment, false);
                    end;
                    //+PS1.01
                    //-NPR5.29 [249684]
                    //-NPR5.26 [248912]
                    //      IF (PacsoftSetup.GET) AND (PacsoftSetup."Use Pakkelabels") THEN BEGIN
                    //        RecRefShipment.GETTABLE(SalesShptHeader);
                    //        ShipmentDocument.AddEntryPakkelabels(RecRefShipment,FALSE);
                    //      END;
                    //+NPR5.26 [248912]
                    //-NPR5.29 [249684]
                    //-237639
                    ConsignorEntry.InsertFromShipmentHeader(SalesShptHeader."No.");
                    //+237639
                end;
    end;

    local procedure "--Page 30 Item Card--"()
    begin
    end;

    [EventSubscriber(ObjectType::Page, 30, 'OnAfterActionEvent', 'NPR_AttributeValues', false, false)]
    local procedure P30OnAfterActionEventNPRAttributeValues(var Rec: Record Item)
    var
        NPRAttrManagement: Codeunit "NPR Attribute Management";
    begin
        NPRAttrManagement.ShowMasterDataAttributeValues(DATABASE::Item, Rec."No.");
    end;

    local procedure "--Page42 Sales Order"()
    begin
    end;

    [EventSubscriber(ObjectType::Page, 42, 'OnAfterActionEvent', 'Consignor Label', false, false)]
    local procedure P42OnAfterActionEventConsignorLabel(var Rec: Record "Sales Header")
    var
        ConsignorEntry: Record "Consignor Entry";
    begin
        //-237639
        ConsignorEntry.InsertFromSalesHeader(Rec."No.");
        //+237639
    end;

    [EventSubscriber(ObjectType::Page, 42, 'OnAfterActionEvent', 'Import From Scanner', false, false)]
    local procedure P42OnAferActionEventImportFromScanner(var Rec: Record "Sales Header")
    var
        ImportfromScannerFileSO: XMLport "Import from Scanner File SO";
    begin
        //-NPR5.23
        ImportfromScannerFileSO.SelectTable(Rec);
        ImportfromScannerFileSO.SetTableView(Rec);
        ImportfromScannerFileSO.Run;
        //+NPR5.23
    end;

    [EventSubscriber(ObjectType::Page, 42, 'OnAfterActionEvent', 'InsertLineItem ', true, true)]
    local procedure P42OnAfterActionInsertLinewithItem(var Rec: Record "Sales Header")
    var
        RetailItemList: Page "Retail Item List";
        Item: Record Item;
        SalesLine: Record "Sales Line";
        LastSalesLine: Record "Sales Line";
        ReturntoSO: Boolean;
        ViewText: Text;
        InputQuantity: Decimal;
        InputDialog: Page "Input Dialog";
    begin
        //-NPR5.38 [298368]
        Rec.TestField(Status, Rec.Status::Open);
        Rec.TestField("Sell-to Customer No.");
        RetailItemList.SetLocationCode(Rec."Location Code");
        RetailItemList.SetBlocked(2);
        RetailItemList.LookupMode := true;
        while RetailItemList.RunModal = ACTION::LookupOK do begin
            RetailItemList.GetRecord(Item);

            InputQuantity := 1;
            InputDialog.SetAutoCloseOnValidate(true);
            InputDialog.SetInput(1, InputQuantity, SalesLine.FieldCaption(Quantity));
            InputDialog.RunModal;
            InputDialog.InputDecimal(1, InputQuantity);
            Clear(InputDialog);

            LastSalesLine.Reset;
            LastSalesLine.SetRange("Document Type", Rec."Document Type");
            LastSalesLine.SetRange("Document No.", Rec."No.");
            if not LastSalesLine.FindLast then
                LastSalesLine.Init;

            SalesLine.Init;
            SalesLine.Validate("Document Type", Rec."Document Type");
            SalesLine.Validate("Document No.", Rec."No.");
            SalesLine.Validate("Line No.", LastSalesLine."Line No." + 10000);
            SalesLine.Insert(true);
            SalesLine.Validate(Type, SalesLine.Type::Item);
            SalesLine.Validate("No.", Item."No.");
            SalesLine.Validate(Quantity, InputQuantity);
            SalesLine.Modify(true);
            Commit;
            ViewText := RetailItemList.GetViewText;
            Clear(RetailItemList);
            RetailItemList.SetLocationCode(Rec."Location Code");
            RetailItemList.SetVendorNo(Rec."Buy-From Vendor No.");
            Item.SetView(ViewText);
            RetailItemList.SetTableView(Item);
            RetailItemList.SetRecord(Item);
            RetailItemList.LookupMode := true;
        end;
        //+NPR5.38 [298368]
    end;

    local procedure "--Page 43 Sales Invoice"()
    begin
    end;

    [EventSubscriber(ObjectType::Page, 43, 'OnAfterActionEvent', 'ImportFromScanner', false, false)]
    local procedure P43OnAfterActionEventImportFromScannerFile(var Rec: Record "Sales Header")
    var
        ImportfromScannerFileSO: XMLport "Import from Scanner File SO";
    begin
        //-NPR5.49 [324592]
        ImportfromScannerFileSO.SelectTable(Rec);
        ImportfromScannerFileSO.SetTableView(Rec);
        ImportfromScannerFileSO.Run;
        //-NPR5.49 [324592]
    end;

    local procedure "--Page 44 Sales Credit Memo"()
    begin
    end;

    [EventSubscriber(ObjectType::Page, 44, 'OnAfterActionEvent', 'ImportFromScanner', false, false)]
    local procedure P44OnAfterActionEventImportFromScannerFile(var Rec: Record "Sales Header")
    var
        ImportfromScannerFileSO: XMLport "Import from Scanner File SO";
    begin
        //-NPR5.49 [324592]
        ImportfromScannerFileSO.SelectTable(Rec);
        ImportfromScannerFileSO.SetTableView(Rec);
        ImportfromScannerFileSO.Run;
        //-NPR5.49 [324592]
    end;

    local procedure "--Page 50 Purchase Order"()
    begin
    end;

    [EventSubscriber(ObjectType::Page, 50, 'OnAfterActionEvent', 'InsertLineVendorItem', false, false)]
    local procedure P50OnAfterActionEventInsertLinewithVendorItem(var Rec: Record "Purchase Header")
    var
        RetailItemList: Page "Retail Item List";
        Item: Record Item;
        PurchaseLine: Record "Purchase Line";
        LastPurchaseLine: Record "Purchase Line";
        ReturntoPO: Boolean;
        ViewText: Text;
        InputQuantity: Decimal;
        InputDialog: Page "Input Dialog";
    begin
        //-NPR5.31
        //-NPR5.33 [272843]
        Rec.TestField(Status, Rec.Status::Open);
        //+NPR5.33 [272843]
        Rec.TestField("Buy-from Vendor No.");
        RetailItemList.SetLocationCode(Rec."Location Code");
        RetailItemList.SetVendorNo(Rec."Buy-from Vendor No.");
        RetailItemList.LookupMode := true;
        //-NPR5.33 [272843]
        //  IF RetailItemList.RUNMODAL <> ACTION::LookupOK THEN
        //    EXIT;
        while RetailItemList.RunModal = ACTION::LookupOK do begin
            //+NPR5.33 [272843]
            RetailItemList.GetRecord(Item);
            //-NPR5.34 [282922]
            InputQuantity := 1;
            InputDialog.SetAutoCloseOnValidate(true);
            InputDialog.SetInput(1, InputQuantity, PurchaseLine.FieldCaption(Quantity));
            InputDialog.RunModal;
            InputDialog.InputDecimal(1, InputQuantity);
            Clear(InputDialog);
            //-NPR5.34 [282922]

            LastPurchaseLine.Reset;
            LastPurchaseLine.SetRange("Document Type", Rec."Document Type");
            LastPurchaseLine.SetRange("Document No.", Rec."No.");
            if not LastPurchaseLine.FindLast then
                LastPurchaseLine.Init;

            PurchaseLine.Init;
            PurchaseLine.Validate("Document Type", Rec."Document Type");
            PurchaseLine.Validate("Document No.", Rec."No.");
            PurchaseLine.Validate("Line No.", LastPurchaseLine."Line No." + 10000);
            PurchaseLine.Insert(true);
            PurchaseLine.Validate(Type, PurchaseLine.Type::Item);
            PurchaseLine.Validate("No.", Item."No.");
            //-NPR5.33 [272843]
            //PurchaseLine.MODIFY(TRUE);
            //-NPR5.34 [282922]
            //PurchaseLine.VALIDATE(Quantity,1);
            PurchaseLine.Validate(Quantity, InputQuantity);
            //+NPR5.34 [282922]
            PurchaseLine.Modify(true);
            Commit;
            ViewText := RetailItemList.GetViewText;
            Clear(RetailItemList);
            RetailItemList.SetLocationCode(Rec."Location Code");
            RetailItemList.SetVendorNo(Rec."Buy-from Vendor No.");
            Item.SetView(ViewText);
            RetailItemList.SetTableView(Item);
            RetailItemList.SetRecord(Item);
            RetailItemList.LookupMode := true;
        end;
        //+NPR5.33 [272843]
        //+NPR5.31
    end;

    [EventSubscriber(ObjectType::Page, 50, 'OnAfterActionEvent', 'ImportFromScanner', false, false)]
    local procedure P50OnAfterActionEventImportFromScannerFile(var Rec: Record "Purchase Header")
    var
        ImportfromScannerFilePO: XMLport "Import from Scanner File PO";
    begin
        //-NPR5.38 [296801]
        ImportfromScannerFilePO.SelectTable(Rec);
        ImportfromScannerFilePO.SetTableView(Rec);
        ImportfromScannerFilePO.Run;
        //+NPR5.38 [296801]
    end;

    local procedure "--Page 49 Purchase Quote"()
    begin
    end;

    [EventSubscriber(ObjectType::Page, 49, 'OnAfterActionEvent', 'ImportFromScanner', false, false)]
    local procedure P49OnAfterActionEventImportFromScannerFile(var Rec: Record "Purchase Header")
    var
        ImportfromScannerFilePO: XMLport "Import from Scanner File PO";
    begin
        //-NPR5.45 [324592]
        ImportfromScannerFilePO.SelectTable(Rec);
        ImportfromScannerFilePO.SetTableView(Rec);
        ImportfromScannerFilePO.Run;
        //+NPR5.45 [324592]
    end;

    local procedure "--Page 52 Purchase Credit Memo--"()
    begin
    end;

    [EventSubscriber(ObjectType::Page, 52, 'OnAfterActionEvent', 'Import From Scanner File', false, false)]
    local procedure P52OnAfterActionEventImportFromScannerFile(var Rec: Record "Purchase Header")
    var
        ImportfromScannerFilePO: XMLport "Import from Scanner File PO";
    begin
        //-NPR4.18
        ImportfromScannerFilePO.SelectTable(Rec);
        ImportfromScannerFilePO.SetTableView(Rec);
        ImportfromScannerFilePO.Run;
        //+NPR4.18
    end;

    local procedure "--Page 130 Posted Sales Shipment--"()
    begin
    end;

    [EventSubscriber(ObjectType::Page, 130, 'OnAfterActionEvent', 'CreatePacsoftDocument', false, false)]
    local procedure P130OnAfterActionEventCreatePacsoftDocument(var Rec: Record "Sales Shipment Header")
    var
        ShipmentDocument: Record "Pacsoft Shipment Document";
        RecRef: RecordRef;
    begin
        //-PS1.00
        RecRef.GetTable(Rec);
        ShipmentDocument.AddEntry(RecRef, true);
        //+PS1.00
    end;

    [EventSubscriber(ObjectType::Page, 130, 'OnAfterActionEvent', 'Consignor Label', false, false)]
    local procedure P130OnAfterActionEventConsignorLabel(var Rec: Record "Sales Shipment Header")
    var
        ConsignorEntry: Record "Consignor Entry";
    begin
        //-237639
        ConsignorEntry.InsertFromShipmentHeader(Rec."No.");
        //+237639
    end;

    local procedure "--Page132 Posted Sales Invoice"()
    begin
    end;

    [EventSubscriber(ObjectType::Page, 132, 'OnAfterActionEvent', 'Consignor Label', false, false)]
    local procedure P132OnAfterActionEventConsignorLabel(var Rec: Record "Sales Invoice Header")
    var
        ConsignorEntry: Record "Consignor Entry";
    begin
        //-237639
        ConsignorEntry.InsertFromPostedInvoiceHeader(Rec."No.");
        //+237639
    end;

    local procedure "--Page 291 Req. Worksheet--"()
    begin
    end;

    [EventSubscriber(ObjectType::Page, 291, 'OnAfterActionEvent', '&ReadFromScanner', false, false)]
    local procedure P291OnAfterActionEventReadFromScanner(var Rec: Record "Requisition Line")
    var
        ScannerFunctions: Codeunit "Scanner - Functions";
    begin
        //-NPR4.04
        ScannerFunctions.initPurchJnl(Rec);
        //+NPR4.04
    end;

    local procedure "--Page 5740 Transfer Order--"()
    begin
    end;

    [EventSubscriber(ObjectType::Page, 5740, 'OnAfterActionEvent', 'Import From Scanner File', false, false)]
    local procedure P5740OnAfterActionEventImportFromScannerFile(var Rec: Record "Transfer Header")
    var
        ImportfromScannerFileTO: XMLport "Import from Scanner File TO";
    begin
        //-NPR4.18
        ImportfromScannerFileTO.SelectTable(Rec);
        ImportfromScannerFileTO.SetTableView(Rec);
        ImportfromScannerFileTO.Run;
        //+NPR4.18
    end;

    [EventSubscriber(ObjectType::Page, 5740, 'OnAfterActionEvent', '&Read from scanner', false, false)]
    local procedure P5740OnAfterActionEventReadFromScanner(var Rec: Record "Transfer Header")
    var
        ScannerFunctions: Codeunit "Scanner - Functions";
    begin
        //-NPR4.04
        ScannerFunctions.initTransfer(Rec);
        //+NPR4.04
    end;

    local procedure "--Page 9506 Session List--"()
    begin
    end;

    [EventSubscriber(ObjectType::Page, 9506, 'OnAfterActionEvent', 'Kill Session', false, false)]
    local procedure P956OnAfterActionEventKillSession(var Rec: Record "Active Session")
    var
        Text6014400: Label 'Kill Session   ?';
    begin
        //+NPR70.01.00.01
        if Confirm(Text6014400, false) then
            StopSession(Rec."Session ID");
        //-NPR70.01.00.01
    end;

    local procedure "--Page 6014453 Campaign Discount--"()
    begin
    end;

    [EventSubscriber(ObjectType::Page, 6014453, 'OnAfterActionEvent', 'Transfer from Period Discount', false, false)]
    local procedure P6014453OnAfterActionEventTransferFromPeriodDiscount(var Rec: Record "Period Discount")
    var
        FromPeriodDiscount: Record "Period Discount";
        CampaignDiscounts: Page "Campaign Discount List";
        FromPeriodDiscountLine: Record "Period Discount Line";
        ToPeriodDiscountLine: Record "Period Discount Line";
        ErrorNo1: Label 'There are no items to transfer';
        ErrorNo2: Label 'Item No. %1 already exists in the period';
        OkMsg: Label '%1 Items has been transferred to Period %2';
    begin
        FromPeriodDiscount.SetFilter(Code, '<>%1', Rec.Code);
        CampaignDiscounts.LookupMode := true;
        CampaignDiscounts.Editable := false;
        CampaignDiscounts.SetTableView(FromPeriodDiscount);
        if CampaignDiscounts.RunModal = ACTION::LookupOK then begin
            CampaignDiscounts.GetRecord(FromPeriodDiscount);
            FromPeriodDiscountLine.SetRange(Code, FromPeriodDiscount.Code);
            if not FromPeriodDiscountLine.FindSet then
                Error(ErrorNo1)
            else
                repeat
                    if ToPeriodDiscountLine.Get(Rec.Code, FromPeriodDiscountLine."Item No.", FromPeriodDiscountLine."Variant Code") then
                        Message(ErrorNo2, FromPeriodDiscountLine."Item No.")
                    else begin
                        ToPeriodDiscountLine.Init;
                        ToPeriodDiscountLine := FromPeriodDiscountLine;
                        ToPeriodDiscountLine.Code := Rec.Code;
                        ToPeriodDiscountLine.Insert(true);
                    end;
                until FromPeriodDiscountLine.Next = 0;
            Message(OkMsg, FromPeriodDiscountLine.Count, Rec.Code);
        end;
    end;
}

