table 6151015 "NPR NpRv Sales Line"
{
    Caption = 'Retail Voucher Sales Line';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpRv Sales Lines";
    LookupPageID = "NPR NpRv Sales Lines";

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR POS Unit";
        }
        field(5; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
            Editable = false;
            NotBlank = true;
        }
        field(10; "Sale Type"; Option)
        {
            Caption = 'Sale Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Deposit,Out payment,Comment,Cancelled,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,Cancelled,"Open/Close";
        }
        field(15; "Sale Date"; Date)
        {
            Caption = 'Sale Date';
            DataClassification = CustomerContent;
        }
        field(20; "Sale Line No."; Integer)
        {
            Caption = 'Sale Line No.';
            DataClassification = CustomerContent;
        }
        field(30; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.50';
            OptionCaption = 'New Voucher,Payment,Top-up,Partner Issue Voucher';
            OptionMembers = "New Voucher",Payment,"Top-up","Partner Issue Voucher";
        }
        field(40; "Applies-to Sale Line No."; Integer)
        {
            Caption = 'Applies-to Sale Line No.';
            DataClassification = CustomerContent;
        }
        field(45; "Applies-to Voucher Line No."; Integer)
        {
            Caption = 'Applies-to Voucher Line No.';
            DataClassification = CustomerContent;
        }
        field(50; "Voucher Type"; Code[20])
        {
            Caption = 'Voucher Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpRv Voucher Type";
        }
        field(55; "Voucher No."; Code[20])
        {
            Caption = 'Voucher No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpRv Voucher";
        }
        field(60; "Reference No."; Text[30])
        {
            Caption = 'Reference No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.49';
        }
        field(65; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(80; "Starting Date"; DateTime)
        {
            Caption = 'Starting Date';
            DataClassification = CustomerContent;
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
            Description = 'NPR5.55';
            TableRelation = Language;
        }
        field(300; "Voucher Message"; Text[250])
        {
            Caption = 'Voucher Message';
            DataClassification = CustomerContent;
        }
        field(310; Posted; Boolean)
        {
            Caption = 'Posted';
            DataClassification = CustomerContent;
        }
        field(400; "External Document No."; Code[50])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            NotBlank = true;
        }
        field(405; "Document Source"; Option)
        {
            Caption = 'Document Source';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            OptionCaption = 'POS,Sales Document,Payment Line';
            OptionMembers = POS,"Sales Document","Payment Line";
        }
        field(410; "Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
        }
        field(420; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            TableRelation = "Sales Header"."No." WHERE("Document Type" = FIELD("Document Type"));
        }
        field(430; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
        }
        field(440; "Posting No."; Code[20])
        {
            Caption = 'Posting No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
        }
        field(1000; Id; Guid)
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
        }
        field(1010; "Retail ID"; Guid)
        {
            Caption = 'Retail ID';
            DataClassification = CustomerContent;
        }
        field(1020; "Parent Id"; Guid)
        {
            Caption = 'Parent Id';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
        }
    }

    keys
    {
        key(Key1; Id)
        {
        }
        key(Key2; Type, "Voucher Type", "Voucher No.", "Reference No.")
        {
        }
        key(Key3; "Document Source", "Document Type", "Document No.", "Document Line No.")
        {
        }
        key(Key4; "Retail ID")
        {
        }
    }

    trigger OnDelete()
    var
        NpRvSalesLineReference: Record "NPR NpRv Sales Line Ref.";
    begin
        NpRvSalesLineReference.SetRange("Sales Line Id", Id);
        if NpRvSalesLineReference.FindFirst() then
            NpRvSalesLineReference.DeleteAll();
    end;

    trigger OnInsert()
    begin
        if IsNullGuid(Id) then
            Id := CreateGuid();
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
}

