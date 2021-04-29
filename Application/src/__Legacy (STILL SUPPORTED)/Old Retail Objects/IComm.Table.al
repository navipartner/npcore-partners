table 6014510 "NPR I-Comm"
{
    Caption = 'I-Comm';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "SMS-Address Postfix"; Text[30])
        {
            Caption = 'SMS-Address Postfix';
            DataClassification = CustomerContent;
        }
        field(2; "Local E-Mail Address"; Text[40])
        {
            Caption = 'Local E-Mail Adress';
            DataClassification = CustomerContent;
        }
        field(3; "Local SMTP Pickup Library"; Text[100])
        {
            Caption = 'Local SMTP ''Pickup'' library';
            DataClassification = CustomerContent;
        }
        field(5; "Tailor Message"; Text[100])
        {
            Caption = 'Tailor Message';
            DataClassification = CustomerContent;
        }
        field(6; "Rental Message"; Text[100])
        {
            Caption = 'Rental Message';
            DataClassification = CustomerContent;
        }
        field(8; "Reg. Turnover Mobile No."; Code[20])
        {
            Caption = 'Cash Reg. Turnover Mobile No.';
            DataClassification = CustomerContent;
        }
        field(14; "Register Turnover Mobile 2"; Code[20])
        {
            Caption = 'Cash Register Turnover Mobile 2';
            DataClassification = CustomerContent;
        }
        field(15; "Register Turnover Mobile 3"; Code[20])
        {
            Caption = 'Cash Register Turnover Mobile 3';
            DataClassification = CustomerContent;
        }
        field(25; "Use Auto. Cust. Lookup"; Boolean)
        {
            Caption = 'Enable Number Info Lookup';
            Description = 'Brug TDC? f.eks.';
            DataClassification = CustomerContent;
        }
        field(32; "NAS - Enabled"; Boolean)
        {
            Caption = 'NAS - Enabled';
            DataClassification = CustomerContent;
        }
        field(36; "NAS - Administrator CRM"; Code[20])
        {
            Caption = 'NAS - Administrator CRM';
            TableRelation = Contact;
            DataClassification = CustomerContent;
        }
        field(50; "Company - Clearing"; Text[30])
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Table will be obsolete - moved to SMS Setup';
            Caption = 'Company';
            Description = 'regnskab til clearing af gavekort og tilgodebeviser';
            TableRelation = Company;
            DataClassification = CustomerContent;
        }
        field(53; "VirtualPDF Name"; Text[50])
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Table will be obsolete - moved to SMS Setup';
            Caption = 'VirtualPDF Name';
            DataClassification = CustomerContent;
        }
        field(56; "SMS Type"; Option)
        {
            Caption = 'Sms type';
            Description = 'NAS1.1o: om der sendes ved hjælp af mail(turbosms), dll(smsdriver) eller http(Eclub)';
            OptionCaption = 'Mail,Dll,Eclub,Endpoint';
            OptionMembers = Mail,Dll,Eclub,Endpoint;
            DataClassification = CustomerContent;
        }
        field(57; "SMS Endpoint"; Code[20])
        {
            Caption = 'SMS Endpoint';
            TableRelation = "NPR Nc Endpoint";
            DataClassification = CustomerContent;
        }
        field(60; "Turnover - Email Addresses"; Text[50])
        {
            Caption = 'Turnover - Email Addresses';
            DataClassification = CustomerContent;
        }
        field(61; "Tunnel URL Address"; Text[100])
        {
            Caption = 'Tunnel URL Address';
            Description = 'Adressen til tdc på nettet';
            DataClassification = CustomerContent;
        }
        field(62; "Clearing - SQL"; Boolean)
        {
            Caption = 'Clearing through SQL';
            DataClassification = CustomerContent;
        }
        field(90; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
        }
        field(91; "E-Club Sender"; Text[12])
        {
            Caption = 'E-Club Sender';
            DataClassification = CustomerContent;
        }
        field(124; "Interaction Template Code"; Code[10])
        {
            Caption = 'Interaction Template Code';
            DataClassification = CustomerContent;
        }
        field(160; "Exchange Label Center Company"; Text[30])
        {
            Caption = 'Exchange Label Center Company';
            DataClassification = CustomerContent;
        }
        field(170; "Number Info Codeunit ID"; Integer)
        {
            Caption = 'Number Info Codeunit ID';
            Description = 'NPR5.23';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = FILTER(Codeunit));
            DataClassification = CustomerContent;
        }
        field(171; "Number Info Codeunit Name"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Codeunit),
                                                                           "Object ID" = FIELD("Number Info Codeunit ID")));
            Caption = 'Number Info Codeunit Name';
            Description = 'NPR5.23';
            FieldClass = FlowField;
        }
        field(172; "Config Request (Customer)"; Option)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Table will be obsolete - moved to SMS Setup';
            Caption = 'Config Request (Customer)';
            Description = '226819';
            OptionCaption = 'Always,Ask,None';
            OptionMembers = Always,Ask,"None";
            DataClassification = CustomerContent;
        }
        field(173; "Config Request (Vendor)"; Option)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Table will be obsolete - moved to SMS Setup';
            Caption = 'Config Request (Vendor)';
            Description = '226819';
            OptionCaption = 'Always,Ask,None';
            OptionMembers = Always,Ask,"None";
            DataClassification = CustomerContent;
        }
        field(174; "Config Request (Contact)"; Option)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Table will be obsolete - moved to SMS Setup';
            Caption = 'Config Request (Contact)';
            Description = '226819';
            OptionCaption = 'Always,Ask,None';
            OptionMembers = Always,Ask,"None";
            DataClassification = CustomerContent;
        }
        field(175; "Config. Template (Customer)"; Code[10])
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Table will be obsolete - moved to SMS Setup';
            Caption = 'Config. Template (Customer)';
            Description = '226819';
            TableRelation = "Config. Template Header".Code WHERE("Table ID" = CONST(18));
            DataClassification = CustomerContent;
        }
        field(176; "Config. Template (Vendor)"; Code[10])
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Table will be obsolete - moved to SMS Setup';
            Caption = 'Config. Template (Vendor)';
            Description = '226819';
            TableRelation = "Config. Template Header".Code WHERE("Table ID" = CONST(23));
            DataClassification = CustomerContent;
        }
        field(177; "Config. Template (Contact)"; Code[10])
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Table will be obsolete - moved to SMS Setup';
            Caption = 'Config. Template (Contact)';
            Description = '226819';
            TableRelation = "Config. Template Header".Code WHERE("Table ID" = CONST(5050));
            DataClassification = CustomerContent;
        }
        field(200; "SMS Provider"; Option)
        {
            Caption = 'SMS Provider';
            OptionCaption = ' ,NaviPartner,,,,,,,,,Custom';
            OptionMembers = " ",NaviPartner,,,,,,,,,Custom;
            DataClassification = CustomerContent;
        }
        field(1000000; "Key"; Code[10])
        {
            Caption = 'Key';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Key")
        {
        }
    }
}