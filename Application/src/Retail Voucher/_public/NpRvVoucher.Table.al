table 6151013 "NPR NpRv Voucher"
{
    Caption = 'Retail Voucher';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpRv Vouchers";
    LookupPageID = "NPR NpRv Vouchers";

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
            TableRelation = "NPR NpRv Voucher Type";

            trigger OnValidate()
            var
                VoucherType: Record "NPR NpRv Voucher Type";
            begin
                VoucherType.Get("Voucher Type");
                Description := VoucherType.Description;
                if "Starting Date" = 0DT then
                    "Starting Date" := CreateDateTime(Today, 0T);
                if Format(VoucherType."Valid Period") <> '' then
                    "Ending Date" := CreateDateTime(CalcDate(VoucherType."Valid Period", DT2Date("Starting Date")), DT2Time("Starting Date"));

                "No. Series" := VoucherType."No. Series";
                "Arch. No. Series" := VoucherType."Arch. No. Series";
                "Print Object Type" := VoucherType."Print Object Type";
                "Print Object ID" := VoucherType."Print Object ID";
                "Print Template Code" := VoucherType."Print Template Code";
                "E-mail Template Code" := VoucherType."E-mail Template Code";
                "SMS Template Code" := VoucherType."SMS Template Code";
                "Account No." := VoucherType."Account No.";
                "Voucher Message" := VoucherType."Voucher Message";
                "Allow Top-up" := VoucherType."Allow Top-up";
            end;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(15; "Reference No."; Text[50])
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
            TableRelation = "No. Series";
        }
        field(45; "Arch. No. Series"; Code[20])
        {
            Caption = 'Archivation No. Series';
            DataClassification = CustomerContent;
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
        }
        field(63; "Print Object Type"; Enum "NPR Print Object Type")
        {
            Caption = 'Print Object Type';
            DataClassification = CustomerContent;
            InitValue = Template;
        }
        field(64; "Print Object ID"; Integer)
        {
            Caption = 'Print Object ID';
            DataClassification = CustomerContent;
            TableRelation = IF ("Print Object Type" = CONST(Codeunit)) AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Codeunit)) ELSE
            IF ("Print Object Type" = CONST(Report)) AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Report));
            BlankZero = true;
        }
        field(65; "Print Template Code"; Code[20])
        {
            Caption = 'Print Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR RP Template Header" WHERE("Table ID" = CONST(6151013));
        }
        field(70; Open; Boolean)
        {
            CalcFormula = Max("NPR NpRv Voucher Entry".Open WHERE("Voucher No." = FIELD("No.")));
            Caption = 'Open';
            Editable = false;
            FieldClass = FlowField;
        }
        field(75; Amount; Decimal)
        {
            CalcFormula = Sum("NPR NpRv Voucher Entry"."Remaining Amount" WHERE("Voucher No." = FIELD("No.")));
            Caption = 'Amount';
            DecimalPlaces = 2 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(76; "Initial Amount"; Decimal)
        {
            CalcFormula = Sum("NPR NpRv Voucher Entry".Amount WHERE("Voucher No." = FIELD("No."),
                                                                 "Entry Type" = FILTER("Issue Voucher" | "Partner Issue Voucher" | "Top-up")));
            Caption = 'Initial Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(80; "In-use Quantity"; Integer)
        {
            CalcFormula = Count("NPR NpRv Sales Line" WHERE(Type = CONST(Payment),
                                                         "Voucher No." = FIELD("No.")));
            Caption = 'In-use Quantity';
            Editable = false;
            FieldClass = FlowField;
        }
        field(90; "E-mail Template Code"; Code[20])
        {
            Caption = 'E-mail Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR E-mail Template Header" WHERE("Table No." = CONST(6151013));
        }
        field(95; "SMS Template Code"; Code[10])
        {
            Caption = 'SMS Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR SMS Template Header" WHERE("Table No." = CONST(6151013));
        }
        field(100; "Send Voucher Module"; Code[20])
        {
            CalcFormula = Lookup("NPR NpRv Voucher Type"."Send Voucher Module" WHERE(Code = FIELD("Voucher Type")));
            Caption = 'Send Voucher Module';
            Editable = false;
            FieldClass = FlowField;
        }
        field(103; "Send via Print"; Boolean)
        {
            Caption = 'Send via Print';
            DataClassification = CustomerContent;
        }
        field(105; "Send via E-mail"; Boolean)
        {
            Caption = 'Send via E-mail';
            DataClassification = CustomerContent;
        }
        field(107; "Send via SMS"; Boolean)
        {
            Caption = 'Send via SMS';
            DataClassification = CustomerContent;
        }
        field(110; "Validate Voucher Module"; Code[20])
        {
            CalcFormula = Lookup("NPR NpRv Voucher Type"."Validate Voucher Module" WHERE(Code = FIELD("Voucher Type")));
            Caption = 'Validate Voucher Module';
            Editable = false;
            FieldClass = FlowField;
        }
        field(120; "Apply Payment Module"; Code[20])
        {
            CalcFormula = Lookup("NPR NpRv Voucher Type"."Apply Payment Module" WHERE(Code = FIELD("Voucher Type")));
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
                        if ContBusinessRelation.FindFirst() then
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
                    if ContBusinessRelation.FindFirst() and Cust.Get(ContBusinessRelation."No.") then
                        "Customer No." := Cust."No.";
                end;

                UpdateContactInfo();
            end;
        }
        field(210; Name; Text[100])
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
        field(220; Address; Text[100])
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
            SubType = Bitmap;
            ObsoleteState = Removed;
            ObsoleteReason = 'Use Media instead of Blob type.';
        }
        field(306; "Barcode Image"; Media)
        {
            Caption = 'Barcode';
            DataClassification = CustomerContent;
        }
        field(1000; "Issue Date"; Date)
        {
            CalcFormula = Min("NPR NpRv Voucher Entry"."Posting Date" WHERE("Voucher No." = FIELD("No."),
                                                                         "Entry Type" = FILTER("Issue Voucher" | "Partner Issue Voucher")));
            Caption = 'Issue Date';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1005; "Issue Register No."; Code[10])
        {
            CalcFormula = Max("NPR NpRv Voucher Entry"."Register No." WHERE("Voucher No." = FIELD("No."),
                                                                         "Entry Type" = FILTER("Issue Voucher" | "Partner Issue Voucher")));
            Caption = 'Issue POS Unit No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1007; "Issue Document Type"; Option)
        {
            CalcFormula = Max("NPR NpRv Voucher Entry"."Document Type" WHERE("Voucher No." = FIELD("No."),
                                                                          "Entry Type" = FILTER("Issue Voucher" | "Partner Issue Voucher")));
            Caption = 'Issue Document Type';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'POS Entry,Invoice,Credit Memo';
            OptionMembers = "Audit Roll",Invoice,"Credit Memo";
        }
        field(1010; "Issue Document No."; Code[20])
        {
            CalcFormula = Max("NPR NpRv Voucher Entry"."Document No." WHERE("Voucher No." = FIELD("No."),
                                                                         "Entry Type" = FILTER("Issue Voucher" | "Partner Issue Voucher")));
            Caption = 'Issue Document No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1013; "Issue External Document No."; Code[50])
        {
            CalcFormula = Max("NPR NpRv Voucher Entry"."External Document No." WHERE("Voucher No." = FIELD("No."),
                                                                                  "Entry Type" = FILTER("Issue Voucher" | "Partner Issue Voucher")));
            Caption = 'Issue External Document No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1015; "Issue User ID"; Code[50])
        {
            CalcFormula = Max("NPR NpRv Voucher Entry"."User ID" WHERE("Voucher No." = FIELD("No."),
                                                                    "Entry Type" = FILTER("Issue Voucher" | "Partner Issue Voucher")));
            Caption = 'Issue User ID';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1020; "Issue Partner Code"; Code[20])
        {
            CalcFormula = Max("NPR NpRv Voucher Entry"."Partner Code" WHERE("Voucher No." = FIELD("No."),
                                                                         "Entry Type" = FILTER("Issue Voucher" | "Partner Issue Voucher")));
            Caption = 'Issue Partner Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1025; "Partner Clearing"; Boolean)
        {
            CalcFormula = Max("NPR NpRv Voucher Entry"."Partner Clearing" WHERE("Voucher No." = FIELD("No.")));
            Caption = 'Partner Clearing';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1030; "No. Send"; Integer)
        {
            CalcFormula = Count("NPR NpRv Sending Log" WHERE("Voucher No." = FIELD("No."),
                                                          "Error during Send" = CONST(false)));
            Caption = 'No. Send';
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

    trigger OnDelete()
    var
        NpRvVoucherEntry: Record "NPR NpRv Voucher Entry";
    begin
        CalcFields(Open);
        TestField(Open, false);

        NpRvVoucherEntry.SetRange("Voucher No.", "No.");
        if NpRvVoucherEntry.FindFirst() then
            NpRvVoucherEntry.DeleteAll();
    end;

    trigger OnInsert()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
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
        VoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        ReferenceNo: Text;
        ReferenceNoErr: Label 'Generated Reference Number for Voucher Type %1 is too long. Please check setup or contact administrator.';
    begin
        ReferenceNo := VoucherMgt.GenerateReferenceNo(Rec);
        if StrLen(ReferenceNo) > MaxStrLen("Reference No.") then
            Error(ReferenceNoErr, Rec."Voucher Type") else
            "Reference No." := CopyStr(ReferenceNo, 1, MaxStrLen("Reference No."));
    end;

    local procedure TestReferenceNo()
    var
        Voucher: Record "NPR NpRv Voucher";
    begin
        if "Reference No." = '' then
            InitReferenceNo();

        TestField("Reference No.");

        Voucher.SetFilter("No.", '<>%1', "No.");
        Voucher.SetRange("Reference No.", "Reference No.");
        if Voucher.FindFirst() then
            Error(Text000, "Reference No.");
    end;

    local procedure UpdateContactInfo()
    var
        Cust: Record Customer;
        Cont: Record Contact;
    begin
        if "Contact No." <> '' then begin
            Cont.Get("Contact No.");
            Name := Cont.Name;
            "Name 2" := Cont."Name 2";
            Address := Cont.Address;
            "Address 2" := Cont."Address 2";
            City := Cont.City;
            "Post Code" := Cont."Post Code";
            County := Cont.County;
            "Country/Region Code" := Cont."Country/Region Code";
            "E-mail" := Cont."E-Mail";
            "Phone No." := Cont."Phone No.";
            "Language Code" := Cont."Language Code";
            exit;
        end;

        if "Customer No." <> '' then begin
            Cust.Get("Customer No.");
            Name := Cust.Name;
            "Name 2" := Cust."Name 2";
            Address := Cust.Address;
            "Address 2" := Cust."Address 2";
            City := Cust.City;
            "Post Code" := Cust."Post Code";
            County := Cust.County;
            "Country/Region Code" := Cust."Country/Region Code";
            "E-mail" := Cust."E-Mail";
            "Phone No." := Cust."Phone No.";
            "Language Code" := Cust."Language Code";
            exit;
        end;
    end;

    procedure CalcInUseQty() InUseQty: Integer
    begin
        CalcFields("In-use Quantity");
        exit("In-use Quantity");
    end;

    procedure GetImageContent(var TenantMedia: Record "Tenant Media")
    begin
        TenantMedia.Init();
        if not Rec."Barcode Image".HasValue() then
            exit;
        if TenantMedia.Get(Rec."Barcode Image".MediaId()) then
            TenantMedia.CalcFields(Content);
    end;
}

