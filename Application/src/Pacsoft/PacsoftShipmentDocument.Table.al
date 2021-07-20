table 6014452 "NPR Pacsoft Shipment Document"
{
    Caption = 'Pacsoft Shipment Document';
    DrillDownPageID = "NPR Pacsoft Shipment Documents";
    LookupPageID = "NPR Pacsoft Shipment Documents";
    PasteIsValid = false;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ShipmentDocument: Record "NPR Pacsoft Shipment Document";
            begin
                if "Entry No." = 0 then begin
                    Clear(ShipmentDocument);
                    if ShipmentDocument.FindLast() then
                        "Entry No." := ShipmentDocument."Entry No." + 1
                    else
                        "Entry No." := 1;
                end;
            end;
        }
        field(5; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            DataClassification = CustomerContent;
        }
        field(10; "RecordID"; RecordID)
        {
            Caption = 'RecordID';
            DataClassification = CustomerContent;
        }
        field(20; "Document Type"; Option)
        {
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order","Posted Shipment","Posted Invoice";
            DataClassification = CustomerContent;
        }
        field(21; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(100; "Creation Time"; DateTime)
        {
            Caption = 'Creation Time';
            DataClassification = CustomerContent;
        }
        field(101; "Export Time"; DateTime)
        {
            Caption = 'Export Time';
            DataClassification = CustomerContent;
        }
        Field(102; "User ID"; text[100])
        {
            TableRelation = user."User Security ID";
            Caption = 'User ID';
            DataClassification = CustomerContent;
        }

        field(7; "User Name"; text[100])
        {
            Caption = 'User Name';
            FieldClass = FlowField;
            CalcFormula = lookup(user."User Name" where("user security ID" = field("user ID")));

        }

        Field(103; "Location Code"; code[20])
        {
            Caption = 'Location';
            TableRelation = Location;
            DataClassification = CustomerContent;
        }
        field(200; Status; Text[10])
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(201; "Return Message"; Text[250])
        {
            Caption = 'Return Message';
            DataClassification = CustomerContent;
        }
        field(202; Session; Text[100])
        {
            Caption = 'Session';
            DataClassification = CustomerContent;
        }
        field(300; "Receiver ID"; Code[20])
        {
            Caption = 'Receiver ID';
            DataClassification = CustomerContent;
        }
        field(301; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(302; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(303; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(304; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
        }
        field(305; City; Text[30])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(306; County; Text[30])
        {
            Caption = 'County';
            DataClassification = CustomerContent;
        }
        field(307; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
        }
        field(308; Contact; Text[100])
        {
            Caption = 'Contact';
            DataClassification = CustomerContent;
        }
        field(309; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            ExtendedDatatype = PhoneNo;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "SMS No." = '' then
                    "SMS No." := "Phone No.";
            end;
        }
        field(310; "Fax No."; Text[30])
        {
            Caption = 'Fax No.';
            DataClassification = CustomerContent;
        }
        field(311; "VAT Registration No."; Text[20])
        {
            Caption = 'VAT Registration No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
            end;
        }
        field(312; "E-Mail"; Text[80])
        {
            Caption = 'E-Mail';
            ExtendedDatatype = EMail;
            DataClassification = CustomerContent;
        }
        field(313; "SMS No."; Text[30])
        {
            Caption = 'SMS No.';
            DataClassification = CustomerContent;
        }
        field(400; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if (xRec."Shipping Agent Code" <> '') and (xRec."Shipping Agent Code" <> "Shipping Agent Code") then
                    DeleteShippingAgentServices(Rec, true);
            end;
        }
        field(401; "Package Code"; Code[20])
        {
            Caption = 'Package Code';
            TableRelation = "NPR Pacsoft Package Code".Code;
            DataClassification = CustomerContent;
        }
        field(402; Reference; Text[35])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
        }
        field(403; "Free Text"; Text[50])
        {
            Caption = 'Free Text';
            DataClassification = CustomerContent;
        }
        field(404; "Shipment Date"; Date)
        {
            Caption = 'Shipment Date';
            DataClassification = CustomerContent;
        }
        field(405; "Return Label"; Boolean)
        {
            Caption = 'Return Label';
            InitValue = false;
            DataClassification = CustomerContent;
        }
        field(406; Undeliverable; Option)
        {
            Caption = 'If Nondeliverable';
            OptionCaption = 'Return,Abandon';
            OptionMembers = RETURN,ABANDON;
            DataClassification = CustomerContent;
        }
        field(407; "Parcel Qty."; Integer)
        {
            Caption = 'Parcel Qty.';
            InitValue = 1;
            MinValue = 1;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Parcel Qty." = 1 then
                    "Total Weight" := "Parcel Weight"
                else
                    "Total Weight" := "Parcel Qty." * "Parcel Weight";
            end;
        }
        field(408; "Parcel Weight"; Decimal)
        {
            Caption = 'Parcel Weight';
            InitValue = 0.01;
            MinValue = 0.01;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Total Weight" := "Parcel Qty." * "Parcel Weight";
            end;
        }
        field(409; "Total Weight"; Decimal)
        {
            Caption = 'Total Weight';
            InitValue = 0.01;
            MinValue = 0.01;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Parcel Qty." <> 0 then
                    "Parcel Weight" := "Total Weight" / "Parcel Qty.";
            end;
        }
        field(410; Marking; Text[30])
        {
            Caption = 'Marking';
            DataClassification = CustomerContent;
        }
        field(411; Volume; Text[30])
        {
            Caption = 'Volume';
            DataClassification = CustomerContent;
        }
        field(412; Contents; Text[30])
        {
            Caption = 'Contents';
            DataClassification = CustomerContent;
        }
        field(500; "Customs Document"; Option)
        {
            Caption = 'Customs Document';
            OptionCaption = ' ,CN23,Trade Invoice,Pro Forma Invoice';
            OptionMembers = " ",CN23,"Trade Invoice","Pro Forma Invoice";
            DataClassification = CustomerContent;
        }
        field(501; "Customs Currency"; Code[10])
        {
            Caption = 'Customs Currency';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(502; "Sender VAT Reg. No"; Text[20])
        {
            Caption = 'Sender VAT Reg. No';
            DataClassification = CustomerContent;
        }
        field(600; "Send Link To Print"; Boolean)
        {
            Caption = 'Send Link To Print';
            DataClassification = CustomerContent;
        }
        field(700; "Delivery Location"; Code[10])
        {
            Caption = 'Delivery Location';
            DataClassification = CustomerContent;
        }
        field(701; "Ship-to Name"; Text[100])
        {
            Caption = 'Ship-to Name';
            DataClassification = CustomerContent;
        }
        field(702; "Ship-to Address"; Text[100])
        {
            Caption = 'Ship-to Address';
            DataClassification = CustomerContent;
        }
        field(703; "Ship-to Address 2"; Text[50])
        {
            Caption = 'Ship-to Address 2';
            DataClassification = CustomerContent;
        }
        field(704; "Ship-to Post Code"; Code[20])
        {
            Caption = 'Ship-to Post Code';
            DataClassification = CustomerContent;
        }
        field(705; "Ship-to City"; Text[30])
        {
            Caption = 'Ship-to City';
            DataClassification = CustomerContent;
        }
        field(706; "Ship-to County"; Text[30])
        {
            Caption = 'Ship-to County';
            DataClassification = CustomerContent;
        }
        field(707; "Ship-to Country/Region Code"; Code[10])
        {
            Caption = 'Ship-to Country/Region Code';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
        }
        field(720; "Return Label Both"; Boolean)
        {
            Caption = 'Return Label Both';
            DataClassification = CustomerContent;
        }
        field(800; "Request XML"; BLOB)
        {
            Caption = 'Document Source';
            DataClassification = CustomerContent;
        }
        field(801; "Request XML Name"; Text[50])
        {
            Caption = 'Document Name';
            DataClassification = CustomerContent;
        }
        field(802; "Response XML"; BLOB)
        {
            Caption = 'Response XML';
            DataClassification = CustomerContent;
        }
        field(803; "Response XML Name"; Text[50])
        {
            Caption = 'Response XML Name';
            DataClassification = CustomerContent;
        }
        field(850; "Response Shipment ID"; Text[50])
        {
            Caption = 'Response Shipment ID';
            DataClassification = CustomerContent;
        }
        field(851; "Response Package No."; Text[50])
        {
            Caption = 'Response Package No.';
            DataClassification = CustomerContent;
        }
        field(853; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            DataClassification = CustomerContent;
        }
        field(854; "Order No."; Code[20])
        {
            Caption = 'Order No.';
            DataClassification = CustomerContent;
        }
        field(855; "Shipping Method Code"; Code[10])
        {
            Caption = 'Shipping Method Code';
            DataClassification = CustomerContent;
        }
        field(856; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            DataClassification = CustomerContent;
        }
        field(857; "Delivery Instructions"; Text[50])
        {
            Caption = 'Delivery Instructions';
            DataClassification = CustomerContent;
        }
        field(858; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(859; "Your Reference"; Text[35])
        {
            Caption = 'Your Reference';
            DataClassification = CustomerContent;
        }
        field(860; "Print Return Label"; Boolean)
        {
            Caption = 'Print Return Label';
            DataClassification = CustomerContent;
        }
        field(861; "Return Response Shipment ID"; Text[50])
        {
            Caption = 'Return Response Shipment ID';
            DataClassification = CustomerContent;
        }
        field(862; "Return Response Package No."; Text[50])
        {
            Caption = 'Return Response Package No.';
            DataClassification = CustomerContent;
        }
        field(863; "Return Shipping Agent Code"; Code[10])
        {
            Caption = 'Return Shipping Agent Code';
            TableRelation = "Shipping Agent";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if (xRec."Shipping Agent Code" <> '') and (xRec."Shipping Agent Code" <> "Shipping Agent Code") then
                    DeleteShippingAgentServices(Rec, true);
            end;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Export Time")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        DeleteShippingAgentServices(Rec, false);
    end;

    procedure AddEntry(RecRef: RecordRef; ShowWindow: Boolean)
    var
        CompanyInfo: Record "Company Information";
        ShipmentDocument: Record "NPR Pacsoft Shipment Document";
        ShipmentDocument2: Record "NPR Pacsoft Shipment Document";
        ShipmentDocServices: Record "NPR Pacsoft Shipm. Doc. Serv.";
        CustomsItemRows: Record "NPR Pacsoft Customs Item Rows";
        Customer: Record Customer;
        SalesShipmentHeader: Record "Sales Shipment Header";
        ShipToAddress: Record "Ship-to Address";
        ShippingAgentServices: Record "Shipping Agent Services";
        PacsoftMgt: Codeunit "NPR Pacsoft Management";
        TextNotActivated: Label 'The Pacsoft integration is not activated.';
        PacsoftSetup: Record "NPR Pacsoft Setup";
        CreateShipmentDocument: Page "NPR Pacsoft Shipment Document";
        ShippingAgentServicesCode: Code[10];
    begin
        if not PacsoftSetup.Get() then exit;
        if (not PacsoftSetup."Use Pacsoft integration") and (not ShowWindow) then exit;
        if (not PacsoftSetup."Use Pacsoft integration") and (ShowWindow) then
            Error(TextNotActivated);

        Clear(ShipmentDocument);
        ShipmentDocument.Init();
        ShipmentDocument.Validate("Entry No.", 0);
        ShipmentDocument.Validate("Table No.", RecRef.Number);
        ShipmentDocument.Validate(RecordID, RecRef.RecordId);
        ShipmentDocument.Validate("Creation Time", CurrentDateTime);
        ShipmentDocument.Insert(true);

        case RecRef.Number of
            DATABASE::"Sales Shipment Header":
                begin
                    RecRef.SetTable(SalesShipmentHeader);
                    if SalesShipmentHeader.Find() then begin
                        Customer.Get(SalesShipmentHeader."Sell-to Customer No.");
                        ShippingAgentServicesCode := SalesShipmentHeader."Shipping Agent Service Code";

                        Clear(ShipToAddress);
                        if not ShipToAddress.Get(SalesShipmentHeader."Sell-to Customer No.", SalesShipmentHeader."Ship-to Code") then begin
                            ShipToAddress."Phone No." := Customer."Phone No.";
                            ShipToAddress."Fax No." := Customer."Fax No.";
                            ShipToAddress."E-Mail" := Customer."E-Mail";
                        end;
                        ShipmentDocument."Receiver ID" := SalesShipmentHeader."Sell-to Customer No.";

                        ShipmentDocument.Name := SalesShipmentHeader."Ship-to Name";
                        ShipmentDocument.Address := SalesShipmentHeader."Ship-to Address";
                        ShipmentDocument."Address 2" := SalesShipmentHeader."Ship-to Address 2";
                        ShipmentDocument."Post Code" := SalesShipmentHeader."Ship-to Post Code";
                        ShipmentDocument.City := SalesShipmentHeader."Ship-to City";
                        ShipmentDocument.County := SalesShipmentHeader."Ship-to County";
                        ShipmentDocument."Country/Region Code" := SalesShipmentHeader."Ship-to Country/Region Code";
                        ShipmentDocument.Contact := SalesShipmentHeader."Ship-to Contact";
                        ShipmentDocument.Reference := SalesShipmentHeader."Your Reference";
                        ShipmentDocument."Shipment Date" := SalesShipmentHeader."Shipment Date";
                        ShipmentDocument."Phone No." := ShipToAddress."Phone No.";
                        ShipmentDocument."Fax No." := ShipToAddress."Fax No.";
                        ShipmentDocument."VAT Registration No." := Customer."VAT Registration No.";
                        ShipmentDocument."E-Mail" := ShipToAddress."E-Mail";
                        ShipmentDocument."SMS No." := ShipToAddress."Phone No.";
                        ShipmentDocument."Shipping Agent Code" := SalesShipmentHeader."Shipping Agent Code";

                        if SalesShipmentHeader."NPR Delivery Location" <> '' then begin
                            ShipmentDocument.Name := SalesShipmentHeader."Bill-to Name";
                            ShipmentDocument.Address := SalesShipmentHeader."Bill-to Address";
                            ShipmentDocument."Address 2" := SalesShipmentHeader."Bill-to Address 2";
                            ShipmentDocument."Post Code" := SalesShipmentHeader."Bill-to Post Code";
                            ShipmentDocument.City := SalesShipmentHeader."Bill-to City";
                            ShipmentDocument.County := SalesShipmentHeader."Bill-to County";
                            ShipmentDocument."Country/Region Code" := SalesShipmentHeader."Bill-to Country/Region Code";
                            ShipmentDocument.Contact := SalesShipmentHeader."Bill-to Contact";

                            ShipmentDocument."Delivery Location" := SalesShipmentHeader."NPR Delivery Location";
                            ShipmentDocument."Ship-to Name" := SalesShipmentHeader."Ship-to Name";
                            ShipmentDocument."Ship-to Address" := SalesShipmentHeader."Ship-to Address";
                            ShipmentDocument."Ship-to Address 2" := SalesShipmentHeader."Ship-to Address 2";
                            ShipmentDocument."Ship-to Post Code" := SalesShipmentHeader."Ship-to Post Code";
                            ShipmentDocument."Ship-to City" := SalesShipmentHeader."Ship-to City";
                            ShipmentDocument."Ship-to County" := SalesShipmentHeader."Ship-to County";
                            ShipmentDocument."Ship-to Country/Region Code" := SalesShipmentHeader."Ship-to Country/Region Code"
                        end;

                        if PacsoftSetup."Order No. to Reference" then
                            if SalesShipmentHeader."Order No." <> '' then
                                ShipmentDocument.Reference := CopyStr(SalesShipmentHeader."Order No.", 1,
                                                                      MaxStrLen(ShipmentDocument.Reference));
                    end;
                end;
        end;

        CompanyInfo.Get();
        ShipmentDocument."Sender VAT Reg. No" := CompanyInfo."VAT Registration No.";
        if ShipmentDocument."Country/Region Code" = '' then
            ShipmentDocument."Country/Region Code" := CompanyInfo."Country/Region Code";
        if ShipmentDocument."Shipment Date" < Today then
            ShipmentDocument."Shipment Date" := Today();

        ShipmentDocument.Modify(true);

        if ShipmentDocument."Shipping Agent Code" <> '' then begin
            Clear(ShippingAgentServices);
            ShippingAgentServices.SetCurrentKey("Shipping Agent Code");
            ShippingAgentServices.SetRange("Shipping Agent Code", ShipmentDocument."Shipping Agent Code");
            ShippingAgentServices.SetRange("NPR Default Option", true);
            if ShippingAgentServices.FindSet() then begin
                repeat
                    Clear(ShipmentDocServices);
                    ShipmentDocServices.Validate("Entry No.", ShipmentDocument."Entry No.");
                    ShipmentDocServices.Validate("Shipping Agent Code", ShippingAgentServices."Shipping Agent Code");
                    ShipmentDocServices.Validate("Shipping Agent Service Code", ShippingAgentServices.Code);
                    ShipmentDocServices.Insert(true);
                until ShippingAgentServices.Next() = 0;
            end
            else begin
                if (ShippingAgentServicesCode <> '') and (PacsoftSetup."Create Shipping Services Line") then begin
                    Clear(ShippingAgentServices);
                    ShippingAgentServices.SetCurrentKey("Shipping Agent Code");
                    ShippingAgentServices.SetRange("Shipping Agent Code", ShipmentDocument."Shipping Agent Code");
                    ShippingAgentServices.SetRange(Code, ShippingAgentServicesCode);
                    ShippingAgentServices.SetRange("NPR Default Option", false);
                    if ShippingAgentServices.FindSet() then
                        repeat
                            Clear(ShipmentDocServices);
                            ShipmentDocServices.Validate("Entry No.", ShipmentDocument."Entry No.");
                            ShipmentDocServices.Validate("Shipping Agent Code", ShippingAgentServices."Shipping Agent Code");
                            ShipmentDocServices.Validate("Shipping Agent Service Code", ShippingAgentServices.Code);
                            ShipmentDocServices.Insert(true);
                        until ShippingAgentServices.Next() = 0;
                end;
            end;
        end;

        if ShipmentDocument."Delivery Location" <> '' then
            if ShippingAgentServices.Get(ShipmentDocument."Shipping Agent Code", 'PUPOPT') then begin
                if not ShipmentDocServices.Get(ShipmentDocument."Entry No.", ShippingAgentServices."Shipping Agent Code", ShippingAgentServices.Code) then begin

                    Clear(ShipmentDocServices);
                    ShipmentDocServices.Validate("Entry No.", ShipmentDocument."Entry No.");
                    ShipmentDocServices.Validate("Shipping Agent Code", ShippingAgentServices."Shipping Agent Code");
                    ShipmentDocServices.Validate("Shipping Agent Service Code", ShippingAgentServices.Code);
                    ShipmentDocServices.Insert(true);
                end;

            end;

        if ShowWindow then begin
            Commit();
            ShipmentDocument.SetRecFilter();
            Clear(CreateShipmentDocument);
            CreateShipmentDocument.LookupMode(false);
            CreateShipmentDocument.SetRecord(ShipmentDocument);
            CreateShipmentDocument.RunModal();
            if CreateShipmentDocument.OKButtonWasPressed() then begin
                CreateShipmentDocument.GetRecord(ShipmentDocument);
                ShipmentDocument.Modify(true);
                if PacsoftSetup."Send Doc. Immediately(Pacsoft)" then
                    PacsoftMgt.SendDocument(ShipmentDocument, false);
            end
            else begin
                ShipmentDocument2.Get(ShipmentDocument."Entry No.");
                ShipmentDocument2.Delete(true);

                Clear(CustomsItemRows);
                CustomsItemRows.SetCurrentKey("Shipment Document Entry No.", "Entry No.");
                CustomsItemRows.SetRange("Shipment Document Entry No.", ShipmentDocument."Entry No.");
                CustomsItemRows.DeleteAll(true);
            end;
        end
        else
            if PacsoftSetup."Send Doc. Immediately(Pacsoft)" then
                PacsoftMgt.SendDocument(ShipmentDocument, false);
    end;

    procedure DeleteShippingAgentServices(pShipmentDocument: Record "NPR Pacsoft Shipment Document"; WithDialog: Boolean)
    var
        ShipmentDocServices: Record "NPR Pacsoft Shipm. Doc. Serv.";
        TextConfirm: Label 'The chosen Shipping Agent Services will be deleted. Continue ?';
    begin
        if WithDialog then begin
            Clear(ShipmentDocServices);
            ShipmentDocServices.SetCurrentKey("Entry No.", "Shipping Agent Code", "Shipping Agent Service Code");
            ShipmentDocServices.SetRange("Entry No.", pShipmentDocument."Entry No.");
            if not ShipmentDocServices.FindFirst() then
                WithDialog := false
        end;

        if WithDialog then
            if not Confirm(TextConfirm, true) then
                Error('');

        Clear(ShipmentDocServices);
        ShipmentDocServices.SetCurrentKey("Entry No.", "Shipping Agent Code", "Shipping Agent Service Code");
        ShipmentDocServices.SetRange("Entry No.", pShipmentDocument."Entry No.");
        ShipmentDocServices.DeleteAll(true);
    end;

    procedure ShowTrackAndTrace(pShipmentDocument: Record "NPR Pacsoft Shipment Document")
    var
        ShippingAgent: Record "Shipping Agent";
        TrackingInternetAddr: Text[250];
        PacsoftSetup: Record "NPR Pacsoft Setup";
    begin

        if pShipmentDocument."Entry No." = 0 then exit;

        PacsoftSetup.Get();

        pShipmentDocument.TestField("Shipping Agent Code");
        ShippingAgent.Get(pShipmentDocument."Shipping Agent Code");
        ShippingAgent.TestField("Internet Address");
        if pShipmentDocument."Response Package No." <> '' then
            TrackingInternetAddr := StrSubstNo(ShippingAgent."Internet Address", pShipmentDocument."Response Package No.")
        else
            TrackingInternetAddr := StrSubstNo(ShippingAgent."Internet Address", PacsoftSetup.User, pShipmentDocument."Entry No.");
        HyperLink(TrackingInternetAddr);
    end;
}

