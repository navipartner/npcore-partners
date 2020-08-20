table 6151013 "NpRv Voucher"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.48/MHA /20180921  CASE 302179 Added fields 85 "In-use Quantity (External)", 1007 "Issue Document Type", 1013 "Issue External Document No."
    // NPR5.48/MHA /20190123  CASE 341711 Added field 90 "E-mail Template Code", 95 "SMS Template Code", 103 "Send via Print", 105 "Send via E-mail", 107 "Send via SMS"
    // NPR5.48/MHA /20190213  CASE 345739 No. Series length has been increased from 10 to 20 in NAV2018 and newer
    // NPR5.49/MHA /20190228  CASE 342811 Added partner fields
    // NPR5.50/MHA /20190426  CASE 353079 Added field 62 "Allow Top-up"
    // NPR5.53/MHA /20191122  CASE 378597 Fixed mapping of Name 2 in UpdateContactInfo()
    // NPR5.53/MHA /20191211  CASE 380284 Added field 76 "Initial Amount"
    // NPR5.55/MHA /20200427  CASE 402015 Removed field 85 "In-use Quantity (External)"
    // NPR5.55/MHA /20200701  CASE 397527 Added field 270 "Language Code"
    // NPR5.55/MHA /20200702  CASE 407070 Added field 1030 "No. Send"

    Caption = 'Retail Voucher';
    DataClassification = CustomerContent;
    DrillDownPageID = "NpRv Vouchers";
    LookupPageID = "NpRv Vouchers";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(5; "Voucher Type"; Code[20])
        {
            Caption = 'Voucher Type';
            DataClassification = CustomerContent;
            TableRelation = "NpRv Voucher Type";

            trigger OnValidate()
            var
                VoucherType: Record "NpRv Voucher Type";
            begin
                VoucherType.Get("Voucher Type");
                Description := VoucherType.Description;
                if "Starting Date" = 0DT then
                    "Starting Date" := CreateDateTime(Today, 0T);
                if Format(VoucherType."Valid Period") <> '' then
                    "Ending Date" := CreateDateTime(CalcDate(VoucherType."Valid Period", DT2Date("Starting Date")), DT2Time("Starting Date"));

                "No. Series" := VoucherType."No. Series";
                "Arch. No. Series" := VoucherType."Arch. No. Series";
                "Print Template Code" := VoucherType."Print Template Code";
                //-NPR5.48 [341711]
                "E-mail Template Code" := VoucherType."E-mail Template Code";
                "SMS Template Code" := VoucherType."SMS Template Code";
                //+NPR5.48 [341711]
                "Account No." := VoucherType."Account No.";
                "Voucher Message" := VoucherType."Voucher Message";
                //-NPR5.50 [353079]
                "Allow Top-up" := VoucherType."Allow Top-up";
                //+NPR5.50 [353079]
            end;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(15; "Reference No."; Text[30])
        {
            Caption = 'Reference No.';
            DataClassification = CustomerContent;
        }
        field(30; "Starting Date"; DateTime)
        {
            Caption = 'Starting Date';
            DataClassification = CustomerContent;
        }
        field(35; "Ending Date"; DateTime)
        {
            Caption = 'Ending Date';
            DataClassification = CustomerContent;
        }
        field(40; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            TableRelation = "No. Series";
        }
        field(45; "Arch. No. Series"; Code[20])
        {
            Caption = 'Archivation No. Series';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            TableRelation = "No. Series";
        }
        field(50; "Arch. No."; Code[20])
        {
            Caption = 'Archivation No.';
            DataClassification = CustomerContent;
        }
        field(55; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" WHERE("Account Type" = CONST(Posting),
                                                 "Direct Posting" = CONST(true));
        }
        field(60; "Provision Account No."; Code[20])
        {
            Caption = 'Provision Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" WHERE("Account Type" = CONST(Posting),
                                                 "Direct Posting" = CONST(true));
        }
        field(62; "Allow Top-up"; Boolean)
        {
            Caption = 'Allow Top-up';
            DataClassification = CustomerContent;
            Description = 'NPR5.50';
        }
        field(65; "Print Template Code"; Code[20])
        {
            Caption = 'Print Template Code';
            DataClassification = CustomerContent;
            TableRelation = "RP Template Header" WHERE("Table ID" = CONST(6151013));
        }
        field(70; Open; Boolean)
        {
            CalcFormula = Max ("NpRv Voucher Entry".Open WHERE("Voucher No." = FIELD("No.")));
            Caption = 'Open';
            Editable = false;
            FieldClass = FlowField;
        }
        field(75; Amount; Decimal)
        {
            CalcFormula = Sum ("NpRv Voucher Entry"."Remaining Amount" WHERE("Voucher No." = FIELD("No.")));
            Caption = 'Amount';
            DecimalPlaces = 2 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(76; "Initial Amount"; Decimal)
        {
            CalcFormula = Sum ("NpRv Voucher Entry".Amount WHERE("Voucher No." = FIELD("No."),
                                                                 "Entry Type" = FILTER("Issue Voucher" | "Partner Issue Voucher" | "Top-up")));
            Caption = 'Initial Amount';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(80; "In-use Quantity"; Integer)
        {
            CalcFormula = Count ("NpRv Sales Line" WHERE(Type = CONST(Payment),
                                                         "Voucher No." = FIELD("No.")));
            Caption = 'In-use Quantity';
            Editable = false;
            FieldClass = FlowField;
        }
        field(90; "E-mail Template Code"; Code[20])
        {
            Caption = 'E-mail Template Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            TableRelation = "E-mail Template Header" WHERE("Table No." = CONST(6151013));
        }
        field(95; "SMS Template Code"; Code[10])
        {
            Caption = 'SMS Template Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            TableRelation = "SMS Template Header" WHERE("Table No." = CONST(6151013));
        }
        field(100; "Send Voucher Module"; Code[20])
        {
            CalcFormula = Lookup ("NpRv Voucher Type"."Send Voucher Module" WHERE(Code = FIELD("Voucher Type")));
            Caption = 'Send Voucher Module';
            Editable = false;
            FieldClass = FlowField;
        }
        field(103; "Send via Print"; Boolean)
        {
            Caption = 'Send via Print';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
        }
        field(105; "Send via E-mail"; Boolean)
        {
            Caption = 'Send via E-mail';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
        }
        field(107; "Send via SMS"; Boolean)
        {
            Caption = 'Send via SMS';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
        }
        field(110; "Validate Voucher Module"; Code[20])
        {
            CalcFormula = Lookup ("NpRv Voucher Type"."Validate Voucher Module" WHERE(Code = FIELD("Voucher Type")));
            Caption = 'Validate Voucher Module';
            Editable = false;
            FieldClass = FlowField;
        }
        field(120; "Apply Payment Module"; Code[20])
        {
            CalcFormula = Lookup ("NpRv Voucher Type"."Apply Payment Module" WHERE(Code = FIELD("Voucher Type")));
            Caption = 'Apply Payment Module';
            Editable = false;
            FieldClass = FlowField;
        }
        field(200; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;

            trigger OnValidate()
            begin
                UpdateContactInfo();
            end;
        }
        field(205; "Contact No."; Code[20])
        {
            Caption = 'Contact No.';
            DataClassification = CustomerContent;
            TableRelation = Contact;

            trigger OnLookup()
            var
                Cont: Record Contact;
                ContBusinessRelation: Record "Contact Business Relation";
            begin
                if "Customer No." <> '' then
                    if Cont.Get("Contact No.") then
                        Cont.SetRange("Company No.", Cont."Company No.")
                    else begin
                        ContBusinessRelation.SetCurrentKey("Link to Table", "No.");
                        ContBusinessRelation.SetRange("Link to Table", ContBusinessRelation."Link to Table"::Customer);
                        ContBusinessRelation.SetRange("No.", "Customer No.");
                        if ContBusinessRelation.FindFirst then
                            Cont.SetRange("Company No.", ContBusinessRelation."Contact No.")
                        else
                            Cont.SetRange("No.", '');
                    end;

                if "Contact No." <> '' then
                    if Cont.Get("Contact No.") then;
                if PAGE.RunModal(0, Cont) <> ACTION::LookupOK then
                    exit;

                xRec := Rec;
                Validate("Contact No.", Cont."No.");
            end;

            trigger OnValidate()
            var
                Cont: Record Contact;
                ContBusinessRelation: Record "Contact Business Relation";
                Cust: Record Customer;
            begin
                if ("Contact No." <> '') and Cont.Get("Contact No.") and (Cont."Company No." <> '') then begin
                    ContBusinessRelation.SetRange("Contact No.", Cont."Company No.");
                    ContBusinessRelation.SetRange("Link to Table", ContBusinessRelation."Link to Table"::Customer);
                    ContBusinessRelation.SetFilter("No.", '<>%1', '');
                    if ContBusinessRelation.FindFirst and Cust.Get(ContBusinessRelation."No.") then
                        "Customer No." := Cust."No.";
                end;

                UpdateContactInfo();
            end;
        }
        field(210; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            TableRelation = Customer;
            ValidateTableRelation = false;
        }
        field(215; "Name 2"; Text[50])
        {
            Caption = 'Name 2';
            DataClassification = CustomerContent;
        }
        field(220; Address; Text[50])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(225; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(230; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
            TableRelation = IF ("Country/Region Code" = CONST('')) "Post Code"
            ELSE
            IF ("Country/Region Code" = FILTER(<> '')) "Post Code" WHERE("Country/Region Code" = FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                PostCode: Record "Post Code";
            begin
                PostCode.ValidatePostCode(
                  City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(235; City; Text[30])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
            TableRelation = IF ("Country/Region Code" = CONST('')) "Post Code".City
            ELSE
            IF ("Country/Region Code" = FILTER(<> '')) "Post Code".City WHERE("Country/Region Code" = FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                PostCode: Record "Post Code";
            begin
                PostCode.ValidateCity(
                  City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(240; County; Text[30])
        {
            Caption = 'County';
            DataClassification = CustomerContent;
        }
        field(245; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }
        field(255; "E-mail"; Text[80])
        {
            Caption = 'E-mail';
            DataClassification = CustomerContent;
        }
        field(260; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
        }
        field(270; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            TableRelation = Language;
        }
        field(300; "Voucher Message"; Text[250])
        {
            Caption = 'Voucher Message';
            DataClassification = CustomerContent;
        }
        field(305; Barcode; BLOB)
        {
            Caption = 'Barcode';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            SubType = Bitmap;
        }
        field(1000; "Issue Date"; Date)
        {
            CalcFormula = Min ("NpRv Voucher Entry"."Posting Date" WHERE("Voucher No." = FIELD("No."),
                                                                         "Entry Type" = FILTER("Issue Voucher" | "Partner Issue Voucher")));
            Caption = 'Issue Date';
            Description = 'NPR5.49';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1005; "Issue Register No."; Code[10])
        {
            CalcFormula = Max ("NpRv Voucher Entry"."Register No." WHERE("Voucher No." = FIELD("No."),
                                                                         "Entry Type" = FILTER("Issue Voucher" | "Partner Issue Voucher")));
            Caption = 'Issue Register No.';
            Description = 'NPR5.49';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1007; "Issue Document Type"; Option)
        {
            CalcFormula = Max ("NpRv Voucher Entry"."Document Type" WHERE("Voucher No." = FIELD("No."),
                                                                          "Entry Type" = FILTER("Issue Voucher" | "Partner Issue Voucher")));
            Caption = 'Issue Document Type';
            Description = 'NPR5.48,NPR5.49';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'Audit Roll,Invoice';
            OptionMembers = "Audit Roll",Invoice;
        }
        field(1010; "Issue Document No."; Code[20])
        {
            CalcFormula = Max ("NpRv Voucher Entry"."Document No." WHERE("Voucher No." = FIELD("No."),
                                                                         "Entry Type" = FILTER("Issue Voucher" | "Partner Issue Voucher")));
            Caption = 'Issue Document No.';
            Description = 'NPR5.48,NPR5.49';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1013; "Issue External Document No."; Code[50])
        {
            CalcFormula = Max ("NpRv Voucher Entry"."External Document No." WHERE("Voucher No." = FIELD("No."),
                                                                                  "Entry Type" = FILTER("Issue Voucher" | "Partner Issue Voucher")));
            Caption = 'Issue External Document No.';
            Description = 'NPR5.48,NPR5.49';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1015; "Issue User ID"; Code[50])
        {
            CalcFormula = Max ("NpRv Voucher Entry"."User ID" WHERE("Voucher No." = FIELD("No."),
                                                                    "Entry Type" = FILTER("Issue Voucher" | "Partner Issue Voucher")));
            Caption = 'Issue User ID';
            Description = 'NPR5.49';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1020; "Issue Partner Code"; Code[20])
        {
            CalcFormula = Max ("NpRv Voucher Entry"."Partner Code" WHERE("Voucher No." = FIELD("No."),
                                                                         "Entry Type" = FILTER("Issue Voucher" | "Partner Issue Voucher")));
            Caption = 'Issue Partner Code';
            Description = 'NPR5.49';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1025; "Partner Clearing"; Boolean)
        {
            CalcFormula = Max ("NpRv Voucher Entry"."Partner Clearing" WHERE("Voucher No." = FIELD("No.")));
            Caption = 'Partner Clearing';
            Description = 'NPR5.49';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1030; "No. Send"; Integer)
        {
            CalcFormula = Count ("NpRv Sending Log" WHERE("Voucher No." = FIELD("No."),
                                                          "Error during Send" = CONST(false)));
            Caption = 'No. Send';
            Description = 'NPR5.55';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "Voucher Type")
        {
        }
        key(Key3; "Reference No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        NpRvVoucherEntry: Record "NpRv Voucher Entry";
    begin
        //-NPR5.55 [402015]
        CalcFields(Open);
        TestField(Open, false);

        NpRvVoucherEntry.SetRange("Voucher No.", "No.");
        if NpRvVoucherEntry.FindFirst then
            NpRvVoucherEntry.DeleteAll;
        //+NPR5.55 [402015]
    end;

    trigger OnInsert()
    var
        VoucherType: Record "NpRv Voucher Type";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        TestField("Voucher Type");
        if "No." = '' then begin
            VoucherType.Get("Voucher Type");
            VoucherType.TestField("No. Series");
            NoSeriesMgt.InitSeries(VoucherType."No. Series", xRec."No. Series", 0D, "No.", "No. Series");
        end;
        TestField("No.");
        TestReferenceNo();
    end;

    trigger OnModify()
    begin
        TestField("Voucher Type");
        TestReferenceNo();
    end;

    var
        Text000: Label 'Reference No. %1 is already used.';

    local procedure InitReferenceNo()
    var
        VoucherMgt: Codeunit "NpRv Voucher Mgt.";
    begin
        "Reference No." := VoucherMgt.GenerateReferenceNo(Rec);
    end;

    local procedure TestReferenceNo()
    var
        Voucher: Record "NpRv Voucher";
    begin
        if "Reference No." = '' then
            InitReferenceNo();

        TestField("Reference No.");

        Voucher.SetFilter("No.", '<>%1', "No.");
        Voucher.SetRange("Reference No.", "Reference No.");
        if Voucher.FindFirst then
            Error(Text000, "Reference No.");
    end;

    local procedure UpdateContactInfo()
    var
        ContBusinessRelation: Record "Contact Business Relation";
        Cust: Record Customer;
        Cont: Record Contact;
    begin
        if "Contact No." <> '' then begin
            Cont.Get("Contact No.");
            Name := Cont.Name;
            //-NPR5.53 [378597]
            "Name 2" := Cont."Name 2";
            //+NPR5.53 [378597]
            Address := Cont.Address;
            "Address 2" := Cont."Address 2";
            City := Cont.City;
            "Post Code" := Cont."Post Code";
            County := Cont.County;
            "Country/Region Code" := Cont."Country/Region Code";
            "E-mail" := Cont."E-Mail";
            "Phone No." := Cont."Phone No.";
            //-NPR5.55 [397527]
            "Language Code" := Cont."Language Code";
            //-NPR5.55 [397527]
            exit;
        end;

        if "Customer No." <> '' then begin
            Cust.Get("Customer No.");
            Name := Cust.Name;
            //-NPR5.53 [378597]
            "Name 2" := Cust."Name 2";
            //+NPR5.53 [378597]
            Address := Cust.Address;
            "Address 2" := Cust."Address 2";
            City := Cust.City;
            "Post Code" := Cust."Post Code";
            County := Cust.County;
            "Country/Region Code" := Cust."Country/Region Code";
            "E-mail" := Cust."E-Mail";
            "Phone No." := Cust."Phone No.";
            //-NPR5.55 [397527]
            "Language Code" := Cust."Language Code";
            //-NPR5.55 [397527]
            exit;
        end;
    end;

    procedure CalcInUseQty() InUseQty: Integer
    begin
        //-NPR5.55 [402015]
        //-NPR5.48 [302179]
        CalcFields("In-use Quantity");
        exit("In-use Quantity");
        //+NPR5.48 [302179]
        //+NPR5.55 [402015]
    end;
}

