table 6151570 "AF Setup"
{
    // NPR5.36/CLVA/20170710 CASE 269792 AF Setup
    // NPR5.38/CLVA/20171024 CASE 289636 Added Messages Service fields
    // NPR5.38/CLVA/20180123 CASE 279861 Added OIO validation fields
    // NPR5.40/THRO/20180315 CASE 307195 Added LookUpPageID and DrillDownPageID
    // NPR5.43/CLVA/20180529 CASE 279861 Added field OIO Validation - Enable
    // NPR5.48/JDH /20181109 CASE 334163 Added caption to field OIO Validation - Enable

    Caption = 'AF Setup';
    DrillDownPageID = "AF Setup";
    LookupPageID = "AF Setup";

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Id';
        }
        field(10;"Enable Azure Functions";Boolean)
        {
            Caption = 'Enable Azure Functions';
        }
        field(11;"Customer Tag";Text[50])
        {
            Caption = 'Customer Tag';
        }
        field(12;"Web Service Is Published";Boolean)
        {
            CalcFormula = Exist("Web Service" WHERE ("Object Type"=CONST(Codeunit),
                                                     "Service Name"=CONST('azurefunction_service')));
            Caption = 'Web Service Is Published';
            Editable = false;
            FieldClass = FlowField;
        }
        field(13;"Web Service Url";Text[250])
        {
            Caption = 'Web Service Url';
        }
        field(100;"Spire Barcode - API Key";Text[100])
        {
            Caption = 'Spire Barcode - API Key';
        }
        field(101;"Spire Barcode - Base Url";Text[100])
        {
            Caption = 'Spire Barcode - Base Url';
        }
        field(102;"Spire Barcode - API Routing";Text[100])
        {
            Caption = 'Spire Barcode - API Routing';
        }
        field(200;"Notification - API Key";Text[100])
        {
            Caption = 'Notification - API Key';
        }
        field(201;"Notification - Base Url";Text[100])
        {
            Caption = 'Notification - Base Url';
        }
        field(202;"Notification - API Routing";Text[100])
        {
            Caption = 'Notification - API Routing';
        }
        field(203;"Notification - Conn. String";Text[250])
        {
            Caption = 'Notification - Conn. String';
            InitValue = 'No';
        }
        field(204;"Notification - Hub Path";Text[100])
        {
            Caption = 'Notification - Hub Path';
            InitValue = '15';
        }
        field(300;"Msg Service - API Key";Text[100])
        {
            Caption = 'Msg Service - API Key';
        }
        field(301;"Msg Service - Base Url";Text[100])
        {
            Caption = 'Msg Service - Base Url';
        }
        field(302;"Msg Service - API Routing";Text[100])
        {
            Caption = 'Msg Service - API Routing';
        }
        field(303;"Msg Service - Name";Text[30])
        {
            Caption = 'Msg Service - Name';
        }
        field(304;"Msg Service - Description";Text[100])
        {
            Caption = 'Msg Service - Description';
        }
        field(305;"Msg Service - Title";Text[30])
        {
            Caption = 'Msg Service - Title';
        }
        field(306;"Msg Service - Image";BLOB)
        {
            Caption = 'Msg Service - Image';
            SubType = Bitmap;
        }
        field(307;"Msg Service - Icon";BLOB)
        {
            Caption = 'Msg Service - Icon';
            SubType = Bitmap;
        }
        field(308;"Msg Service - Base Web Url";Text[250])
        {
            Caption = 'Msg Service - Base Web Url';
        }
        field(309;"Msg Service - Site Created";Boolean)
        {
            Caption = 'Msg Service - Site Created';
            Editable = false;
        }
        field(310;"Msg Service - Report ID";Integer)
        {
            Caption = 'Msg Service - Report ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Report));

            trigger OnValidate()
            begin
                CalcFields("Msg Service - Report Caption");
            end;
        }
        field(311;"Msg Service - Report Caption";Text[249])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(Report),
                                                                           "Object ID"=FIELD("Msg Service - Report ID")));
            Caption = 'Msg Service - Report Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(314;"Msg Service - Source Type";Option)
        {
            Caption = 'Msg Service - Source Type';
            OptionCaption = 'NAV,Magento';
            OptionMembers = NAV,Magento;
        }
        field(315;"Msg Service - Encryption Key";Text[30])
        {
            Caption = 'Msg Service - Encryption Key';
            ExtendedDatatype = Masked;
        }
        field(316;"Msg Service - NAV WS User";Text[30])
        {
            Caption = 'Msg Service - NAV WS User';
        }
        field(317;"Msg Service - NAV WS Password";Text[30])
        {
            Caption = 'Msg Service - NAV WS Password';
            ExtendedDatatype = Masked;
        }
        field(400;"OIO Validation - API Key";Text[100])
        {
            Caption = 'OIO Validation - API Key';
        }
        field(401;"OIO Validation - Base Url";Text[100])
        {
            Caption = 'OIO Validation - Base Url';
        }
        field(402;"OIO Validation - API Routing";Text[100])
        {
            Caption = 'OIO Validation - API Routing';
        }
        field(403;"OIO Validation - Enable";Boolean)
        {
            Caption = 'OIO Validation - Enable';
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Customer Tag" := ConvertStr(Format(CreateGuid),'{}-','000');
    end;

    trigger OnModify()
    begin
        if "Customer Tag" = '' then
          "Customer Tag" := ConvertStr(Format(CreateGuid),'{}-','000');

        if "Msg Service - Site Created" then
          if (xRec."Msg Service - Name" <> "Msg Service - Name") then
            Error(SITENAMEERROR);
    end;

    var
        SITENAMEERROR: Label 'Is not possible to change site name';
}

