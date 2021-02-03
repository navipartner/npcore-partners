table 6151570 "NPR AF Setup"
{
    Caption = 'AF Setup';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR AF Setup";
    LookupPageID = "NPR AF Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
        }
        field(10; "Enable Azure Functions"; Boolean)
        {
            Caption = 'Enable Azure Functions';
            DataClassification = CustomerContent;
        }
        field(11; "Customer Tag"; Text[50])
        {
            Caption = 'Customer Tag';
            DataClassification = CustomerContent;
        }
        field(12; "Web Service Is Published"; Boolean)
        {
            CalcFormula = Exist("Web Service" WHERE("Object Type" = CONST(Codeunit),
                                                     "Service Name" = CONST('azurefunction_service')));
            Caption = 'Web Service Is Published';
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; "Web Service Url"; Text[250])
        {
            Caption = 'Web Service Url';
            DataClassification = CustomerContent;
        }
        field(100; "Spire Barcode - API Key"; Text[100])
        {
            Caption = 'Spire Barcode - API Key';
            DataClassification = CustomerContent;
        }
        field(101; "Spire Barcode - Base Url"; Text[100])
        {
            Caption = 'Spire Barcode - Base Url';
            DataClassification = CustomerContent;
        }
        field(102; "Spire Barcode - API Routing"; Text[100])
        {
            Caption = 'Spire Barcode - API Routing';
            DataClassification = CustomerContent;
        }
        field(200; "Notification - API Key"; Text[100])
        {
            Caption = 'Notification - API Key';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'This Field won''t be used anymore';
            ObsoleteTag = 'NPR AF Setup cleanup';
        }
        field(201; "Notification - Base Url"; Text[100])
        {
            Caption = 'Notification - Base Url';
            DataClassification = CustomerContent;
        }
        field(202; "Notification - API Routing"; Text[100])
        {
            Caption = 'Notification - API Routing';
            DataClassification = CustomerContent;
        }
        field(203; "Notification - Conn. String"; Text[250])
        {
            Caption = 'Notification - Conn. String';
            DataClassification = CustomerContent;
            InitValue = 'No';
        }
        field(204; "Notification - Hub Path"; Text[100])
        {
            Caption = 'Notification - Hub Path';
            DataClassification = CustomerContent;
            InitValue = '15';
        }
        field(300; "Msg Service - API Key"; Text[100])
        {
            Caption = 'Msg Service - API Key';
            DataClassification = CustomerContent;
        }
        field(301; "Msg Service - Base Url"; Text[100])
        {
            Caption = 'Msg Service - Base Url';
            DataClassification = CustomerContent;
        }
        field(302; "Msg Service - API Routing"; Text[100])
        {
            Caption = 'Msg Service - API Routing';
            DataClassification = CustomerContent;
        }
        field(303; "Msg Service - Name"; Text[30])
        {
            Caption = 'Msg Service - Name';
            DataClassification = CustomerContent;
        }
        field(304; "Msg Service - Description"; Text[100])
        {
            Caption = 'Msg Service - Description';
            DataClassification = CustomerContent;
        }
        field(305; "Msg Service - Title"; Text[30])
        {
            Caption = 'Msg Service - Title';
            DataClassification = CustomerContent;
        }
        field(306; "Msg Service - Image"; BLOB)
        {
            Caption = 'Msg Service - Image';
            DataClassification = CustomerContent;
            SubType = Bitmap;
        }
        field(307; "Msg Service - Icon"; BLOB)
        {
            Caption = 'Msg Service - Icon';
            DataClassification = CustomerContent;
            SubType = Bitmap;
        }
        field(308; "Msg Service - Base Web Url"; Text[250])
        {
            Caption = 'Msg Service - Base Web Url';
            DataClassification = CustomerContent;
        }
        field(309; "Msg Service - Site Created"; Boolean)
        {
            Caption = 'Msg Service - Site Created';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(310; "Msg Service - Report ID"; Integer)
        {
            Caption = 'Msg Service - Report ID';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Report));

            trigger OnValidate()
            begin
                CalcFields("Msg Service - Report Caption");
            end;
        }
        field(311; "Msg Service - Report Caption"; Text[249])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Report),
                                                                           "Object ID" = FIELD("Msg Service - Report ID")));
            Caption = 'Msg Service - Report Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(314; "Msg Service - Source Type"; Option)
        {
            Caption = 'Msg Service - Source Type';
            DataClassification = CustomerContent;
            OptionCaption = 'NAV,Magento';
            OptionMembers = NAV,Magento;
        }
        field(315; "Msg Service - Encryption Key"; Text[30])
        {
            Caption = 'Msg Service - Encryption Key';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(316; "Msg Service - NAV WS User"; Text[30])
        {
            Caption = 'Msg Service - NAV WS User';
            DataClassification = CustomerContent;
        }
        field(317; "Msg Service - NAV WS Password"; Text[30])
        {
            Caption = 'Msg Service - NAV WS Password';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(400; "OIO Validation - API Key"; Text[100])
        {
            Caption = 'OIO Validation - API Key';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'This Field won''t be used anymore';
            ObsoleteTag = 'NPR AF Setup cleanup';
        }
        field(401; "OIO Validation - Base Url"; Text[100])
        {
            Caption = 'OIO Validation - Base Url';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'This Field won''t be used anymore';
            ObsoleteTag = 'NPR AF Setup cleanup';
        }
        field(402; "OIO Validation - API Routing"; Text[100])
        {
            Caption = 'OIO Validation - API Routing';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'This Field won''t be used anymore';
            ObsoleteTag = 'NPR AF Setup cleanup';
        }
        field(403; "OIO Validation - Enable"; Boolean)
        {
            Caption = 'OIO Validation - Enable';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'This Field won''t be used anymore';
            ObsoleteTag = 'NPR AF Setup cleanup';
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Customer Tag" := ConvertStr(Format(CreateGuid), '{}-', '000');
    end;

    trigger OnModify()
    begin
        if "Customer Tag" = '' then
            "Customer Tag" := ConvertStr(Format(CreateGuid), '{}-', '000');

        if "Msg Service - Site Created" then
            if (xRec."Msg Service - Name" <> "Msg Service - Name") then
                Error(SITENAMEERROR);
    end;

    var
        SITENAMEERROR: Label 'Is not possible to change site name';
}

