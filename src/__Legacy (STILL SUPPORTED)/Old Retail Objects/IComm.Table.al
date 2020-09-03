table 6014510 "NPR I-Comm"
{
    // //-NPR3.0s
    //   tilf¢jet path to smtpmail.exe, bruges f.eks. ved japanphoto forsikringudlæsning
    // //4.001 - NPE
    //   added field 121
    // 
    // NPR4.16/JDH/20151016 CASE 225285 Removed references to NAS and DBI module
    // NPR4.16/JDH/20151110 CASE 226329 changed fieldname TDC Tunnel Address to Tunnel URL Address
    // NPR5.01/RMT/20160217 CASE 234145 Change field "Retail Journal - Items update" property "SQL Data Type" from Variant to <Undefined>
    //                                  NOTE: Requires data upgrade
    // NPR5.23/BHR/20151204  CASE 222711 Added 2 fields 170 ,171 for Phone number identification
    // NPR5.23/LS  /20160516 CASE 226819 Added fields 172..177
    // NPR5.23/TS/20160613 CASE 244162 Removed fields 47,67,70,71,77,94.
    // NPR5.26/THRO/20160908 CASE 244114 Added field 200 SMS Provider - used in SMS Module to determin which provider to send through
    // NPR5.27/TJ/20160928 CASE 248981 Removing unused variables and fields, renaming fields and variables to use standard naming procedures
    // NPR5.27/LS  /20161027 CASE 251264 Renaming fields 172..174
    // NPR5.30/TJ  /20170202 CASE 264793 Removed unused fields
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.47/TS  /20181022 CASE 307097 Removed field  4,7,11,24,74,75,83,85. Fields names are referenced in case
    // NPR5.51/THRO/20190710 CASE 360944 Added option to send SMS file to Nc Endpoint

    Caption = 'I-Comm';

    fields
    {
        field(1; "SMS-Address Postfix"; Text[30])
        {
            Caption = 'SMS-Address Postfix';
        }
        field(2; "Local E-Mail Address"; Text[40])
        {
            Caption = 'Local E-Mail Adress';
        }
        field(3; "Local SMTP Pickup Library"; Text[100])
        {
            Caption = 'Local SMTP ''Pickup'' library';
        }
        field(5; "Tailor Message"; Text[100])
        {
            Caption = 'Tailor Message';
        }
        field(6; "Rental Message"; Text[100])
        {
            Caption = 'Rental Message';
        }
        field(8; "Reg. Turnover Mobile No."; Code[20])
        {
            Caption = 'Cash Reg. Turnover Mobile No.';
        }
        field(14; "Register Turnover Mobile 2"; Code[20])
        {
            Caption = 'Cash Register Turnover Mobile 2';
        }
        field(15; "Register Turnover Mobile 3"; Code[20])
        {
            Caption = 'Cash Register Turnover Mobile 3';
        }
        field(25; "Use Auto. Cust. Lookup"; Boolean)
        {
            Caption = 'Enable Number Info Lookup';
            Description = 'Brug TDC? f.eks.';
        }
        field(32; "NAS - Enabled"; Boolean)
        {
            Caption = 'NAS - Enabled';
        }
        field(36; "NAS - Administrator CRM"; Code[20])
        {
            Caption = 'NAS - Administrator CRM';
            TableRelation = Contact;
        }
        field(50; "Company - Clearing"; Text[30])
        {
            Caption = 'Company';
            Description = 'regnskab til clearing af gavekort og tilgodebeviser';
            TableRelation = Company;
        }
        field(53; "VirtualPDF Name"; Text[50])
        {
            Caption = 'VirtualPDF Name';
        }
        field(56; "SMS Type"; Option)
        {
            Caption = 'Sms type';
            Description = 'NAS1.1o: om der sendes ved hjælp af mail(turbosms), dll(smsdriver) eller http(Eclub)';
            OptionCaption = 'Mail,Dll,Eclub,Endpoint';
            OptionMembers = Mail,Dll,Eclub,Endpoint;
        }
        field(57; "SMS Endpoint"; Code[20])
        {
            Caption = 'SMS Endpoint';
            TableRelation = "NPR Nc Endpoint";
        }
        field(60; "Turnover - Email Addresses"; Text[50])
        {
            Caption = 'Turnover - Email Addresses';
        }
        field(61; "Tunnel URL Address"; Text[100])
        {
            Caption = 'Tunnel URL Address';
            Description = 'Adressen til tdc på nettet';
        }
        field(62; "Clearing - SQL"; Boolean)
        {
            Caption = 'Clearing through SQL';
        }
        field(90; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
        }
        field(91; "E-Club Sender"; Text[12])
        {
            Caption = 'E-Club Sender';
        }
        field(124; "Interaction Template Code"; Code[10])
        {
            Caption = 'Interaction Template Code';
        }
        field(160; "Exchange Label Center Company"; Text[30])
        {
            Caption = 'Exchange Label Center Company';
        }
        field(170; "Number Info Codeunit ID"; Integer)
        {
            Caption = 'Number Info Codeunit ID';
            Description = 'NPR5.23';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = FILTER(Codeunit));
        }
        field(171; "Number Info Codeunit Name"; Text[50])
        {
            CalcFormula = Lookup (AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Codeunit),
                                                                           "Object ID" = FIELD("Number Info Codeunit ID")));
            Caption = 'Number Info Codeunit Name';
            Description = 'NPR5.23';
            FieldClass = FlowField;
        }
        field(172; "Config Request (Customer)"; Option)
        {
            Caption = 'Config Request (Customer)';
            Description = '226819';
            OptionCaption = 'Always,Ask,None';
            OptionMembers = Always,Ask,"None";
        }
        field(173; "Config Request (Vendor)"; Option)
        {
            Caption = 'Config Request (Vendor)';
            Description = '226819';
            OptionCaption = 'Always,Ask,None';
            OptionMembers = Always,Ask,"None";
        }
        field(174; "Config Request (Contact)"; Option)
        {
            Caption = 'Config Request (Contact)';
            Description = '226819';
            OptionCaption = 'Always,Ask,None';
            OptionMembers = Always,Ask,"None";
        }
        field(175; "Config. Template (Customer)"; Code[10])
        {
            Caption = 'Config. Template (Customer)';
            Description = '226819';
            TableRelation = "Config. Template Header".Code WHERE("Table ID" = CONST(18));
        }
        field(176; "Config. Template (Vendor)"; Code[10])
        {
            Caption = 'Config. Template (Vendor)';
            Description = '226819';
            TableRelation = "Config. Template Header".Code WHERE("Table ID" = CONST(23));
        }
        field(177; "Config. Template (Contact)"; Code[10])
        {
            Caption = 'Config. Template (Contact)';
            Description = '226819';
            TableRelation = "Config. Template Header".Code WHERE("Table ID" = CONST(5050));
        }
        field(200; "SMS Provider"; Option)
        {
            Caption = 'SMS Provider';
            OptionCaption = ' ,NaviPartner,,,,,,,,,Custom';
            OptionMembers = " ",NaviPartner,,,,,,,,,Custom;
        }
        field(1000000; "Key"; Code[10])
        {
            Caption = 'Key';
        }
    }

    keys
    {
        key(Key1; "Key")
        {
        }
    }

    fieldgroups
    {
    }
}

