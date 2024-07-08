codeunit 85189 "NPR Retail Print Tests"
{
    Subtype = Test;

    var
        _Initialized: Boolean;
        _POSUnit: Record "NPR POS Unit";
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSSession: Codeunit "NPR POS Session";
        _POSStore: Record "NPR POS Store";
        _POSSetup: Record "NPR POS Setup";

    /*
        [Test]
        [TestPermissions(TestPermissions::Disabled)]
        procedure TestZebraMatrixPrint()
        var
            LibraryRPTemplateData: Codeunit "NPR Library - RP Template Data";
            Template: Text;
            TemplateHeader: Record "NPR RP Template Header";
            RetailJournalLine: Record "NPR Retail Journal Line";
            LabelManagement: Codeunit "NPR Label Management";
            RetailPrintHandler: Codeunit "NPR Retail Print Handler";
            Assert: Codeunit Assert;
            NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
            Item: Record Item;
        begin
            // [Given] A Zebra price label template is configured
            InitializeData();
            Template := LibraryRPTemplateData.ImportZebraMatrixPriceLabelTemplate();
            TemplateHeader.Get(Template);
            LibraryRPTemplateData.ConfigureReportSelection(Enum::"NPR Report Selection Type"::"Price Label", TemplateHeader);

            // [Given] Item in a retail journal line
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
            Item.Description := 'Test item';
            Item."Description 2" := 'Test item description 2';
            Item."Vendor No." := 'Test Vendor No.';
            Item."Vendor Item No." := 'Test Vendor Item No.';
            Item."Unit Price" := 10;
            Item.Modify();
            RetailJournalLine.SelectRetailJournal(Format(CreateGuid()));
            RetailJournalLine.InitLine();
            RetailJournalLine.SetItem(Item."No.", '', '');
            RetailJournalLine.Validate("Quantity to Print", 5);
            RetailJournalLine.Barcode := 'STATIC_BARCODE';
            RetailJournalLine.Insert();
            RetailJournalLine.SetRecFilter();

            // [When] Printing a price label
            BindSubscription(RetailPrintHandler);
            LabelManagement.PrintRetailJournal(RetailJournalLine, Enum::"NPR Report Selection Type"::"Price Label".AsInteger());
            UnbindSubscription(RetailPrintHandler);

            // [Then] The output matches the expected printer control commands. 
            // The point with the test is: if any bytes in the output suddenly changes, you probably broke something. Deserialize the two base64s and compare bytes.
            Assert.AreEqual('XlhBXkNJMjdeRk84OCwyXkFRTl5GQjkxLDEsMCxDLDBeRkQxMC4wMCwtXkZTXkZPNzIsMjJeQTBOLDE5LDE1XkZCOTUsMSwwLEMsMF5GRE1hdGVyaWFsZV5GU15GTzcxLDM4XkJZMSwyLjAsMTheQkVOLDE4LE4sTl5GRFNUQVRJQ19CQVJDT0RFXkZTXkZPNCw3NF5BME4sMTksMTVeRkIyMzEsMSwwLEMsMF5GRFRlc3QgaXRlbSBkZXNjcmlwdGlvbiBeRlNeRk83Miw5MV5BME4sMTksMTVeRkI5NSwxLDAsQywwXkZEU3RlbiBpbmZvXkZTXkZPNCwxMDheQTBOLDE5LDE1XkZCMjMxLDEsMCxDLDBeRkRURVNUIFZFTkRPUiBOTy5UZXN0IFZlXkZTXkZPMjU1LDJeQVFOXkZCOTEsMSwwLEMsMF5GRDEwLjAwLC1eRlNeRk8yMzksMjJeQTBOLDE5LDE1XkZCOTUsMSwwLEMsMF5GRE1hdGVyaWFsZV5GU15GTzIzOCwzOF5CWTEsMi4wLDE4XkJFTiwxOCxOLE5eRkRTVEFUSUNfQkFSQ09ERV5GU15GTzE3MSw3NF5BME4sMTksMTVeRkIyMzEsMSwwLEMsMF5GRFRlc3QgaXRlbSBkZXNjcmlwdGlvbiBeRlNeRk8yMzksOTFeQTBOLDE5LDE1XkZCOTUsMSwwLEMsMF5GRFN0ZW4gaW5mb15GU15GTzE3MSwxMDheQTBOLDE5LDE1XkZCMjMxLDEsMCxDLDBeRkRURVNUIFZFTkRPUiBOTy5UZXN0IFZlXkZTXkZPNDIzLDJeQVFOXkZCOTEsMSwwLEMsMF5GRDEwLjAwLC1eRlNeRk80MDcsMjJeQTBOLDE5LDE1XkZCOTUsMSwwLEMsMF5GRE1hdGVyaWFsZV5GU15GTzQwNiwzOF5CWTEsMi4wLDE4XkJFTiwxOCxOLE5eRkRTVEFUSUNfQkFSQ09ERV5GU15GTzMzOSw3NF5BME4sMTksMTVeRkIyMzEsMSwwLEMsMF5GRFRlc3QgaXRlbSBkZXNjcmlwdGlvbiBeRlNeRk80MDcsOTFeQTBOLDE5LDE1XkZCOTUsMSwwLEMsMF5GRFN0ZW4gaW5mb15GU15GTzMzOSwxMDheQTBOLDE5LDE1XkZCMjMxLDEsMCxDLDBeRkRURVNUIFZFTkRPUiBOTy5UZXN0IFZlXkZTXlhaXlhBXkNJMjdeRk84OCwyXkFRTl5GQjkxLDEsMCxDLDBeRkQxMC4wMCwtXkZTXkZPNzIsMjJeQTBOLDE5LDE1XkZCOTUsMSwwLEMsMF5GRE1hdGVyaWFsZV5GU15GTzcxLDM4XkJZMSwyLjAsMTheQkVOLDE4LE4sTl5GRFNUQVRJQ19CQVJDT0RFXkZTXkZPNCw3NF5BME4sMTksMTVeRkIyMzEsMSwwLEMsMF5GRFRlc3QgaXRlbSBkZXNjcmlwdGlvbiBeRlNeRk83Miw5MV5BME4sMTksMTVeRkI5NSwxLDAsQywwXkZEU3RlbiBpbmZvXkZTXkZPNCwxMDheQTBOLDE5LDE1XkZCMjMxLDEsMCxDLDBeRkRURVNUIFZFTkRPUiBOTy5UZXN0IFZlXkZTXkZPMjU1LDJeQVFOXkZCOTEsMSwwLEMsMF5GRDEwLjAwLC1eRlNeRk8yMzksMjJeQTBOLDE5LDE1XkZCOTUsMSwwLEMsMF5GRE1hdGVyaWFsZV5GU15GTzIzOCwzOF5CWTEsMi4wLDE4XkJFTiwxOCxOLE5eRkRTVEFUSUNfQkFSQ09ERV5GU15GTzE3MSw3NF5BME4sMTksMTVeRkIyMzEsMSwwLEMsMF5GRFRlc3QgaXRlbSBkZXNjcmlwdGlvbiBeRlNeRk8yMzksOTFeQTBOLDE5LDE1XkZCOTUsMSwwLEMsMF5GRFN0ZW4gaW5mb15GU15GTzE3MSwxMDheQTBOLDE5LDE1XkZCMjMxLDEsMCxDLDBeRkRURVNUIFZFTkRPUiBOTy5UZXN0IFZlXkZTXkZPNDIzLDJeQVFOXkZCOTEsMSwwLEMsMF5GRDEwLjAwLC1eRlNeRk80MDcsMjJeQTBOLDE5LDE1XkZCOTUsMSwwLEMsMF5GRE1hdGVyaWFsZV5GU15GTzQwNiwzOF5CWTEsMi4wLDE4XkJFTiwxOCxOLE5eRkRTVEFUSUNfQkFSQ09ERV5GU15GTzMzOSw3NF5BME4sMTksMTVeRkIyMzEsMSwwLEMsMF5GRFRlc3QgaXRlbSBkZXNjcmlwdGlvbiBeRlNeRk80MDcsOTFeQTBOLDE5LDE1XkZCOTUsMSwwLEMsMF5GRFN0ZW4gaW5mb15GU15GTzMzOSwxMDheQTBOLDE5LDE1XkZCMjMxLDEsMCxDLDBeRkRURVNUIFZFTkRPUiBOTy5UZXN0IFZlXkZTXlhaXlhBXkNJMjdeRk84OCwyXkFRTl5GQjkxLDEsMCxDLDBeRkQxMC4wMCwtXkZTXkZPNzIsMjJeQTBOLDE5LDE1XkZCOTUsMSwwLEMsMF5GRE1hdGVyaWFsZV5GU15GTzcxLDM4XkJZMSwyLjAsMTheQkVOLDE4LE4sTl5GRFNUQVRJQ19CQVJDT0RFXkZTXkZPNCw3NF5BME4sMTksMTVeRkIyMzEsMSwwLEMsMF5GRFRlc3QgaXRlbSBkZXNjcmlwdGlvbiBeRlNeRk83Miw5MV5BME4sMTksMTVeRkI5NSwxLDAsQywwXkZEU3RlbiBpbmZvXkZTXkZPNCwxMDheQTBOLDE5LDE1XkZCMjMxLDEsMCxDLDBeRkRURVNUIFZFTkRPUiBOTy5UZXN0IFZlXkZTXkZPMjU1LDJeQVFOXkZCOTEsMSwwLEMsMF5GRDEwLjAwLC1eRlNeRk8yMzksMjJeQTBOLDE5LDE1XkZCOTUsMSwwLEMsMF5GRE1hdGVyaWFsZV5GU15GTzIzOCwzOF5CWTEsMi4wLDE4XkJFTiwxOCxOLE5eRkRTVEFUSUNfQkFSQ09ERV5GU15GTzE3MSw3NF5BME4sMTksMTVeRkIyMzEsMSwwLEMsMF5GRFRlc3QgaXRlbSBkZXNjcmlwdGlvbiBeRlNeRk8yMzksOTFeQTBOLDE5LDE1XkZCOTUsMSwwLEMsMF5GRFN0ZW4gaW5mb15GU15GTzE3MSwxMDheQTBOLDE5LDE1XkZCMjMxLDEsMCxDLDBeRkRURVNUIFZFTkRPUiBOTy5UZXN0IFZlXkZTXkZPNDIzLDJeQVFOXkZCOTEsMSwwLEMsMF5GRDEwLjAwLC1eRlNeRk80MDcsMjJeQTBOLDE5LDE1XkZCOTUsMSwwLEMsMF5GRE1hdGVyaWFsZV5GU15GTzQwNiwzOF5CWTEsMi4wLDE4XkJFTiwxOCxOLE5eRkRTVEFUSUNfQkFSQ09ERV5GU15GTzMzOSw3NF5BME4sMTksMTVeRkIyMzEsMSwwLEMsMF5GRFRlc3QgaXRlbSBkZXNjcmlwdGlvbiBeRlNeRk80MDcsOTFeQTBOLDE5LDE1XkZCOTUsMSwwLEMsMF5GRFN0ZW4gaW5mb15GU15GTzMzOSwxMDheQTBOLDE5LDE1XkZCMjMxLDEsMCxDLDBeRkRURVNUIFZFTkRPUiBOTy5UZXN0IFZlXkZTXlhaXlhBXkNJMjdeRk84OCwyXkFRTl5GQjkxLDEsMCxDLDBeRkQxMC4wMCwtXkZTXkZPNzIsMjJeQTBOLDE5LDE1XkZCOTUsMSwwLEMsMF5GRE1hdGVyaWFsZV5GU15GTzcxLDM4XkJZMSwyLjAsMTheQkVOLDE4LE4sTl5GRFNUQVRJQ19CQVJDT0RFXkZTXkZPNCw3NF5BME4sMTksMTVeRkIyMzEsMSwwLEMsMF5GRFRlc3QgaXRlbSBkZXNjcmlwdGlvbiBeRlNeRk83Miw5MV5BME4sMTksMTVeRkI5NSwxLDAsQywwXkZEU3RlbiBpbmZvXkZTXkZPNCwxMDheQTBOLDE5LDE1XkZCMjMxLDEsMCxDLDBeRkRURVNUIFZFTkRPUiBOTy5UZXN0IFZlXkZTXkZPMjU1LDJeQVFOXkZCOTEsMSwwLEMsMF5GRDEwLjAwLC1eRlNeRk8yMzksMjJeQTBOLDE5LDE1XkZCOTUsMSwwLEMsMF5GRE1hdGVyaWFsZV5GU15GTzIzOCwzOF5CWTEsMi4wLDE4XkJFTiwxOCxOLE5eRkRTVEFUSUNfQkFSQ09ERV5GU15GTzE3MSw3NF5BME4sMTksMTVeRkIyMzEsMSwwLEMsMF5GRFRlc3QgaXRlbSBkZXNjcmlwdGlvbiBeRlNeRk8yMzksOTFeQTBOLDE5LDE1XkZCOTUsMSwwLEMsMF5GRFN0ZW4gaW5mb15GU15GTzE3MSwxMDheQTBOLDE5LDE1XkZCMjMxLDEsMCxDLDBeRkRURVNUIFZFTkRPUiBOTy5UZXN0IFZlXkZTXkZPNDIzLDJeQVFOXkZCOTEsMSwwLEMsMF5GRDEwLjAwLC1eRlNeRk80MDcsMjJeQTBOLDE5LDE1XkZCOTUsMSwwLEMsMF5GRE1hdGVyaWFsZV5GU15GTzQwNiwzOF5CWTEsMi4wLDE4XkJFTiwxOCxOLE5eRkRTVEFUSUNfQkFSQ09ERV5GU15GTzMzOSw3NF5BME4sMTksMTVeRkIyMzEsMSwwLEMsMF5GRFRlc3QgaXRlbSBkZXNjcmlwdGlvbiBeRlNeRk80MDcsOTFeQTBOLDE5LDE1XkZCOTUsMSwwLEMsMF5GRFN0ZW4gaW5mb15GU15GTzMzOSwxMDheQTBOLDE5LDE1XkZCMjMxLDEsMCxDLDBeRkRURVNUIFZFTkRPUiBOTy5UZXN0IFZlXkZTXlhaXlhBXkNJMjdeRk84OCwyXkFRTl5GQjkxLDEsMCxDLDBeRkQxMC4wMCwtXkZTXkZPNzIsMjJeQTBOLDE5LDE1XkZCOTUsMSwwLEMsMF5GRE1hdGVyaWFsZV5GU15GTzcxLDM4XkJZMSwyLjAsMTheQkVOLDE4LE4sTl5GRFNUQVRJQ19CQVJDT0RFXkZTXkZPNCw3NF5BME4sMTksMTVeRkIyMzEsMSwwLEMsMF5GRFRlc3QgaXRlbSBkZXNjcmlwdGlvbiBeRlNeRk83Miw5MV5BME4sMTksMTVeRkI5NSwxLDAsQywwXkZEU3RlbiBpbmZvXkZTXkZPNCwxMDheQTBOLDE5LDE1XkZCMjMxLDEsMCxDLDBeRkRURVNUIFZFTkRPUiBOTy5UZXN0IFZlXkZTXkZPMjU1LDJeQVFOXkZCOTEsMSwwLEMsMF5GRDEwLjAwLC1eRlNeRk8yMzksMjJeQTBOLDE5LDE1XkZCOTUsMSwwLEMsMF5GRE1hdGVyaWFsZV5GU15GTzIzOCwzOF5CWTEsMi4wLDE4XkJFTiwxOCxOLE5eRkRTVEFUSUNfQkFSQ09ERV5GU15GTzE3MSw3NF5BME4sMTksMTVeRkIyMzEsMSwwLEMsMF5GRFRlc3QgaXRlbSBkZXNjcmlwdGlvbiBeRlNeRk8yMzksOTFeQTBOLDE5LDE1XkZCOTUsMSwwLEMsMF5GRFN0ZW4gaW5mb15GU15GTzE3MSwxMDheQTBOLDE5LDE1XkZCMjMxLDEsMCxDLDBeRkRURVNUIFZFTkRPUiBOTy5UZXN0IFZlXkZTXkZPNDIzLDJeQVFOXkZCOTEsMSwwLEMsMF5GRDEwLjAwLC1eRlNeRk80MDcsMjJeQTBOLDE5LDE1XkZCOTUsMSwwLEMsMF5GRE1hdGVyaWFsZV5GU15GTzQwNiwzOF5CWTEsMi4wLDE4XkJFTiwxOCxOLE5eRkRTVEFUSUNfQkFSQ09ERV5GU15GTzMzOSw3NF5BME4sMTksMTVeRkIyMzEsMSwwLEMsMF5GRFRlc3QgaXRlbSBkZXNjcmlwdGlvbiBeRlNeRk80MDcsOTFeQTBOLDE5LDE1XkZCOTUsMSwwLEMsMF5GRFN0ZW4gaW5mb15GU15GTzMzOSwxMDheQTBOLDE5LDE1XkZCMjMxLDEsMCxDLDBeRkRURVNUIFZFTkRPUiBOTy5UZXN0IFZlXkZTXlha',
                            RetailPrintHandler.GetPrintJobBase64(),
                            'Breaking change in zebra label print job');
        end;
    */

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TestEpsonLinePrint()
    var
        LibraryRPTemplateData: Codeunit "NPR Library - RP Template Data";
        Template: Text;
        TemplateHeader: Record "NPR RP Template Header";
        POSSale: Codeunit "NPR POS Sale";
        RetailPrintHandler: Codeunit "NPR Retail Print Handler";
        Assert: Codeunit Assert;
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Item: Record Item;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        POSEntryManagement: Codeunit "NPR POS Entry Management";
    begin
        // [Given] An epson receipt template is configured
        InitializeData();
        Template := LibraryRPTemplateData.ImportEpsonReceiptTemplate();
        TemplateHeader.Get(Template);
        LibraryRPTemplateData.ConfigureReportSelection(Enum::"NPR Report Selection Type"::"Sales Receipt (POS Entry)", TemplateHeader);

        // [Given] A finished POS entry
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item.Description := 'Test item';
        Item."Description 2" := 'Test item description 2';
        Item."Unit Price" := 10;
        Item.Modify();
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);
        _POSPaymentMethod.Description := 'Test payment method';
        _POSPaymentMethod.Modify();
        SaleEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, 10, '');
        Assert.IsTrue(SaleEnded, 'Sale ended');

        // [When] Printing a receipt
        POSEntry.FindLast();
        BindSubscription(RetailPrintHandler);
        POSEntryManagement.PrintEntry(POSEntry, false);
        UnbindSubscription(RetailPrintHandler);

        // [Then] The output matches the expected printer control commands. 
        // The point with the test is: if any bytes in the output suddenly changes, you probably broke something. Deserialize the two base64s and compare bytes.
        Assert.AreEqual('G0AbdBAbYTAKG2EwHSEAG00wICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgChthMB0hABtNMF9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwobYTAdIQAbTTAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKG2EwHSEAG00wX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fChthMB0hABtNMCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAobYTAdIQAbTTBUZXN0IGl0ZW0gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKG2EwHSEAG00wICAxeCAgICAgICAgICAgICAbYTAdIQAbTTAgICAgICAgMTAuMDAbYTAdIQAbTTAgICAgICAxMC4wMAobYTAdIQAbTTBfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KG2EwHSEAG00wICAgICAgICAgICAgICAgICAgICAgG2EwHSEAG00wICAgICAgICAgICAgICAgICAyLjAwChthMB0hABtNMF9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwobYTAdIQAbTTAgICAgICAgICAgICAgICAgICAgICAbRTEbYTAdIQAbTTAgICAgICAgICAgICAgICAgMTAuMDAbRTAKG2EwHSEAG00wVGVzdCBwYXltZW50IG1ldGhvZCAgG2EwHSEAG00wICAgICAgICAgICAgICAgIDEwLjAwChthMB0hABtNMCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAobYTEddwIdaCgda0kRe0JCQVJDT0RFVkFMVUUxMjNCQVJDT0RFVkFMVUUxMjMKChthMR0hABtNMElOIENBU0UgWU9VIE5FRUQgVE8gRVhDSEFOR0UgVEhFIElURU0KG2ExHSEAG00wV0lUSElOIDE1IERBWVMgT0YgUFVSQ0hBU0UKG2ExHSEAG00wKioqKioqChthMR0hABtNMAodVkID',
                        RetailPrintHandler.GetPrintJobBase64(),
                        'Breaking change in print job');
    end;

    /*
        [Test]
        [TestPermissions(TestPermissions::Disabled)]
        procedure TestHTTPRetailJournalPrint()
        var
            PrintJobKeyValue: Record "NPR Print Job Key Value";
            TmpRetailJournalLine: Record "NPR Retail Journal Line" temporary;
            LibraryRPTemplateData: Codeunit "NPR Library - RP Template Data";
            Template: Text;
            TemplateHeader: Record "NPR RP Template Header";
            LabelManagement: Codeunit "NPR Label Management";
            RetailPrintHandler: Codeunit "NPR Retail Print Handler";
            Assert: Codeunit Assert;
            NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
            Item: Record Item;
            RJLNo: Text;
            PrintJobId: Guid;
            PrintRetJnlHTTPLabel: Codeunit "NPR Print RetJnl HTTP Label";
        begin
            // [Given] A price label template is configured
            InitializeData();
            Template := LibraryRPTemplateData.ImportZebraMatrixPriceLabelTemplate();
            TemplateHeader.Get(Template);
            LibraryRPTemplateData.ConfigureReportSelection(Enum::"NPR Report Selection Type"::"Price Label", TemplateHeader);

            // [Given] A temp retail journal line buffer
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
            Item."Unit Price" := 10;
            Item.Modify();
            RJLNo := Format(CreateGuid());
            PrintJobId := CreateGuid();
            TmpRetailJournalLine.SelectRetailJournal(RJLNo);
            TmpRetailJournalLine.InitLine();
            TmpRetailJournalLine.SetItem(Item."No.", '', '');
            TmpRetailJournalLine.Validate("Quantity to Print", 5);
            TmpRetailJournalLine."Print Job ID" := PrintJobId;
            TmpRetailJournalLine.Insert();
            TmpRetailJournalLine.InitLine();
            TmpRetailJournalLine.SetItem(Item."No.", '', '');
            TmpRetailJournalLine.Validate("Quantity to Print", 2);
            TmpRetailJournalLine."Print Job ID" := PrintJobId;
            TmpRetailJournalLine.Insert();

            TmpRetailJournalLine.SetRange("No.", RJLNo);

            // [When] Starting a manual HTTP print job
            PrintRetJnlHTTPLabel.Run(TmpRetailJournalLine);

            // [Then] Then print job is created as a blob we can handle ourselves
            PrintJobKeyValue.SetRange("Print Key", PrintJobId);
            Assert.IsTrue(PrintJobKeyValue.FindFirst(), 'Print job key value not created');
            Assert.IsTrue(PrintJobKeyValue."Print Job".HasValue(), 'Print job does not contain data');
        end;
    */


    procedure InitializeData()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        UserSetup: Record "User Setup";
    begin
        //Clean any previous mock session
        _POSSession.ClearAll();
        Clear(_POSSession);

        if not _Initialized then begin
            NPRLibraryPOSMasterData.CreatePOSSetup(_POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            NPRLibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethod, _POSPaymentMethod."Processing Type"::CASH, '', false);

            if UserSetup.Get(UserId) then;
            UserSetup."User ID" := UserId;
            UserSetup."NPR POS Unit No." := _POSUnit."No.";
            if not UserSetup.Insert() then
                UserSetup.Modify();

            _Initialized := true;
        end;

        Commit();
    end;
}