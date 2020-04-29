table 6014452 "Pacsoft Shipment Document"
{
    // PS1.00/LS/20140509  CASE 190533 Settings taken from table 6014469 as setup
    // PS1.01/LS/20141216  CASE 200974 : If the setup "Create Shipping Services Line" is checked and ShippingAgentServices is not default
    //                                    then create a shipping Line
    // PS1.02/RA/20150121   CASE 190533 Added field 800 and 801
    // PS1.03/RA/20160809  CASE 228449
    //   Renamed field 800 from "Document Source" to "Request XML"
    //   Renamed field 801 from "Document Name" to "Request XML Name"
    //   Added fields 802 and 803
    // NPR5.26/BHR/20160831 CASE 248912 Add fields 850.. for pakkelabel
    // NPR5.29/BHR/20160929 CASE 248684
    //                                  fill Parcel Qty
    //                                  Added field 6014455 Pick up point
    //                                  Function moved to codeunit 6014490
    // NPR5.34/BHR/20170703 CASE 282595 Correct Bug related to 'Ship-to Code'
    // NPR5.36/BHR/20170926 CASE 290780 Add field "delivery Instructions", "External Document No.", "Your reference"
    // NPR5.43/BHR/20180805 CASE 304453 Add field "Print Return Label"
    // NPR5.45/BHR /20180831 CASE 326205 Add field Change caption For return Labels
    // NPR5.51/BHR /20190716 CASE 361583 Add Track and Trace functionality for packkelabels

    Caption = 'Pacsoft Shipment Document';
    DrillDownPageID = "Pacsoft Shipment Documents";
    LookupPageID = "Pacsoft Shipment Documents";
    PasteIsValid = false;

    fields
    {
        field(1;"Entry No.";BigInteger)
        {
            Caption = 'Entry No.';

            trigger OnValidate()
            var
                ShipmentDocument: Record "Pacsoft Shipment Document";
            begin
                if "Entry No." = 0 then begin
                  Clear(ShipmentDocument);
                  if ShipmentDocument.FindLast then
                    "Entry No." := ShipmentDocument."Entry No." + 1
                  else
                    "Entry No." := 1;
                end;
            end;
        }
        field(5;"Table No.";Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Table));
        }
        field(10;RecordID;RecordID)
        {
            Caption = 'RecordID';
        }
        field(100;"Creation Time";DateTime)
        {
            Caption = 'Creation Time';
        }
        field(101;"Export Time";DateTime)
        {
            Caption = 'Export Time';
        }
        field(200;Status;Text[10])
        {
            Caption = 'Status';
        }
        field(201;"Return Message";Text[250])
        {
            Caption = 'Return Message';
        }
        field(202;Session;Text[100])
        {
            Caption = 'Session';
        }
        field(300;"Receiver ID";Code[20])
        {
            Caption = 'Receiver ID';
        }
        field(301;Name;Text[50])
        {
            Caption = 'Name';
        }
        field(302;Address;Text[50])
        {
            Caption = 'Address';
        }
        field(303;"Address 2";Text[50])
        {
            Caption = 'Address 2';
        }
        field(304;"Post Code";Code[20])
        {
            Caption = 'Post Code';
        }
        field(305;City;Text[30])
        {
            Caption = 'City';
        }
        field(306;County;Text[30])
        {
            Caption = 'County';
        }
        field(307;"Country/Region Code";Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(308;Contact;Text[50])
        {
            Caption = 'Contact';
        }
        field(309;"Phone No.";Text[30])
        {
            Caption = 'Phone No.';
            ExtendedDatatype = PhoneNo;

            trigger OnValidate()
            begin
                if "SMS No." = '' then
                  "SMS No." := "Phone No.";
            end;
        }
        field(310;"Fax No.";Text[30])
        {
            Caption = 'Fax No.';
        }
        field(311;"VAT Registration No.";Text[20])
        {
            Caption = 'VAT Registration No.';

            trigger OnValidate()
            var
                VATRegNoFormat: Record "VAT Registration No. Format";
            begin
            end;
        }
        field(312;"E-Mail";Text[80])
        {
            Caption = 'E-Mail';
            ExtendedDatatype = EMail;
        }
        field(313;"SMS No.";Text[30])
        {
            Caption = 'SMS No.';
        }
        field(400;"Shipping Agent Code";Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";

            trigger OnValidate()
            begin
                if (xRec."Shipping Agent Code" <> '') and (xRec."Shipping Agent Code" <> "Shipping Agent Code") then
                  DeleteShippingAgentServices(Rec, true);
            end;
        }
        field(401;"Package Code";Code[10])
        {
            Caption = 'Package Code';
            TableRelation = "Pacsoft Package Code";
        }
        field(402;Reference;Text[35])
        {
            Caption = 'Reference';
        }
        field(403;"Free Text";Text[50])
        {
            Caption = 'Free Text';
        }
        field(404;"Shipment Date";Date)
        {
            Caption = 'Shipment Date';
        }
        field(405;"Return Label";Boolean)
        {
            Caption = 'Return Label';
            InitValue = false;
        }
        field(406;Undeliverable;Option)
        {
            Caption = 'If Nondeliverable';
            OptionCaption = 'Return,Abandon';
            OptionMembers = RETURN,ABANDON;
        }
        field(407;"Parcel Qty.";Integer)
        {
            Caption = 'Parcel Qty.';
            InitValue = 1;
            MinValue = 1;

            trigger OnValidate()
            begin
                if "Parcel Qty." = 1 then
                  "Total Weight" := "Parcel Weight"
                else
                  "Total Weight" := "Parcel Qty." * "Parcel Weight";
            end;
        }
        field(408;"Parcel Weight";Decimal)
        {
            Caption = 'Parcel Weight';
            InitValue = 0.01;
            MinValue = 0.01;

            trigger OnValidate()
            begin
                "Total Weight" := "Parcel Qty." * "Parcel Weight";
            end;
        }
        field(409;"Total Weight";Decimal)
        {
            Caption = 'Total Weight';
            InitValue = 0.01;
            MinValue = 0.01;

            trigger OnValidate()
            begin
                //-248684 [248684]
                //"Parcel Weight" := 0;
                if "Parcel Qty." <> 0 then
                "Parcel Weight" := "Total Weight"/"Parcel Qty.";
                //+248684 [248684]
            end;
        }
        field(410;Marking;Text[30])
        {
            Caption = 'Marking';
        }
        field(411;Volume;Text[30])
        {
            Caption = 'Volume';
        }
        field(412;Contents;Text[30])
        {
            Caption = 'Contents';
        }
        field(500;"Customs Document";Option)
        {
            Caption = 'Customs Document';
            OptionCaption = ' ,CN23,Trade Invoice,Pro Forma Invoice';
            OptionMembers = " ",CN23,"Trade Invoice","Pro Forma Invoice";
        }
        field(501;"Customs Currency";Code[10])
        {
            Caption = 'Customs Currency';
            TableRelation = Currency;
        }
        field(502;"Sender VAT Reg. No";Text[20])
        {
            Caption = 'Sender VAT Reg. No';
        }
        field(600;"Send Link To Print";Boolean)
        {
            Caption = 'Send Link To Print';
        }
        field(700;"Delivery Location";Code[10])
        {
            Caption = 'Delivery Location';
        }
        field(701;"Ship-to Name";Text[50])
        {
            Caption = 'Ship-to Name';
        }
        field(702;"Ship-to Address";Text[50])
        {
            Caption = 'Ship-to Address';
        }
        field(703;"Ship-to Address 2";Text[50])
        {
            Caption = 'Ship-to Address 2';
        }
        field(704;"Ship-to Post Code";Code[20])
        {
            Caption = 'Ship-to Post Code';
        }
        field(705;"Ship-to City";Text[30])
        {
            Caption = 'Ship-to City';
        }
        field(706;"Ship-to County";Text[30])
        {
            Caption = 'Ship-to County';
        }
        field(707;"Ship-to Country/Region Code";Code[10])
        {
            Caption = 'Ship-to Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(720;"Return Label Both";Boolean)
        {
            Caption = 'Return Label Both';
        }
        field(800;"Request XML";BLOB)
        {
            Caption = 'Document Source';
        }
        field(801;"Request XML Name";Text[50])
        {
            Caption = 'Document Name';
        }
        field(802;"Response XML";BLOB)
        {
            Caption = 'Response XML';
        }
        field(803;"Response XML Name";Text[50])
        {
            Caption = 'Response XML Name';
        }
        field(850;"Response Shipment ID";Text[50])
        {
            Caption = 'Response Shipment ID';
        }
        field(851;"Response Package No.";Text[50])
        {
            Caption = 'Response Package No.';
        }
        field(853;"Ship-to Code";Code[10])
        {
            Caption = 'Ship-to Code';
        }
        field(854;"Order No.";Code[20])
        {
            Caption = 'Order No.';
        }
        field(855;"Shipping Method Code";Code[10])
        {
            Caption = 'Shipping Method Code';
        }
        field(856;"Shipping Agent Service Code";Code[10])
        {
            Caption = 'Shipping Agent Service Code';
        }
        field(857;"Delivery Instructions";Text[50])
        {
            Caption = 'Delivery Instructions';
        }
        field(858;"External Document No.";Code[35])
        {
            Caption = 'External Document No.';
        }
        field(859;"Your Reference";Text[35])
        {
            Caption = 'Your Reference';
        }
        field(860;"Print Return Label";Boolean)
        {
            Caption = 'Print Return Label';
        }
        field(861;"Return Response Shipment ID";Text[50])
        {
            Caption = 'Return Response Shipment ID';
        }
        field(862;"Return Response Package No.";Text[50])
        {
            Caption = 'Return Response Package No.';
        }
        field(863;"Return Shipping Agent Code";Code[10])
        {
            Caption = 'Return Shipping Agent Code';
            TableRelation = "Shipping Agent";

            trigger OnValidate()
            begin
                if (xRec."Shipping Agent Code" <> '') and (xRec."Shipping Agent Code" <> "Shipping Agent Code") then
                  DeleteShippingAgentServices(Rec, true);
            end;
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Export Time")
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

    procedure AddEntry(RecRef: RecordRef;ShowWindow: Boolean)
    var
        CompanyInfo: Record "Company Information";
        ShipmentDocument: Record "Pacsoft Shipment Document";
        ShipmentDocument2: Record "Pacsoft Shipment Document";
        ShipmentDocServices: Record "Pacsoft Shipment Doc. Services";
        CustomsItemRows: Record "Pacsoft Customs Item Rows";
        Customer: Record Customer;
        Vendor: Record Vendor;
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        ShipToAddress: Record "Ship-to Address";
        Job: Record Job;
        Contact: Record Contact;
        ShippingAgentServices: Record "Shipping Agent Services";
        PacsoftMgt: Codeunit "Pacsoft Management";
        TextNotActivated: Label 'The Pacsoft integration is not activated.';
        PacsoftSetup: Record "Pacsoft Setup";
        CreateShipmentDocument: Page "Pacsoft Shipment Document";
        "//-PS1.01": Integer;
        ShippingAgentServicesCode: Code[10];
        "//+PS1.01": Integer;
    begin
        if not PacsoftSetup.Get then exit;
        if (not PacsoftSetup."Use Pacsoft integration") and (not ShowWindow) then exit;
        if (not PacsoftSetup."Use Pacsoft integration") and (ShowWindow) then
          Error(TextNotActivated);

        Clear(ShipmentDocument);
        ShipmentDocument.Init;
        ShipmentDocument.Validate("Entry No.", 0);
        ShipmentDocument.Validate("Table No.",RecRef.Number);
        ShipmentDocument.Validate(RecordID, RecRef.RecordId);
        ShipmentDocument.Validate("Creation Time", CurrentDateTime);
        ShipmentDocument.Insert(true);

        case RecRef.Number of
          DATABASE::Customer : begin
                                 RecRef.SetTable(Customer);
                                 if Customer.Find then
                                   with Customer do begin
                                     ShipmentDocument."Receiver ID" := "No.";
                                     ShipmentDocument.Name := Name;
                                     ShipmentDocument.Address := Address;
                                     ShipmentDocument."Address 2" := "Address 2";
                                     ShipmentDocument."Post Code" := "Post Code";
                                     ShipmentDocument.City := City;
                                     ShipmentDocument.County := County;
                                     ShipmentDocument."Country/Region Code" := "Country/Region Code";
                                     ShipmentDocument.Contact := Contact;
                                     ShipmentDocument.Reference := '';
                                     ShipmentDocument."Shipment Date" := Today;
                                     ShipmentDocument."Phone No." := "Phone No.";
                                     ShipmentDocument."Fax No." := "Fax No.";
                                     ShipmentDocument."VAT Registration No." := "VAT Registration No.";
                                     ShipmentDocument."E-Mail" := "E-Mail";
                                     ShipmentDocument."SMS No." := "Phone No.";
                                     ShipmentDocument."Shipping Agent Code" := "Shipping Agent Code";
                                   end;
                               end;
          DATABASE::Vendor : begin
                               RecRef.SetTable(Vendor);
                               if Vendor.Find then
                                 with Vendor do begin
                                   ShipmentDocument."Receiver ID" := "No.";
                                   ShipmentDocument.Name := Name;
                                   ShipmentDocument.Address := Address;
                                   ShipmentDocument."Address 2" := "Address 2";
                                   ShipmentDocument."Post Code" := "Post Code";
                                   ShipmentDocument.City := City;
                                   ShipmentDocument.County := County;
                                   ShipmentDocument."Country/Region Code" := "Country/Region Code";
                                   ShipmentDocument.Contact := Contact;
                                   ShipmentDocument.Reference := '';
                                   ShipmentDocument."Shipment Date" := Today;
                                   ShipmentDocument."Phone No." := "Phone No.";
                                   ShipmentDocument."Fax No." := "Fax No.";
                                   ShipmentDocument."VAT Registration No." := "VAT Registration No.";
                                   ShipmentDocument."E-Mail" := "E-Mail";
                                   ShipmentDocument."SMS No." := "Phone No.";
                                   ShipmentDocument."Shipping Agent Code" := "Shipping Agent Code";
                                 end;
                             end;
          DATABASE::"Sales Header" : begin
                                       RecRef.SetTable(SalesHeader);
                                       if SalesHeader.Find then
                                         with SalesHeader do begin
                                           Customer.Get("Sell-to Customer No.");
                                           //-PS1.01
                                           ShippingAgentServicesCode := "Shipping Agent Service Code";
                                           //+PS1.01

                                           Clear(ShipToAddress);
                                           if not ShipToAddress.Get("Sell-to Customer No.", "Ship-to Code") then begin
                                             //-NPR5.34 [282595]
                                             //"Ship-to Code" := "Sell-to Customer No.";
                                             //+NPR5.34 [282595]
                                             ShipToAddress."Phone No." := Customer."Phone No.";
                                             ShipToAddress."Fax No." := Customer."Fax No.";
                                             ShipToAddress."E-Mail" := Customer."E-Mail";
                                           end;

                                           //-NPR5.34 [282595]
                                           //ShipmentDocument."Receiver ID" := "Ship-to Code";
                                           ShipmentDocument."Receiver ID":= "Sell-to Customer No.";
                                           //+NPR5.34 [282595]
                                           ShipmentDocument.Name := "Ship-to Name";
                                           ShipmentDocument.Address := "Ship-to Address";
                                           ShipmentDocument."Address 2" := "Ship-to Address 2";
                                           ShipmentDocument."Post Code" := "Ship-to Post Code";
                                           ShipmentDocument.City := "Ship-to City";
                                           ShipmentDocument.County := "Ship-to County";
                                           ShipmentDocument."Country/Region Code" := "Ship-to Country/Region Code";
                                           ShipmentDocument.Contact := "Ship-to Contact";
                                           ShipmentDocument.Reference := "Your Reference";
                                           ShipmentDocument."Shipment Date" := "Shipment Date";
                                           ShipmentDocument."Phone No." := ShipToAddress."Phone No.";
                                           ShipmentDocument."Fax No." := ShipToAddress."Fax No.";
                                           ShipmentDocument."VAT Registration No." := Customer."VAT Registration No.";
                                           ShipmentDocument."E-Mail" := ShipToAddress."E-Mail";
                                           ShipmentDocument."SMS No." := ShipToAddress."Phone No.";
                                           ShipmentDocument."Shipping Agent Code" := "Shipping Agent Code";

                                           if "Delivery Location" <> '' then begin
                                             ShipmentDocument.Name := "Bill-to Name";
                                             ShipmentDocument.Address := "Bill-to Address";
                                             ShipmentDocument."Address 2" := "Bill-to Address 2";
                                             ShipmentDocument."Post Code" := "Bill-to Post Code";
                                             ShipmentDocument.City := "Bill-to City";
                                             ShipmentDocument.County := "Bill-to County";
                                             ShipmentDocument."Country/Region Code" := "Bill-to Country/Region Code";
                                             ShipmentDocument.Contact := "Bill-to Contact";

                                             ShipmentDocument."Delivery Location" := "Delivery Location";
                                             ShipmentDocument."Ship-to Name" := "Ship-to Name";
                                             ShipmentDocument."Ship-to Address" := "Ship-to Address";
                                             ShipmentDocument."Ship-to Address 2" := "Ship-to Address 2";
                                             ShipmentDocument."Ship-to Post Code" := "Ship-to Post Code";
                                             ShipmentDocument."Ship-to City" := "Ship-to City";
                                             ShipmentDocument."Ship-to County" := "Ship-to County";
                                             ShipmentDocument."Ship-to Country/Region Code" := "Ship-to Country/Region Code"
                                           end;
                                       end;
                                     end;
          DATABASE::"Purchase Header" : begin
                                          RecRef.SetTable(PurchHeader);
                                          if PurchHeader.Find then begin
                                                                   end;
                                        end;
          DATABASE::"Sales Shipment Header" :  begin
                                                 RecRef.SetTable(SalesShipmentHeader);
                                                 if SalesShipmentHeader.Find then
                                                   with SalesShipmentHeader do begin
                                                     Customer.Get("Sell-to Customer No.");
                                                     //-PS1.01
                                                     ShippingAgentServicesCode := "Shipping Agent Service Code";
                                                     //+PS1.01

                                                     Clear(ShipToAddress);
                                                     if not ShipToAddress.Get("Sell-to Customer No.", "Ship-to Code") then begin
                                                     //-NPR5.34 [282595]
                                                     //"Ship-to Code" := "Sell-to Customer No.";
                                                     //+NPR5.34 [282595]
                                                       ShipToAddress."Phone No." := Customer."Phone No.";
                                                       ShipToAddress."Fax No." := Customer."Fax No.";
                                                       ShipToAddress."E-Mail" := Customer."E-Mail";
                                                     end;

                                                     //-NPR5.34 [282595]
                                                     //ShipmentDocument."Receiver ID" := "Ship-to Code";
                                                     ShipmentDocument."Receiver ID":= "Sell-to Customer No.";
                                                     //+NPR5.34 [282595]
                                                     ShipmentDocument.Name := "Ship-to Name";
                                                     ShipmentDocument.Address := "Ship-to Address";
                                                     ShipmentDocument."Address 2" := "Ship-to Address 2";
                                                     ShipmentDocument."Post Code" := "Ship-to Post Code";
                                                     ShipmentDocument.City := "Ship-to City";
                                                     ShipmentDocument.County := "Ship-to County";
                                                     ShipmentDocument."Country/Region Code" := "Ship-to Country/Region Code";
                                                     ShipmentDocument.Contact := "Ship-to Contact";
                                                     ShipmentDocument.Reference := "Your Reference";
                                                     ShipmentDocument."Shipment Date" := "Shipment Date";
                                                     ShipmentDocument."Phone No." := ShipToAddress."Phone No.";
                                                     ShipmentDocument."Fax No." := ShipToAddress."Fax No.";
                                                     ShipmentDocument."VAT Registration No." := Customer."VAT Registration No.";
                                                     ShipmentDocument."E-Mail" := ShipToAddress."E-Mail";
                                                     ShipmentDocument."SMS No." := ShipToAddress."Phone No.";
                                                     ShipmentDocument."Shipping Agent Code" := "Shipping Agent Code";

                                                     if "Delivery Location" <> '' then begin
                                                       ShipmentDocument.Name := "Bill-to Name";
                                                       ShipmentDocument.Address := "Bill-to Address";
                                                       ShipmentDocument."Address 2" := "Bill-to Address 2";
                                                       ShipmentDocument."Post Code" := "Bill-to Post Code";
                                                       ShipmentDocument.City := "Bill-to City";
                                                       ShipmentDocument.County := "Bill-to County";
                                                       ShipmentDocument."Country/Region Code" := "Bill-to Country/Region Code";
                                                       ShipmentDocument.Contact := "Bill-to Contact";

                                                       ShipmentDocument."Delivery Location" := "Delivery Location";
                                                       ShipmentDocument."Ship-to Name" := "Ship-to Name";
                                                       ShipmentDocument."Ship-to Address" := "Ship-to Address";
                                                       ShipmentDocument."Ship-to Address 2" := "Ship-to Address 2";
                                                       ShipmentDocument."Ship-to Post Code" := "Ship-to Post Code";
                                                       ShipmentDocument."Ship-to City" := "Ship-to City";
                                                       ShipmentDocument."Ship-to County" := "Ship-to County";
                                                       ShipmentDocument."Ship-to Country/Region Code" := "Ship-to Country/Region Code"
                                                     end;

                                                     if PacsoftSetup."Order No. to Reference" then
                                                       if "Order No." <> '' then
                                                         ShipmentDocument.Reference := CopyStr("Order No.", 1,
                                                                                               MaxStrLen(ShipmentDocument.Reference));
                                                   end;
                                               end;
          DATABASE::"Sales Invoice Header" : begin
                                               RecRef.SetTable(SalesInvoiceHeader);
                                               if SalesInvoiceHeader.Find then
                                                 with SalesInvoiceHeader do begin
                                                   Customer.Get("Sell-to Customer No.");
                                                   //-PS1.01
                                                   ShippingAgentServicesCode := "Shipping Agent Service Code";
                                                   //+PS1.01

                                                   Clear(ShipToAddress);
                                                   if not ShipToAddress.Get("Sell-to Customer No.", "Ship-to Code") then begin
                                                   //-NPR5.34 [282595]
                                                   //"Ship-to Code" := "Sell-to Customer No.";
                                                   //+NPR5.34 [282595]
                                                     ShipToAddress."Phone No." := Customer."Phone No.";
                                                     ShipToAddress."Fax No." := Customer."Fax No.";
                                                     ShipToAddress."E-Mail" := Customer."E-Mail";
                                                   end;

                                                   //-NPR5.34 [282595]
                                                   //ShipmentDocument."Receiver ID" := "Ship-to Code";
                                                   ShipmentDocument."Receiver ID":= "Sell-to Customer No.";
                                                   //+NPR5.34 [282595]
                                                   ShipmentDocument.Name := "Ship-to Name";
                                                   ShipmentDocument.Address := "Ship-to Address";
                                                   ShipmentDocument."Address 2" := "Ship-to Address 2";
                                                   ShipmentDocument."Post Code" := "Ship-to Post Code";
                                                   ShipmentDocument.City := "Ship-to City";
                                                   ShipmentDocument.County := "Ship-to County";
                                                   ShipmentDocument."Country/Region Code" := "Ship-to Country/Region Code";
                                                   ShipmentDocument.Contact := "Ship-to Contact";
                                                   ShipmentDocument.Reference := "Your Reference";
                                                   ShipmentDocument."Shipment Date" := "Shipment Date";
                                                   ShipmentDocument."Phone No." := ShipToAddress."Phone No.";
                                                   ShipmentDocument."Fax No." := ShipToAddress."Fax No.";
                                                   ShipmentDocument."VAT Registration No." := Customer."VAT Registration No.";
                                                   ShipmentDocument."E-Mail" := ShipToAddress."E-Mail";
                                                   ShipmentDocument."SMS No." := ShipToAddress."Phone No.";
                                                   ShipmentDocument."Shipping Agent Code" := "Shipping Agent Code";
                                               end;
                                             end;
          DATABASE::"Sales Cr.Memo Header" : begin
                                               RecRef.SetTable(SalesCrMemoHeader);
                                               if SalesCrMemoHeader.Find then
                                                 with SalesCrMemoHeader do begin
                                                   Customer.Get("Sell-to Customer No.");

                                                   Clear(ShipToAddress);
                                                   if not ShipToAddress.Get("Sell-to Customer No.", "Ship-to Code") then begin
                                                     //-NPR5.34 [282595]
                                                     //"Ship-to Code" := "Sell-to Customer No.";
                                                     //+NPR5.34 [282595]
                                                     ShipToAddress."Phone No." := Customer."Phone No.";
                                                     ShipToAddress."Fax No." := Customer."Fax No.";
                                                     ShipToAddress."E-Mail" := Customer."E-Mail";
                                                   end;

                                                   //-NPR5.34 [282595]
                                                   //ShipmentDocument."Receiver ID" := "Ship-to Code";
                                                   ShipmentDocument."Receiver ID":= "Sell-to Customer No.";
                                                   //+NPR5.34 [282595]
                                                   ShipmentDocument.Name := "Ship-to Name";
                                                   ShipmentDocument.Address := "Ship-to Address";
                                                   ShipmentDocument."Address 2" := "Ship-to Address 2";
                                                   ShipmentDocument."Post Code" := "Ship-to Post Code";
                                                   ShipmentDocument.City := "Ship-to City";
                                                   ShipmentDocument.County := "Ship-to County";
                                                   ShipmentDocument."Country/Region Code" := "Ship-to Country/Region Code";
                                                   ShipmentDocument.Contact := "Ship-to Contact";
                                                   ShipmentDocument.Reference := "Your Reference";
                                                   ShipmentDocument."Shipment Date" := "Shipment Date";
                                                   ShipmentDocument."Phone No." := ShipToAddress."Phone No.";
                                                   ShipmentDocument."Fax No." := ShipToAddress."Fax No.";
                                                   ShipmentDocument."VAT Registration No." := Customer."VAT Registration No.";
                                                   ShipmentDocument."E-Mail" := ShipToAddress."E-Mail";
                                                   ShipmentDocument."SMS No." := ShipToAddress."Phone No.";
                                                   ShipmentDocument."Shipping Agent Code" := "Shipping Agent Code";
                                               end;
                                             end;
          DATABASE::"Purch. Rcpt. Header" : begin
                                              RecRef.SetTable(PurchRcptHeader);
                                              if PurchRcptHeader.Find then begin
                                                                           end;
                                            end;
          DATABASE::"Purch. Inv. Header" : begin
                                               RecRef.SetTable(PurchInvHeader);
                                               if PurchInvHeader.Find then begin
                                                                           end;
                                             end;
          DATABASE::"Purch. Cr. Memo Hdr." : begin
                                               RecRef.SetTable(PurchCrMemoHeader);
                                               if PurchCrMemoHeader.Find then begin
                                                                              end;
                                             end;
          DATABASE::Job : begin
                            RecRef.SetTable(Job);
                            if Job.Find then
                              with Job do begin
                                ShipmentDocument."Receiver ID" := "Bill-to Customer No.";
                                ShipmentDocument.Name := "Bill-to Name";
                                ShipmentDocument.Address := "Bill-to Address";
                                ShipmentDocument."Address 2" := "Address 2";
                                ShipmentDocument."Post Code" := "Bill-to Post Code";
                                ShipmentDocument.City := "Bill-to City";
                                ShipmentDocument.County := '';
                                ShipmentDocument."Country/Region Code" := "Bill-to Country/Region Code";
                                ShipmentDocument.Contact := "Bill-to Contact";
                                ShipmentDocument.Reference := '';
                                ShipmentDocument."Shipment Date" := Today;
                                Customer.Get("Bill-to Customer No.");
                                ShipmentDocument."Phone No." := Customer."Phone No.";
                                ShipmentDocument."Fax No." := Customer."Fax No.";
                                ShipmentDocument."VAT Registration No." := Customer."VAT Registration No.";
                                ShipmentDocument."E-Mail" := Customer."E-Mail";
                                ShipmentDocument."SMS No." := Customer."Phone No.";
                                ShipmentDocument."Shipping Agent Code" := Customer."Shipping Agent Code";
                              end;
                          end;
          DATABASE::Contact : begin
                                RecRef.SetTable(Contact);
                                if Contact.Find then
                                  with Contact do begin
                                     ShipmentDocument."Receiver ID" := "No.";
                                     ShipmentDocument.Name := "Company Name";
                                     ShipmentDocument.Address := Address;
                                     ShipmentDocument."Address 2" := "Address 2";
                                     ShipmentDocument."Post Code" := "Post Code";
                                     ShipmentDocument.City := City;
                                     ShipmentDocument.County := County;
                                     ShipmentDocument."Country/Region Code" := "Country/Region Code";
                                     if Contact.Type = Contact.Type::Person then
                                       ShipmentDocument.Contact := Name;
                                     ShipmentDocument.Reference := '';
                                     ShipmentDocument."Shipment Date" := Today;
                                     ShipmentDocument."Phone No." := "Phone No.";
                                     ShipmentDocument."Fax No." := "Fax No.";
                                     ShipmentDocument."VAT Registration No." := "VAT Registration No.";
                                     ShipmentDocument."E-Mail" := "E-Mail";
                                     ShipmentDocument."SMS No." := "Mobile Phone No.";
                                     ShipmentDocument."Shipping Agent Code" := "Shipping Agent Code";
                                  end;
                              end;
        end;

        CompanyInfo.Get;
        ShipmentDocument."Sender VAT Reg. No" := CompanyInfo."VAT Registration No.";
        if ShipmentDocument."Country/Region Code" = '' then
          ShipmentDocument."Country/Region Code" := CompanyInfo."Country/Region Code";
        if ShipmentDocument."Shipment Date" < Today then
          ShipmentDocument."Shipment Date" := Today;

        ShipmentDocument.Modify(true);

        if ShipmentDocument."Shipping Agent Code" <> '' then begin
          Clear(ShippingAgentServices);
          ShippingAgentServices.SetCurrentKey("Shipping Agent Code");
          ShippingAgentServices.SetRange("Shipping Agent Code", ShipmentDocument."Shipping Agent Code");
          ShippingAgentServices.SetRange("Default Option", true);
          if ShippingAgentServices.FindSet then begin
            repeat
              Clear(ShipmentDocServices);
              ShipmentDocServices.Validate("Entry No.", ShipmentDocument."Entry No.");
              ShipmentDocServices.Validate("Shipping Agent Code", ShippingAgentServices."Shipping Agent Code");
              ShipmentDocServices.Validate("Shipping Agent Service Code", ShippingAgentServices.Code);
              ShipmentDocServices.Insert(true);
            until ShippingAgentServices.Next = 0;
          //-PS1.01
          end
          else begin
            if (ShippingAgentServicesCode <> '' ) and (PacsoftSetup."Create Shipping Services Line")  then begin
              Clear(ShippingAgentServices);
              ShippingAgentServices.SetCurrentKey("Shipping Agent Code");
              ShippingAgentServices.SetRange("Shipping Agent Code", ShipmentDocument."Shipping Agent Code");
              ShippingAgentServices.SetRange(Code,ShippingAgentServicesCode);
              ShippingAgentServices.SetRange("Default Option", false);
              if ShippingAgentServices.FindSet then
                repeat
                  Clear(ShipmentDocServices);
                  ShipmentDocServices.Validate("Entry No.", ShipmentDocument."Entry No.");
                  ShipmentDocServices.Validate("Shipping Agent Code", ShippingAgentServices."Shipping Agent Code");
                  ShipmentDocServices.Validate("Shipping Agent Service Code", ShippingAgentServices.Code);
                  ShipmentDocServices.Insert(true);
                until ShippingAgentServices.Next = 0;
            end;
          end;
          //+PS1.01
        end;

        if ShipmentDocument."Delivery Location" <> '' then
          if ShippingAgentServices.Get(ShipmentDocument."Shipping Agent Code", 'PUPOPT') then begin
            //-228449
            if not ShipmentDocServices.Get(ShipmentDocument."Entry No.", ShippingAgentServices."Shipping Agent Code", ShippingAgentServices.Code) then begin //-228449
            //+228449
              Clear(ShipmentDocServices);
              ShipmentDocServices.Validate("Entry No.", ShipmentDocument."Entry No.");
              ShipmentDocServices.Validate("Shipping Agent Code", ShippingAgentServices."Shipping Agent Code");
              ShipmentDocServices.Validate("Shipping Agent Service Code", ShippingAgentServices.Code);
              ShipmentDocServices.Insert(true);
            //-228449
            end;
            //+228449
          end;

        if ShowWindow then begin
          Commit;
          ShipmentDocument.SetRecFilter;
          Clear(CreateShipmentDocument);
          CreateShipmentDocument.LookupMode(false);
          CreateShipmentDocument.SetRecord(ShipmentDocument);
          CreateShipmentDocument.RunModal;
          if CreateShipmentDocument.OKButtonWasPressed then begin
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

    procedure DeleteShippingAgentServices(pShipmentDocument: Record "Pacsoft Shipment Document";WithDialog: Boolean)
    var
        ShipmentDocServices: Record "Pacsoft Shipment Doc. Services";
        TextConfirm: Label 'The chosen Shipping Agent Services will be deleted. Continue ?';
    begin
        if WithDialog then begin
          Clear(ShipmentDocServices);
          ShipmentDocServices.SetCurrentKey("Entry No.", "Shipping Agent Code", "Shipping Agent Service Code");
          ShipmentDocServices.SetRange("Entry No.", pShipmentDocument."Entry No.");
          if not ShipmentDocServices.FindFirst then
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

    procedure ShowTrackAndTrace(pShipmentDocument: Record "Pacsoft Shipment Document")
    var
        ShippingAgent: Record "Shipping Agent";
        TrackingInternetAddr: Text[250];
        PacsoftSetup: Record "Pacsoft Setup";
    begin

        if pShipmentDocument."Entry No." = 0 then exit;

        PacsoftSetup.Get;

        with pShipmentDocument do begin
          TestField("Shipping Agent Code");
          ShippingAgent.Get("Shipping Agent Code");
          ShippingAgent.TestField("Internet Address");
          //-NPR5.51 [361583]
          if pShipmentDocument."Response Package No." <> '' then
            TrackingInternetAddr := StrSubstNo(ShippingAgent."Internet Address",pShipmentDocument."Response Package No.")
          else
          //+NPR5.51 [361583]
          TrackingInternetAddr := StrSubstNo(ShippingAgent."Internet Address", PacsoftSetup.User, "Entry No.");
          HyperLink(TrackingInternetAddr);
        end;
    end;
}

