﻿table 6060111 "NPR TM Ticket Setup"
{
    Access = Internal;
    Caption = 'Ticket Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(70; "Store Code"; Code[32])
        {
            Caption = 'Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Store";
        }
        field(75; "Ticket Title"; Option)
        {
            Caption = 'Ticket Title';
            DataClassification = CustomerContent;
            OptionCaption = 'Item Description,Admission Description,Ticket Type Description,Ticket BOM Description,Webshop Short Description,Webshop Description,Variant Description,Blank,Webshop Name';
            OptionMembers = ITEM_DESC,ADM_DESC,TYPE_DESC,BOM_DESC,WEBSHOP_SHORT,WEBSHOP_FULL,VARIANT_DESC,BLANK,WEBSHOP_NAME;
        }
        field(76; "Ticket Name"; Option)
        {
            Caption = 'Ticket Name';
            DataClassification = CustomerContent;
            OptionCaption = 'Item Description,Admission Description,Ticket Type Description,Ticket BOM Description,Webshop Short Description,Webshop Description,Variant Description,Blank,Webshop Name';
            OptionMembers = ITEM_DESC,ADM_DESC,TYPE_DESC,BOM_DESC,WEBSHOP_SHORT,WEBSHOP_FULL,VARIANT_DESC,BLANK,WEBSHOP_NAME;
        }
        field(77; "Ticket Description"; Option)
        {
            Caption = 'Ticket Description';
            DataClassification = CustomerContent;
            OptionCaption = 'Item Description,Admission Description,Ticket Type Description,Ticket BOM Description,Webshop Short Description,Webshop Description,Variant Description,Blank,Webshop Name';
            OptionMembers = ITEM_DESC,ADM_DESC,TYPE_DESC,BOM_DESC,WEBSHOP_SHORT,WEBSHOP_FULL,VARIANT_DESC,BLANK,WEBSHOP_NAME;
        }
        field(78; "Ticket Full Description"; Option)
        {
            Caption = 'Ticket Full Description';
            DataClassification = CustomerContent;
            OptionCaption = 'Item Description,Admission Description,Ticket Type Description,Ticket BOM Description,Webshop Short Description,Webshop Description,Variant Description,Blank,Webshop Name';
            OptionMembers = ITEM_DESC,ADM_DESC,TYPE_DESC,BOM_DESC,WEBSHOP_SHORT,WEBSHOP_FULL,VARIANT_DESC,BLANK,WEBSHOP_NAME;
        }
        field(79; "Ticket Sub Title"; Option)
        {
            Caption = 'Ticket Sub Title';
            DataClassification = CustomerContent;
            OptionCaption = 'Item Description,Admission Description,Ticket Type Description,Ticket BOM Description,Webshop Short Description,Webshop Description,Variant Description,Blank,Webshop Name';
            OptionMembers = ITEM_DESC,ADM_DESC,TYPE_DESC,BOM_DESC,WEBSHOP_SHORT,WEBSHOP_FULL,VARIANT_DESC,BLANK,WEBSHOP_NAME;
        }

        field(80; "Authorization Code Scheme"; Code[20])
        {
            Caption = 'Authorization Code Scheme';
            DataClassification = CustomerContent;
        }

        field(85; "Retire Used Tickets After"; DateFormula)
        {
            Caption = 'Retire Tickets After';
            DataClassification = CustomerContent;
            InitValue = '<2Y>';
        }
        Field(86; "Duration Retire Tickets (Min.)"; Integer)
        {
            Caption = 'Duration Retire Tickets (Min.)';
            DataClassification = CustomerContent;
            InitValue = 50;
        }
        field(100; "Print Server Generator URL"; Text[200])
        {
            Caption = 'Print Server Generator URL';
            DataClassification = CustomerContent;
        }
        field(105; "Timeout (ms)"; Integer)
        {
            Caption = 'Timeout (ms)';
            DataClassification = CustomerContent;
            InitValue = 30000;
        }
        field(110; "Print Server Gen. Username"; Text[30])
        {
            Caption = 'Print Server Gen. Username';
            DataClassification = CustomerContent;
        }
        field(111; "Print Server Gen. Password"; Text[50])
        {
            Caption = 'Print Server Gen. Password';
            DataClassification = CustomerContent;
        }
        field(120; "Print Server Ticket URL"; Text[200])
        {
            Caption = 'Print Server Ticket URL';
            DataClassification = CustomerContent;
        }
        field(121; "Print Server Order URL"; Text[200])
        {
            Caption = 'Print Server Order URL';
            DataClassification = CustomerContent;
        }
        field(125; "Default Ticket Language"; Text[30])
        {
            Caption = 'Default Ticket Language';
            DataClassification = CustomerContent;
        }
        field(130; "Prepaid Excel Export Prompt"; Option)
        {
            Caption = 'Prepaid Excel Export Prompt';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Show,Hide';
            OptionMembers = DEFAULT,SHOW,HIDE;
        }
        field(131; "Prepaid Offline Valid. Prompt"; Option)
        {
            Caption = 'Prepaid Offline Valid. Prompt';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Show,Hide';
            OptionMembers = DEFAUL,SHOW,HIDE;
        }
        field(132; "Prepaid Ticket Result List"; Option)
        {
            Caption = 'Prepaid Ticket Result List';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Show,Hide';
            OptionMembers = DEFAULT,SHOW,HIDE;
        }
        field(133; "Prepaid Default Quantity"; Integer)
        {
            Caption = 'Prepaid Default Quantity';
            DataClassification = CustomerContent;
        }
        field(134; "Prepaid Ticket Server Export"; Option)
        {
            Caption = 'Prepaid Ticket Server Export';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Yes,No';
            OptionMembers = DEFAULT,YES,NO;
        }
        field(137; "Postpaid Excel Export Prompt"; Option)
        {
            Caption = 'Postpaid Excel Export Prompt';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Show,Hide';
            OptionMembers = DEFAULT,SHOW,HIDE;
        }
        field(138; "Postpaid Ticket Result List"; Option)
        {
            Caption = 'Postpaid Ticket Result List';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Show,Hide';
            OptionMembers = DEFAULT,SHOW,HIDE;
        }
        field(139; "Postpaid Default Quantity"; Integer)
        {
            Caption = 'Postpaid Default Quantity';
            DataClassification = CustomerContent;
        }
        field(140; "Postpaid Ticket Server Export"; Option)
        {
            Caption = 'Postpaid Ticket Server Export';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Yes,No';
            OptionMembers = DEFAULT,YES,NO;
        }
        field(200; "NP-Pass Server Base URL"; Text[200])
        {
            Caption = 'NP-Pass Server Base URL';
            DataClassification = CustomerContent;
            Description = '//-TM1.38 [332109]';
            InitValue = 'https://passes.npecommerce.dk/api/v1';
        }
        field(210; "NP-Pass Notification Method"; Option)
        {
            Caption = 'NP-Pass Notification Method';
            DataClassification = CustomerContent;
            Description = '//-TM1.38 [332109]';
            OptionCaption = 'Asynchronous,Synchronous';
            OptionMembers = ASYNCHRONOUS,SYNCHRONOUS;
        }
        field(220; "NP-Pass API"; Text[50])
        {
            Caption = 'NP-Pass API';
            DataClassification = CustomerContent;
            Description = '//-TM1.38 [332109]';
            InitValue = '/passes/%1/%2';
        }
        field(230; "Show Send Fail Message In POS"; Boolean)
        {
            Caption = 'Show Send Fail Message In POS';
            DataClassification = CustomerContent;
        }
        field(231; "Show Message Body (Debug)"; Boolean)
        {
            Caption = 'Show Message Body (Debug)';
            DataClassification = CustomerContent;
        }
        field(235; "Suppress Print When eTicket"; Boolean)
        {
            Caption = 'Suppress Print When eTicket';
            DataClassification = CustomerContent;
        }
        field(240; "NP-Pass Token"; Text[150])
        {
            Caption = 'NP-Pass Token';
            DataClassification = CustomerContent;
            Description = '//-TM1.38 [332109]';
        }
        field(300; "Wizard Ticket Type No. Series"; Code[20])
        {
            Caption = 'Wizard Ticket Type No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(301; "Wizard Ticket Type Template"; Code[10])
        {
            Caption = 'Wizard Ticket Type Template';
            DataClassification = CustomerContent;
            TableRelation = "Config. Template Header";
        }
        field(306; "Wizard Ticket Bom Template"; Code[10])
        {
            Caption = 'Wizard Ticket Bom Template';
            DataClassification = CustomerContent;
            TableRelation = "Config. Template Header";
        }
        field(310; "Wizard Adm. Code No. Series"; Code[20])
        {
            Caption = 'Wizard Adm. Code No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(311; "Wizard Admission Template"; Code[10])
        {
            Caption = 'Wizard Admission Template';
            DataClassification = CustomerContent;
            TableRelation = "Config. Template Header";
        }
        field(315; "Wizard Sch. Code No. Series"; Code[20])
        {
            Caption = 'Wizard Sch. Code No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(320; "Wizard Item No. Series"; Code[20])
        {
            Caption = 'Wizard Item No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(400; "Ticket Admission Web Url"; Text[250])
        {
            Caption = 'Ticket Admission Web Url';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    procedure GetTicketAdmissionWebUrl(Mandatory: Boolean): Text
    begin
        if not Rec.Get() then
            Rec.Init();
        if Mandatory then
            Rec.TestField("Ticket Admission Web Url");
        exit("Ticket Admission Web Url");
    end;
}