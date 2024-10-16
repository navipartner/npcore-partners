table 6059884 "NPR Pacsoft Shipment Document"
{
    Access = Internal;
    Caption = 'Pacsoft Shipment Document';
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
        field(10; "RecordID"; RecordId)
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
        field(102; "User ID"; Text[100])
        {
            TableRelation = User."User Security ID";
            Caption = 'User ID';
            DataClassification = CustomerContent;
        }

        field(7; "User Name"; Text[100])
        {
            Caption = 'User Name';
            FieldClass = FlowField;
            CalcFormula = lookup(User."User Name" where("User Security ID" = field("User ID")));

        }

        field(103; "Location Code"; Code[20])
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
        field(700; "Delivery Location"; Code[50])
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
        field(800; "Request XML"; Blob)
        {
            Caption = 'Document Source';
            DataClassification = CustomerContent;
        }
        field(801; "Request XML Name"; Text[50])
        {
            Caption = 'Document Name';
            DataClassification = CustomerContent;
        }
        field(802; "Response XML"; Blob)
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




}

