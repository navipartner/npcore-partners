table 6151015 "NpRv Sales Line"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.48/MHA /20190123  CASE 341711 Added field 103 "Send via Print", 105 "Send via E-mail", 107 "Send via SMS"
    // NPR5.49/MHA /20190228  CASE 342811 Added field 60 "Reference No."
    // NPR5.50/MHA /20190426  CASE 353079 Added Option "Top-up" to field 30 "Type"
    // NPR5.50/MMV /20190527  CASE 356003 Added field 310,
    //                                    Added Option "Partner Issue Voucher" to field 30, for "delayed" partner voucher posting through same flow as normal.
    // NPR5.53/MHA /20200103  CASE 384055 Updated Name 2 reference in UpdateContactInfo()
    // NPR5.54/ALPO/20200423 CASE 401611 5.54 upgrade performace optimization
    // NPR5.55/ALPO/20200424 CASE 401611 Remove dummy fields needed for 5.54 upgrade performace optimization
    // NPR5.55/MHA /20200427  CASE 402015 Changed Primary Key to field 100 "Id" and added Sales Document Fields
    // NPR5.55/MHA /20200701  CASE 397527 Added field 270 "Language Code"

    Caption = 'Retail Voucher Sales Line';
    DataClassification = CustomerContent;
    DrillDownPageID = "NpRv Sales Lines";
    LookupPageID = "NpRv Sales Lines";

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = Register;
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
            TableRelation = "NpRv Voucher Type";
        }
        field(55; "Voucher No."; Code[20])
        {
            Caption = 'Voucher No.';
            DataClassification = CustomerContent;
            TableRelation = "NpRv Voucher";
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
        field(410; "Document Type"; Option)
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
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
            Description = 'NPR5.55';
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

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        NpRvSalesLineReference: Record "NpRv Sales Line Reference";
    begin
        //-NPR5.55 [402015]
        NpRvSalesLineReference.SetRange("Sales Line Id", Id);
        if NpRvSalesLineReference.FindFirst then
            NpRvSalesLineReference.DeleteAll;
        //+NPR5.55 [402015]
    end;

    trigger OnInsert()
    begin
        //-NPR5.55 [402015]
        if IsNullGuid(Id) then
            Id := CreateGuid;
        //+NPR5.55 [402015]
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
            //-NPR5.53 [384055]
            "Name 2" := Cont."Name 2";
            //+NPR5.53 [384055]
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
            //-NPR5.53 [384055]
            "Name 2" := Cust."Name 2";
            //+NPR5.53 [384055]
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
}

