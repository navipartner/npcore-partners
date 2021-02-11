table 6014504 "NPR Customer Repair"
{
    // //-NPR3.0m ved Nikolai Pedersen
    //   Afdelingskode indsat på onInsert
    // 
    // //-NPR3.0p  Henrik Ohm
    //   customer.onInsert has NameAndNumbers lookup, so not needed here
    // 
    // NPR7.000.000  TS 17-01 13 : Added an Option Field called Type to choose the Type of customer which was before a Radio Button
    // NPR70.00.01.00/MH/20150113  CASE 199932 Removed Web references (WEB1.00).
    // NPK70.00.01.01/BHR/20150130 CASE 204899 Created new field 120 'Finalized'
    // NPR70.00.01.02/MH/20150223  CASE 206395 Removed reference to deprecated field Contact."Internet Number"
    // NPR5.26/TS  /20160809  CASE 248351 Added Picture Path for Pictures.Removed Unused Variables and Added Table Relation to Invoice To. Removed function SendMail()
    // NPR5.26/TS  /20160913  CASE 251086 Added Field Related to Invoice No.
    // NPR5.27/TS  /20161017  CASE 254715 Added Field Item Description
    // NPR5.27/MHA /20161025  CASE 255580 Deleted Unused function: SendStatus. Renamed Danish Variables to English. Moved Global Variables to Locals
    // NPR5.29/TS  /20161110  CASE 257937 Populate Global Dimension  and Location base on Users register
    // NPR5.29/TS  /20161221  CASE 253270 Email Copied from Customer.Email
    // NPR5.30/TS  /20170203  CASE 264915 Removed field Mandatory Customer No.
    // NPR5.30/BHR /20170203  CASE 262923 Add field Bag No, 'CreateSalesLine' function to generate Sales Document
    // NPR5.30/TJ  /20170215  CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.32/LS  /20170522  CASE 276203 Added code on field Status
    // NPR5.36/TJ  /20170918  CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                    Removed unused variables
    //                                    Renamed all the danish OptionString properties to english
    // NPR5.38/TJ  /20171218  CASE 225415 Renumbered fields from range 50xxx to range below 50000
    // NPR5.41/TS  /20180403  CASE 309631 Corrected Captions
    // NPR5.53/ALPO/20191025  CASE 371956 Dimensions: POS Store & POS Unit integration; discontinue dimensions on Cash Register

    Caption = 'Customer Repair';
    LookupPageID = "NPR Customer Repair List";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[10])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = IF ("Customer Type" = CONST(Cash)) Contact
            ELSE
            IF ("Customer Type" = CONST(Ordinary)) Customer;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Contact: Record Contact;
                ContactBusinessRelation: Record "Contact Business Relation";
                Customer: Record Customer;
                RetailFormCode: Codeunit "NPR Retail Form Code";
            begin
                if RetailFormCode.CreateCustomerOld("Customer No.", "Customer Type", "Salesperson Code") then begin
                    if "Customer Type" = "Customer Type"::Ordinary then begin
                        Customer.Get("Customer No.");
                        Name := Customer.Name;
                        Address := Customer.Address;
                        "Address 2" := Customer."Address 2";
                        City := Customer.City;
                        "Phone No." := Customer."Phone No.";
                        "Post Code" := Customer."Post Code";
                        "Fax No." := Customer."Fax No.";
                        //-NPR5.26
                        Validate("Invoice To", Customer."No.");
                        //+NPR5.26
                        //-NPR5.29
                        "E-mail" := Customer."E-Mail";
                        //+NPR5.29
                    end else begin
                        Contact.Get("Customer No.");
                        Name := Contact.Name;
                        Address := Contact.Address;
                        "Address 2" := Contact."Address 2";
                        City := Contact.City;
                        "Phone No." := Contact."Phone No.";
                        "Post Code" := Contact."Post Code";
                        "Fax No." := Contact."Fax No.";
                        "Mobile Phone No." := Contact."Mobile Phone No.";
                        //-NPR5.26
                        ContactBusinessRelation.Reset;
                        ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
                        ContactBusinessRelation.SetRange("Contact No.", "Customer No.");
                        if not ContactBusinessRelation.FindFirst then
                            exit;
                        if not Customer.Get(ContactBusinessRelation."No.") then
                            exit;
                        Validate("Invoice To", Customer."No.");
                        //+NPR5.26
                    end;
                end else begin
                    "Customer No." := '';
                    Name := '';
                    Address := '';
                    "Address 2" := '';
                    City := '';
                    "Phone No." := '';
                    "Post Code" := '';
                    "Fax No." := '';
                    "Mobile Phone No." := '';
                end;
            end;
        }
        field(3; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Contact: Record Contact;
                Customer: Record Customer;
            begin
                //-NPR5.30
                //IF RetailSetup."Mandatory Customer No." THEN BEGIN
                if "Customer No." = '' then
                    exit;
                //+NPR5.30
                TestField("Customer No.");
                if (Name <> xRec.Name) then begin
                    if "Customer Type" = "Customer Type"::Ordinary then begin
                        Customer.Get("Customer No.");
                        if (Customer.Name <> Name) and
                          (Confirm(StrSubstNo(Text1060001,
                            Customer.Name, Name), false)) then begin
                            Customer.Name := Name;
                            Customer.Modify;
                        end else
                            Name := Customer.Name;
                    end else begin
                        Contact.Get("Customer No.");
                        if (Contact.Name <> Name) and
                          (Confirm(StrSubstNo(Text1060001,
                            Contact.Name, Name), false)) then begin
                            Contact.Name := Name;
                            Contact.Modify;
                        end else
                            Name := Contact.Name;
                    end;
                end;
                //-NPR5.30
                //END;
                //+NPR5.30
            end;
        }
        field(4; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Contact: Record Contact;
                Customer: Record Customer;
            begin
                //-NPR5.30
                //IF RetailSetup."Mandatory Customer No." THEN BEGIN
                if "Customer No." = '' then
                    exit;
                //+NPR5.30
                TestField("Customer No.");
                if (Address <> xRec.Address) then begin
                    if "Customer Type" = "Customer Type"::Ordinary then begin
                        Customer.Get("Customer No.");
                        if (Customer.Address <> Address) and
                          (Confirm(StrSubstNo(Text1060002,
                            Customer.Address, Address), false)) then begin
                            Customer.Address := Address;
                            Customer.Modify;
                        end else
                            Address := Customer.Address;
                    end else begin
                        Contact.Get("Customer No.");
                        if (Contact.Address <> Address) and
                          (Confirm(StrSubstNo(Text1060002,
                            Contact.Address, Address), false)) then begin
                            Contact.Address := Address;
                            Contact.Modify;
                        end else
                            Address := Contact.Address;
                    end;
                end;
                //-NPR5.30
                //END;
                //+NPR5.30
            end;
        }
        field(5; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Contact: Record Contact;
                Customer: Record Customer;
            begin
                //-NPR5.30
                //IF RetailSetup."Mandatory Customer No." THEN BEGIN
                if "Customer No." = '' then
                    exit;

                //+NPR5.30
                TestField("Customer No.");
                if ("Address 2" <> xRec."Address 2") then begin
                    if "Customer Type" = "Customer Type"::Ordinary then begin
                        Customer.Get("Customer No.");
                        if (Customer."Address 2" <> "Address 2") and
                          (Confirm(StrSubstNo(Text1060003,
                            Customer."Address 2", "Address 2"), false)) then begin
                            Customer."Address 2" := "Address 2";
                            Customer.Modify;
                        end else
                            "Address 2" := Customer."Address 2";
                    end else begin
                        Contact.Get("Customer No.");
                        if (Contact."Address 2" <> "Address 2") and
                          (Confirm(StrSubstNo(Text1060003,
                            Contact."Address 2", "Address 2"), false)) then begin
                            Contact."Address 2" := "Address 2";
                            Contact.Modify;
                        end else
                            "Address 2" := Contact."Address 2";
                    end;
                end;
                //-NPR5.30
                //END;
                //+NPR5.30
            end;
        }
        field(6; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            TableRelation = "Post Code";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Contact: Record Contact;
                Customer: Record Customer;
                PostCode: Record "Post Code";
            begin
                //-NPR5.30
                //IF RetailSetup."Mandatory Customer No." THEN BEGIN
                if "Customer No." = '' then
                    exit;

                //+NPR5.30
                TestField("Invoice To");
                if ("Post Code" <> xRec."Post Code") then begin
                    if "Customer Type" = "Customer Type"::Ordinary then begin
                        Customer.Get("Customer No.");
                        if (Customer."Post Code" <> "Post Code") and
                          (Confirm(StrSubstNo(Text1060004,
                            Customer."Post Code", "Post Code"), false)) then begin
                            Customer."Post Code" := "Post Code";
                            Customer.Modify;
                        end else
                            "Post Code" := Customer."Post Code";
                    end else begin
                        Contact.Get("Customer No.");
                        if (Contact."Post Code" <> "Post Code") and
                          (Confirm(StrSubstNo(Text1060004,
                            Contact."Post Code", "Post Code"), false)) then begin
                            Contact."Post Code" := "Post Code";
                            Contact.Modify;
                        end else
                            "Post Code" := Contact."Post Code";
                    end;
                end;
                //-NPR5.30
                //END;
                //+NPR5.30

                PostCode.Reset;
                PostCode.SetRange(Code, "Post Code");
                if PostCode.FindFirst then
                    City := PostCode.City;
            end;
        }
        field(7; City; Text[30])
        {
            Caption = 'City';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Contact: Record Contact;
                Customer: Record Customer;
            begin
                //-NPR5.30
                //IF RetailSetup."Mandatory Customer No." THEN BEGIN
                if "Customer No." = '' then
                    exit;

                //+NPR5.30
                TestField("Customer No.");
                if (City <> xRec.City) then begin
                    if "Customer Type" = "Customer Type"::Ordinary then begin
                        Customer.Get("Customer No.");
                        if (Customer.City <> City) and
                          (Confirm(StrSubstNo(Text1060005,
                            Customer.City, City), false)) then begin
                            Customer.City := City;
                            Customer.Modify;
                        end else
                            City := Customer.City;
                    end else begin
                        Contact.Get("Customer No.");
                        if (Contact.City <> City) and
                          (Confirm(StrSubstNo(Text1060005,
                            Contact.City, City), false)) then begin
                            Contact.City := City;
                            Contact.Modify;
                        end else
                            City := Contact.City;
                    end;
                end;
                //-NPR5.30
                //END;
                //+NPR5.30
            end;
        }
        field(8; "Invoice To"; Code[20])
        {
            Caption = 'Invoice To';
            TableRelation = IF ("Customer Type" = CONST(Ordinary)) Customer;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ContactBusinessRelation: Record "Contact Business Relation";
                Customer: Record Customer;
            begin
                if "Invoice To" <> '' then begin
                    if "Customer Type" = "Customer Type"::Ordinary then begin
                        Customer.Get("Invoice To");
                        "Customer Name" := Customer.Name;
                        "Customer Address" := Customer.Address;
                        "Customer Address 2" := Customer."Address 2";
                        "Customer Post Code" := Customer."Post Code";
                        "Customer City" := Customer.City;
                    end else begin
                        //-NPR5.26
                        //contact.GET("Invoice To");
                        //"Customer Name" := contact.Name;
                        //"Customer Address" := contact.Address;
                        //"Customer Address 2" := contact."Address 2";
                        //"Customer Post Code" := contact."Post Code";
                        //"Customer City" := contact.City;
                        ContactBusinessRelation.Reset;
                        ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
                        ContactBusinessRelation.SetRange("Contact No.", "Customer No.");
                        if not ContactBusinessRelation.FindFirst then
                            exit;
                        if not Customer.Get(ContactBusinessRelation."No.") then
                            exit;
                        "Customer Name" := Customer.Name;
                        "Customer Address" := Customer.Address;
                        "Customer Address 2" := Customer."Address 2";
                        "Customer Post Code" := Customer."Post Code";
                        "Customer City" := Customer.City;
                        //-NPR5.26
                    end;
                end else begin
                    "Customer Name" := '';
                    "Customer Address" := '';
                    "Customer Address 2" := '';
                    "Customer Post Code" := '';
                    "Customer City" := '';
                end;
            end;
        }
        field(9; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Contact: Record Contact;
                Customer: Record Customer;
            begin
                TestField("Invoice To");
                if ("Customer Name" <> xRec."Customer Name") then begin
                    if "Customer Type" = "Customer Type"::Ordinary then begin
                        Customer.Get("Invoice To");
                        if (Customer.Name <> "Customer Name") and
                          (Confirm(StrSubstNo(Text1060006,
                            Customer.Name, "Customer Name"), false)) then begin
                            Customer.Name := "Customer Name";
                            Customer.Modify;
                        end else
                            "Customer Name" := Customer.Name;
                    end else begin
                        Contact.Get("Invoice To");
                        if (Contact.Name <> "Customer Name") and
                          (Confirm(StrSubstNo(Text1060006,
                            Contact.Name, "Customer Name"), false)) then begin
                            Contact.Name := "Customer Name";
                            Contact.Modify;
                        end else
                            "Customer Name" := Contact.Name;
                    end;
                end;
            end;
        }
        field(10; "Customer Address"; Text[100])
        {
            Caption = 'Customer Address';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Contact: Record Contact;
                Customer: Record Customer;
            begin
                TestField("Invoice To");
                if ("Customer Address" <> xRec."Customer Address") then begin
                    if "Customer Type" = "Customer Type"::Ordinary then begin
                        Customer.Get("Invoice To");
                        if (Customer.Address <> "Customer Address") and
                          (Confirm(StrSubstNo(Text1060007,
                            Customer.Address, "Customer Address"), false)) then begin
                            Customer.Address := "Customer Address";
                            Customer.Modify;
                        end else
                            "Customer Address" := Customer.Address;
                    end else begin
                        Contact.Get("Invoice To");
                        if (Contact.Address <> "Customer Address") and
                          (Confirm(StrSubstNo(Text1060007,
                            Contact.Address, "Customer Address"), false)) then begin
                            Contact.Address := "Customer Address";
                            Contact.Modify;
                        end else
                            "Customer Address" := Contact.Address;
                    end;
                end;
            end;
        }
        field(11; "Customer Address 2"; Text[50])
        {
            Caption = 'Customer Address 2';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Contact: Record Contact;
                Customer: Record Customer;
            begin
                TestField("Invoice To");
                if ("Customer Address 2" <> xRec."Customer Address 2") then begin
                    if "Customer Type" = "Customer Type"::Ordinary then begin
                        Customer.Get("Invoice To");
                        if (Customer."Address 2" <> "Customer Address 2") and
                          (Confirm(StrSubstNo(Text1060008,
                            Customer."Address 2", "Customer Address 2"), false)) then begin
                            Customer."Address 2" := "Customer Address 2";
                            Customer.Modify;
                        end else
                            "Customer Address 2" := Customer."Address 2";
                    end else begin
                        Contact.Get("Invoice To");
                        if (Contact."Address 2" <> "Customer Address 2") and
                          (Confirm(StrSubstNo(Text1060008,
                            Contact."Address 2", "Customer Address 2"), false)) then begin
                            Contact."Address 2" := "Customer Address 2";
                            Contact.Modify;
                        end else
                            "Customer Address 2" := Contact."Address 2";
                    end;
                end;
            end;
        }
        field(12; "Customer Post Code"; Code[20])
        {
            Caption = 'Customer Post Code';
            TableRelation = "Post Code";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Contact: Record Contact;
                Customer: Record Customer;
                PostCode: Record "Post Code";
            begin
                TestField("Invoice To");
                if ("Customer Post Code" <> xRec."Customer Post Code") then begin
                    if "Customer Type" = "Customer Type"::Ordinary then begin
                        Customer.Get("Invoice To");
                        if (Customer."Post Code" <> "Customer Post Code") and
                          (Confirm(StrSubstNo(Text1060009,
                            Customer."Post Code", "Customer Post Code"), false)) then begin
                            Customer."Post Code" := "Customer Post Code";
                            Customer.Modify;
                        end else
                            "Customer Post Code" := Customer."Post Code";
                    end else begin
                        Contact.Get("Invoice To");
                        if (Contact."Post Code" <> "Customer Post Code") and
                          (Confirm(StrSubstNo(Text1060009,
                            Contact."Post Code", "Customer Post Code"), false)) then begin
                            Contact."Post Code" := "Customer Post Code";
                            Contact.Modify;
                        end else
                            "Customer Post Code" := Contact."Post Code";
                    end;
                end;

                if PostCode.Get("Customer Post Code") then
                    "Customer City" := PostCode.City;
            end;
        }
        field(13; "Customer City"; Text[30])
        {
            Caption = 'Customer City';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Contact: Record Contact;
                Customer: Record Customer;
            begin
                TestField("Invoice To");
                if ("Customer City" <> xRec."Customer City") then begin
                    if "Customer Type" = "Customer Type"::Ordinary then begin
                        Customer.Get("Invoice To");
                        if (Customer.City <> "Customer City") and
                          (Confirm(StrSubstNo(Text1060010,
                            Customer.City, "Customer City"), false)) then begin
                            Customer.City := "Customer City";
                            Customer.Modify;
                        end else
                            "Customer City" := Customer.City;
                    end else begin
                        Contact.Get("Invoice To");
                        if (Contact.City <> "Customer City") and
                          (Confirm(StrSubstNo(Text1060010,
                            Contact.City, "Customer City"), false)) then begin
                            Contact.City := "Customer City";
                            Contact.Modify;
                        end else
                            "Customer City" := Contact.City;
                    end;
                end;
            end;
        }
        field(14; "Repairer No."; Code[20])
        {
            Caption = 'Repairer No.';
            TableRelation = Vendor;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                if "Repairer No." <> '' then begin
                    Vendor.Get("Repairer No.");
                    "Repairer Name" := Vendor.Name;
                    "Repairer Address" := Vendor.Address;
                    "Repairer Address2" := Vendor."Address 2";
                    "Repairer Post Code" := Vendor."Post Code";
                    "Repairer City" := Vendor.City;
                end else begin
                    "Repairer Name" := '';
                    "Repairer Address" := '';
                    "Repairer Address2" := '';
                    "Repairer Post Code" := '';
                    "Repairer City" := '';
                end;
            end;
        }
        field(15; "Repairer Name"; Text[100])
        {
            Caption = 'Repairer Name';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                TestField("Repairer No.");
                if ("Repairer Name" <> xRec."Repairer Name") then begin
                    Vendor.Get("Repairer No.");
                    if (Vendor.Name <> "Repairer Name") and
                      (Confirm(StrSubstNo(Text1060011,
                        Vendor.Name, "Repairer Name"), false)) then begin
                        Vendor.Name := "Repairer Name";
                        Vendor.Modify;
                    end else
                        "Repairer Name" := Vendor.Name;
                end;
            end;
        }
        field(16; "Repairer Address"; Text[100])
        {
            Caption = 'Repairer Address';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                TestField("Repairer No.");
                if ("Repairer Address" <> xRec."Repairer Address") then begin
                    Vendor.Get("Repairer No.");
                    if (Vendor.Address <> "Repairer Address") and
                      (Confirm(StrSubstNo(Text1060012,
                        Vendor.Address, "Repairer Address"), false)) then begin
                        Vendor.Address := "Repairer Address";
                        Vendor.Modify;
                    end else
                        "Repairer Address" := Vendor.Address;
                end;
            end;
        }
        field(17; "Repairer Address2"; Text[50])
        {
            Caption = 'Repairer Address2';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                TestField("Repairer No.");
                if ("Repairer Address2" <> xRec."Repairer Address2") then begin
                    Vendor.Get("Repairer No.");
                    if (Vendor."Address 2" <> "Repairer Address2") and
                      (Confirm(StrSubstNo(Text1060013,
                        Vendor."Address 2", "Repairer Address2"), false)) then begin
                        Vendor."Address 2" := "Repairer Address2";
                        Vendor.Modify;
                    end else
                        "Repairer Address2" := Vendor."Address 2";
                end;
            end;
        }
        field(18; "Repairer Post Code"; Code[20])
        {
            Caption = 'Repairer Post Code';
            TableRelation = "Post Code";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                PostCode: Record "Post Code";
                Vendor: Record Vendor;
            begin
                TestField("Repairer No.");
                if ("Repairer Post Code" <> xRec."Repairer Post Code") then begin
                    Vendor.Get("Repairer No.");
                    if (Vendor."Post Code" <> "Repairer Address2") and
                      (Confirm(StrSubstNo(Text1060014,
                        Vendor."Post Code", "Repairer Post Code"), false)) then begin
                        Vendor."Post Code" := "Repairer Post Code";
                        Vendor.Modify;
                    end else
                        "Repairer Post Code" := Vendor."Post Code";
                end;

                //-NPR5.27 [255580]
                //IF PostCode.GET("Repairer Post Code") THEN
                PostCode.SetRange(Code, "Repairer Post Code");
                if PostCode.FindFirst then
                    //+NPR5.27 [255580]
                    "Repairer City" := PostCode.City;
            end;
        }
        field(19; "Repairer City"; Text[30])
        {
            Caption = 'Repairer City';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                TestField("Repairer No.");
                if ("Repairer City" <> xRec."Repairer City") then begin
                    Vendor.Get("Repairer No.");
                    if (Vendor.City <> "Repairer City") and
                      (Confirm(StrSubstNo(Text1060015,
                        Vendor.City, "Repairer Post Code"), false)) then begin
                        Vendor.City := "Repairer City";
                        Vendor.Modify;
                    end else
                        "Repairer City" := Vendor.City;
                end;
            end;
        }
        field(20; "In-house Repairer"; Boolean)
        {
            Caption = 'In-house Repairer';
            DataClassification = CustomerContent;
        }
        field(21; "To Ship"; Boolean)
        {
            Caption = 'To Ship';
            DataClassification = CustomerContent;
        }
        field(22; "Prices Including VAT"; Decimal)
        {
            Caption = 'Prices Including VAT';
            DataClassification = CustomerContent;
        }
        field(23; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            DataClassification = CustomerContent;
        }
        field(24; Worranty; Boolean)
        {
            Caption = 'Guarantee';
            DataClassification = CustomerContent;
        }
        field(25; "Handed In Date"; Date)
        {
            Caption = 'Handed In Date';
            DataClassification = CustomerContent;
        }
        field(26; "Expected Completion Date"; Date)
        {
            Caption = 'Expected Completion Date';
            DataClassification = CustomerContent;
        }
        field(27; "Salesperson Code"; Code[10])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";
            DataClassification = CustomerContent;
        }
        field(28; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
        }
        field(29; "Alt. Telephone"; Code[20])
        {
            Caption = 'Alt. Telephone ';
            DataClassification = CustomerContent;
        }
        field(30; "Fax No."; Text[30])
        {
            Caption = 'Fax No.';
            DataClassification = CustomerContent;
        }
        field(31; "Contact after"; Time)
        {
            Caption = 'Contact After';
            DataClassification = CustomerContent;
        }
        field(32; Status; Option)
        {
            Caption = 'Status';
            InitValue = "To be sent";
            OptionCaption = 'At Vendor,Awaits Approval,Approved,Awaits Claiming,Return No Repair,Ready No Repair,Claimed,To be sent';
            OptionMembers = "At Vendor","Awaits Approval",Approved,"Awaits Claiming","Return No Repair","Ready No Repair",Claimed,"To be sent";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                RetailContractMgt: Codeunit "NPR Retail Contract Mgt.";
            begin
                //-NPR5.27 [255580]
                // "I-Comm".GET;
                // RetailSetup.GET;
                // IF ( "Mobile No." <> '' ) AND RetailSetup."Repair Msg." THEN BEGIN
                //  SMSMessage := STRSUBSTNO( "I-Comm"."Repair Message", "No.", Status );
                //  SMS.SendSMS( "Mobile No.", SMSMessage );
                // END;
                //+NPR5.27 [255580]

                //-NPR5.32 [276203]
                RetailSetup.Get;
                if (Status = Status::"Awaits Claiming") and RetailSetup."Repair Msg." then
                    RetailContractMgt.SendStatusSms(Rec);
                //+NPR5.32 [276203]
            end;
        }
        field(33; Brand; Text[50])
        {
            Caption = 'Brand';
            DataClassification = CustomerContent;
        }
        field(34; "Serial No."; Code[30])
        {
            Caption = 'Serial No.';
            DataClassification = CustomerContent;
        }
        field(35; "Alt. Serial No."; Code[30])
        {
            Caption = 'Alt. Serial No.';
            DataClassification = CustomerContent;
        }
        field(36; Accessories; Text[50])
        {
            Caption = 'Accessories';
            DataClassification = CustomerContent;
        }
        field(37; "Accessories 1"; Text[50])
        {
            Caption = 'Accessories 1';
            DataClassification = CustomerContent;
        }
        field(38; "Offer (more than LCY)"; Decimal)
        {
            Caption = 'Offer (more than LCY)';
            DataClassification = CustomerContent;
        }
        field(39; Delivered; Boolean)
        {
            Caption = 'Delivered';
            DataClassification = CustomerContent;
        }
        field(40; "Price when Not Accepted"; Decimal)
        {
            Caption = 'Price when Not Accepted';
            DataClassification = CustomerContent;
        }
        field(41; "Service nr."; Code[20])
        {
            Caption = 'Service No.';
            DataClassification = CustomerContent;
        }
        field(42; Type; Option)
        {
            Caption = 'Type';
            InitValue = "Vendor's Guarantee";
            OptionCaption = 'Offer,Our Gurantee,Vendor''s Guarantee,Fixed Price,To Repair,Maximum Price/Offer';
            OptionMembers = Offer,"Our Gurantee","Vendor's Guarantee","Fixed Price","To Repair","Maximum Price/Offer";
            DataClassification = CustomerContent;
        }
        field(43; "Customer Answer"; Date)
        {
            Caption = 'Customer Answer';
            DataClassification = CustomerContent;
        }
        field(44; "Approved by repairer"; Date)
        {
            Caption = 'Approved by Repairer';
            DataClassification = CustomerContent;
        }
        field(45; "Requested Returned, No Repair"; Date)
        {
            Caption = 'Requested Returned, No Repair';
            DataClassification = CustomerContent;
        }
        field(46; "Return from Repair"; Date)
        {
            Caption = 'Return from Repair';
            DataClassification = CustomerContent;
        }
        field(47; Claimed; Date)
        {
            Caption = 'Claimed';
            DataClassification = CustomerContent;
        }
        field(48; "Offer Sent"; Date)
        {
            Caption = 'Offer Sent';
            DataClassification = CustomerContent;
        }
        field(49; "Reported Ready and Sent"; Date)
        {
            Caption = 'Reported Ready and Sent';
            DataClassification = CustomerContent;
        }
        field(50; Deposit; Decimal)
        {
            Caption = 'Deposit';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(51; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            DataClassification = CustomerContent;
        }
        field(52; "Date Delivered"; Date)
        {
            Caption = 'Date Delivered';
            DataClassification = CustomerContent;
        }
        field(53; "Delivering Salespers."; Code[20])
        {
            Caption = 'Delivering Salespers.';
            DataClassification = CustomerContent;
        }
        field(54; "Delivering Sales Ticket No."; Code[20])
        {
            Caption = 'Delivering Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(55; "Contact Person"; Text[80])
        {
            Caption = 'Contact Person';
            DataClassification = CustomerContent;
        }
        field(56; Model; Text[50])
        {
            Caption = 'Model';
            DataClassification = CustomerContent;
        }
        field(57; "Delivered Register No."; Code[10])
        {
            Caption = 'Delivered Cash Register No.';
            DataClassification = CustomerContent;
        }
        field(58; "Audit Roll Line No."; Integer)
        {
            Caption = 'Audit Roll Line No.';
            DataClassification = CustomerContent;
        }
        field(59; "Audit Roll Trans. Type"; Integer)
        {
            Caption = 'Audit Roll Trans. Type';
            DataClassification = CustomerContent;
        }
        field(60; Register; Code[10])
        {
            Caption = 'Cash Register';
            DataClassification = CustomerContent;
        }
        field(61; Location; Code[10])
        {
            Caption = 'Location';
            TableRelation = Location.Code;
            DataClassification = CustomerContent;
        }
        field(100; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            Description = '---';
            DataClassification = CustomerContent;
        }
        field(105; "Picture Documentation1"; BLOB)
        {
            Caption = 'Picture Documentation1';
            SubType = Bitmap;
            DataClassification = CustomerContent;
        }
        field(106; "Picture Documentation2"; BLOB)
        {
            Caption = 'Picture Documentation2';
            SubType = Bitmap;
            DataClassification = CustomerContent;
        }
        field(107; "Picture Documentation3"; BLOB)
        {
            Caption = 'Picture Documentation3';
            DataClassification = CustomerContent;
        }
        field(108; Comment; Boolean)
        {
            CalcFormula = Exist("NPR Retail Comment" WHERE("Table ID" = CONST(6014504),
                                                        "No." = FIELD("No.")));
            Caption = 'Comment';
            FieldClass = FlowField;
        }
        field(109; "Customer Type"; Option)
        {
            Caption = 'Customer Type';
            OptionCaption = 'Ordinary,Cash';
            OptionMembers = Ordinary,Cash;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Validate("Customer No.", '');
            end;
        }
        field(110; "Mobile Phone No."; Code[20])
        {
            Caption = 'Mobile Phone No.';
            DataClassification = CustomerContent;
        }
        field(111; "E-mail"; Text[250])
        {
            Caption = 'E-mail';
            DataClassification = CustomerContent;
        }
        field(112; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                LookUpShortcutDimCode(1, "Global Dimension 1 Code");
            end;
        }
        field(113; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
        }
        field(114; "Costs Paid by Offer"; Boolean)
        {
            Caption = 'Costs Paid by Offer';
            DataClassification = CustomerContent;
        }
        field(115; "Delivery reff."; Code[20])
        {
            Caption = 'Delivery Reff.';
            DataClassification = CustomerContent;
        }
        field(116; "Global Dimension 2 Code"; Code[20])
        {
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                LookUpShortcutDimCode(2, "Global Dimension 2 Code");
            end;
        }
        field(117; "Warranty Text"; Text[100])
        {
            Caption = 'Warranty Text';
            DataClassification = CustomerContent;
        }
        field(120; Finalized; Boolean)
        {
            Caption = 'Finalized';
            Description = 'NPK70.00.01.01';
            DataClassification = CustomerContent;
        }
        field(125; "Picture Path 1"; Text[100])
        {
            Caption = 'Picture Path 1';
            Description = 'NPR5.26';
            DataClassification = CustomerContent;
        }
        field(130; "Picture Path 2"; Text[100])
        {
            Caption = 'Picture Path 2';
            Description = 'NPR5.26';
            DataClassification = CustomerContent;
        }
        field(140; "Related to Invoice No."; Code[20])
        {
            Caption = 'Related to Invoice No.';
            Description = 'NPR5.26';
            DataClassification = CustomerContent;
        }
        field(150; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
            Description = 'NPR5.27';
            DataClassification = CustomerContent;
        }
        field(160; "Bag No"; Text[50])
        {
            Caption = 'Bag No';
            DataClassification = CustomerContent;
        }
        field(165; "Primary key length"; Integer)
        {
            Caption = 'Primary Key Length';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Primary key length" := StrLen("No.");
            end;
        }
        field(170; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item."No.";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                //-NPR5.27
                if Item.Get("Item No.") then
                    "Item Description" := Item.Description;
                //+NPR5.27
            end;
        }
        field(175; "Customer Type1"; Option)
        {
            Caption = 'Customer Type1';
            Description = 'Field Added to replace Customer Radio Button';
            OptionCaption = ' ,Contact,Customer';
            OptionMembers = " ",Contact,Customer;
            DataClassification = CustomerContent;
        }
        field(5402; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(6060000; "Customer Internet number"; Integer)
        {
            Caption = 'Customer Internet Number';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; Status)
        {
        }
        key(Key3; "Primary key length")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
        POSUnit: Record "NPR POS Unit";
        RecRegister: Record "NPR Register";
        UserSetup: Record "User Setup";
    begin
        RetailSetup.Get;

        "Handed In Date" := Today;
        "Prices Including VAT" := RetailSetup."Fixed Price of Mending";
        "Price when Not Accepted" := RetailSetup."Fixed Price of Denied Mending";

        if "No." = '' then begin
            RetailSetup.TestField("Customer Repair Management");
            NoSeriesMgt.InitSeries(RetailSetup."Customer Repair Management", xRec."No. Series", 0D, "No.", "No. Series");
        end else begin
            NoSeriesMgt.TestManual(RetailSetup."Customer Repair Management");
        end;

        if UserSetup.Get(UserId) then begin
            if RecRegister.Get(UserSetup."NPR Backoffice Register No.") then begin
                Location := GetStoreLocationCode();
                POSUnit.Get(UserSetup."NPR Backoffice Register No.");
                "Global Dimension 1 Code" := POSUnit."Global Dimension 1 Code";
                "Global Dimension 2 Code" := POSUnit."Global Dimension 2 Code";
            end;
        end;
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today;
    end;

    var
        Text1060001: Label 'Do you want to change customer name from %1 to %2?';
        Text1060002: Label 'Do you want to change customer address from %1 to %2?';
        Text1060003: Label 'Do you want to change customer address 2 from %1 to %2?';
        Text1060004: Label 'Do you want to change customer post code from %1 to %2?';
        Text1060005: Label 'Do you want to change customer city  from %1 to %2?';
        Text1060006: Label 'Do you want to change debtor name from %1 to %2?';
        Text1060007: Label 'Do you want to change debtor address from %1 to %2?';
        Text1060008: Label 'Do you want to change debtor address 2 from %1 to %2?';
        Text1060009: Label 'Do you want to change debtor post code from %1 to %2?';
        Text1060010: Label 'Do you want to change debtor city from %1 to %2?';
        Text1060011: Label 'Do you want to change creditor name from %1 to %2?';
        Text1060012: Label 'Do you want to change creditor address from %1 to %2?';
        Text1060013: Label 'Do you want to change creditor address 2 from %1 to %2?';
        Text1060014: Label 'Do you want to change creditor post code from %1 to %2?';
        Text1060015: Label 'Do you want to change creditor city from %1 to %2?';
        Text1060020: Label 'For Repair : ';
        RetailSetup: Record "NPR Retail Setup";

    procedure AssistEdit(xCustomerRepair: Record "NPR Customer Repair"): Boolean
    var
        CustomerRepair: Record "NPR Customer Repair";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        with CustomerRepair do begin
            CustomerRepair := Rec;
            RetailSetup.Get;
            RetailSetup.TestField("Customer Repair Management");
            if NoSeriesMgt.SelectSeries(RetailSetup."Customer Repair Management", xCustomerRepair."No. Series", "No. Series") then begin
                //-NPR5.27 [255580]
                //RetailSetup.GET;
                //RetailSetup.TESTFIELD("Customer Repair Management");
                //+NPR5.27 [255580]
                NoSeriesMgt.SetSeries("No.");
                Rec := CustomerRepair;
                exit(true);
            end;
        end;
    end;

    procedure TransferFromAuditRoll(var AuditRoll: Record "NPR Audit Roll")
    begin
        //TransferFromAuditRoll()
        Status := Status::Claimed;
        "Date Delivered" := Today;
        "Delivering Salespers." := AuditRoll."Salesperson Code";
        "Delivering Sales Ticket No." := AuditRoll."Sales Ticket No.";
        "Delivered Register No." := AuditRoll."Register No.";
        "Audit Roll Line No." := AuditRoll."Line No.";
        "Audit Roll Trans. Type" := AuditRoll."Sale Type";
    end;

    procedure Navigate()
    var
        AuditRoll: Record "NPR Audit Roll";
        NavigatePage: Page Navigate;
    begin
        //Navigate()
        AuditRoll.SetRange("Register No.", "Delivered Register No.");
        AuditRoll.SetRange("Sales Ticket No.", "Delivering Sales Ticket No.");
        AuditRoll.SetRange("Sale Type", "Audit Roll Trans. Type");
        AuditRoll.SetRange("Line No.", "Audit Roll Line No.");
        AuditRoll.Find('-');
        NavigatePage.SetDoc("Date Delivered", AuditRoll."Posted Doc. No.");
        NavigatePage.Run;
    end;

    procedure LookUpShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        NprDimMgt: Codeunit "NPR Dimension Mgt.";
    begin
        RetailSetup.Get;
        if RetailSetup."Use Adv. dimensions" then
            NprDimMgt.LookupDimValueCode(FieldNumber, ShortcutDimCode);
    end;

    procedure CreateSalesDocument("Document Type": Enum "Sales Document Type")
    var
        TxtInvCreated: Label 'The invoice has been created on number %1';
        TxtOrderCreated: Label 'Salesorder is created with number %1';
        RetailContractSetup: Record "NPR Retail Contr. Setup";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesLine2: Record "Sales Line";
    begin
        //CreateInvoice()
        //-NPR5.26
        if "Related to Invoice No." = '' then begin
            //+NPR5.26
            if "Customer Type" = "Customer Type"::Cash then
                Validate("Customer Type", "Customer Type"::Ordinary);

            SalesHeader.Init;
            SalesHeader."Document Type" := "Document Type";
            SalesHeader.Insert(true);
            SalesHeader.Validate("Sell-to Customer No.", "Customer No.");
            SalesHeader."Salesperson Code" := "Salesperson Code";
            if Format("Expected Completion Date") <> '' then
                SalesHeader."Promised Delivery Date" := "Expected Completion Date";
            SalesHeader."External Document No." := "No.";
            SalesHeader.Modify;

            //-NPR5.27
            SalesLine2.Init;
            SalesLine2."Document Type" := SalesHeader."Document Type";
            SalesLine2."Document No." := SalesHeader."No.";
            SalesLine2."Line No." := 10000;
            SalesLine2.Description := Text1060020;
            SalesLine2.Insert(true);
            //+NPR5.27
            SalesLine.Init;
            SalesLine."Document Type" := SalesHeader."Document Type";
            SalesLine."Document No." := SalesHeader."No.";
            SalesLine."Line No." := 20000;
            SalesLine.Insert(true);
            //LineNo += 10000;
            RetailContractSetup.Get;
            SalesLine.Type := SalesLine.Type::Item;
            //-NPR5.26
            //IF  "Item No." = '' THEN
            //  SalesLine.VALIDATE( SalesLine."No.", PhotoSetup.Reparationsvarenummer )
            //ELSE
            //  SalesLine.VALIDATE( "No.", "Item No.");

            SalesLine.Validate(SalesLine."No.", RetailContractSetup."Repair Item No.");
            //+NPR5.26

            SalesLine.Validate("Sell-to Customer No.", "Customer No.");

            //-NPR5.27
            //IF  Brand <> '' THEN
            //  SalesLine.VALIDATE( SalesLine.Description,  Brand );
            //IF PhotoSetup.Reparationsvarenummer  <>'' THEN
            //  IF Item.GET(PhotoSetup.Reparationsvarenummer) THEN
            //    "Item Description" := Item.Description;
            SalesLine.Validate(SalesLine.Description, "Item Description");
            //-NPR5.27
            SalesLine.Validate(SalesLine.Quantity, 1);
            //-NPR5.30 [262923]
            if not SalesHeader."Prices Including VAT" then begin
                SalesLine.Validate(SalesLine."Unit Price", ("Prices Including VAT" * 100) / (100 + SalesLine."VAT %"));
            end else
                //+NPR5.30 [262923]
                SalesLine.Validate(SalesLine."Unit Price", "Prices Including VAT");
            SalesLine.Modify;

            //-NPR5.30 [262923]
            CreateSalesLine(SalesHeader, Rec);
            //+NPR5.30 [262923]

            Status := Status::Claimed;
            "Date Delivered" := Today;
            //-NPR5.26
            "Related to Invoice No." := SalesHeader."No.";
            //+NPR5.26

            case "Document Type" of
                "Document Type"::Invoice:
                    Message(TxtInvCreated, SalesHeader."No.");
                "Document Type"::Order:
                    Message(TxtOrderCreated, SalesHeader."No.");
            end;
            //-NPR5.26
        end;
        //+NPR5.26
    end;

    procedure PostItemPart(var CustRepair: Record "NPR Customer Repair")
    var
        ItemJnlLine: Record "Item Journal Line" temporary;
        CustRepairItemParts: Record "NPR Customer Repair Journal";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        Window: Dialog;
        LineNo: Integer;
    begin
        if CustRepair.Finalized = false then begin
            CustRepairItemParts.SetRange("Customer Repair No.", CustRepair."No.");
            CustRepairItemParts.SetFilter("Item Part No.", '<>%1', '');
            //-NPR5.26
            CustRepairItemParts.SetFilter(Quantity, '<>%1', 0);
            //+NPR5.26
            //-NPR5.30 [262923]
            CustRepairItemParts.SetRange("Expenses to be charged", false);
            //+NPR5.30 [262923]
            if CustRepairItemParts.FindSet then begin
                Window.Open('Processing Item #1#################################');
                repeat
                    LineNo += 10000;
                    Window.Update(1, StrSubstNo('%1', CustRepairItemParts."Item Part No."));
                    ItemJnlLine.Init;
                    ItemJnlLine.Validate("Posting Date", Today);
                    //-NPR5.26
                    if CustRepairItemParts.Quantity < 0 then
                        ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Positive Adjmt.")
                    else
                        ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Negative Adjmt.");
                    //+NPR5.26
                    ItemJnlLine.Validate("Document No.", CustRepairItemParts."Customer Repair No.");

                    ItemJnlLine.Validate("Item No.", CustRepairItemParts."Item Part No.");
                    ItemJnlLine.Validate(Quantity, CustRepairItemParts.Quantity);
                    //-NPR5.26
                    ItemJnlLine.Validate("Location Code", Location);
                    ItemJnlLine.Validate("Line No.", CustRepairItemParts."Line No.");
                    //+NPR5.26
                    ItemJnlPostLine.RunWithCheck(ItemJnlLine);
                    //-NPR5.26
                    CustRepairItemParts.Quantity := 0;
                    CustRepairItemParts.Modify();
                //+NPR5.26
                until CustRepairItemParts.Next = 0;
                Window.Close;
            end;
            //-NPR5.26
            CustRepair.Finalized := true;
            CustRepair.Modify;
            //+NPR5.26
        end;
    end;

    procedure PostItemPartWithoutFinalize(var CustRepair: Record "NPR Customer Repair")
    var
        ItemJnlLine: Record "Item Journal Line" temporary;
        CustRepairItemParts: Record "NPR Customer Repair Journal";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        Window: Dialog;
        LineNo: Integer;
    begin
        //-NPR5.26
        CustRepairItemParts.SetRange("Customer Repair No.", CustRepair."No.");
        CustRepairItemParts.SetFilter("Item Part No.", '<>%1', '');
        CustRepairItemParts.SetFilter(Quantity, '<>%1', 0);
        //-NPR5.30 [262923]
        CustRepairItemParts.SetRange("Expenses to be charged", false);
        //+NPR5.30 [262923]
        if CustRepairItemParts.FindSet then begin
            Window.Open('Processing Item #1#################################');
            repeat
                LineNo += 10000;
                Window.Update(1, StrSubstNo('%1', CustRepairItemParts."Item Part No."));
                ItemJnlLine.Init;
                ItemJnlLine.Validate("Posting Date", Today);
                if CustRepairItemParts.Quantity < 0 then
                    ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Positive Adjmt.")
                else
                    ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Negative Adjmt.");
                ItemJnlLine.Validate("Document No.", CustRepairItemParts."Customer Repair No.");
                ItemJnlLine.Validate("Item No.", CustRepairItemParts."Item Part No.");
                ItemJnlLine.Validate(Quantity, CustRepairItemParts.Quantity);
                ItemJnlLine.Validate("Location Code", Location);
                ItemJnlPostLine.RunWithCheck(ItemJnlLine);
                CustRepairItemParts.Quantity := 0;
                CustRepairItemParts.Modify();
            until CustRepairItemParts.Next = 0;
            Window.Close;
        end;
        //+NPR5.26
    end;

    procedure CreateSalesLine(SalesHeader: Record "Sales Header"; CustomerRepair: Record "NPR Customer Repair")
    var
        SalesLine: Record "Sales Line";
        CustomerRepairJournal: Record "NPR Customer Repair Journal";
        PhotoSetup: Record "NPR Retail Contr. Setup";
        LineNo: Integer;
    begin
        //-NPR5.30 [262923]
        LineNo := 20000;
        PhotoSetup.Get;
        CustomerRepairJournal.SetRange("Customer Repair No.", CustomerRepair."No.");
        CustomerRepairJournal.SetRange("Expenses to be charged", true);
        if CustomerRepairJournal.FindSet then
            repeat
                SalesLine.Init;
                LineNo += 10000;
                SalesLine.Validate("Document Type", SalesHeader."Document Type");
                SalesLine.Validate("Document No.", SalesHeader."No.");
                SalesLine.Validate("Line No.", LineNo);

                Clear(SalesLine.Type);
                if CustomerRepairJournal."Item Part No." <> '' then begin
                    SalesLine.Validate(Type, SalesLine.Type::Item);
                    SalesLine.Validate("No.", CustomerRepairJournal."Item Part No.");
                end;

                SalesLine.Insert(true);
                SalesLine.Validate("Variant Code", CustomerRepairJournal."Variant Code");
                SalesLine.Validate(Description, CustomerRepairJournal.Description);
                if CustomerRepairJournal.Quantity <> 0 then begin
                    SalesLine.Validate(Quantity, CustomerRepairJournal.Quantity);
                    if SalesHeader."Prices Including VAT" then
                        SalesLine.Validate("Unit Price", CustomerRepairJournal."Unit Price Excl. VAT" + CustomerRepairJournal."VAT Amount")
                    else
                        SalesLine.Validate(SalesLine."Unit Price", CustomerRepairJournal."Unit Price Excl. VAT");
                end;
                SalesLine.Modify;
            until CustomerRepairJournal.Next = 0;
        //+NPR5.30 [262923]
    end;

    local procedure GetStoreLocationCode(): Code[10]
    var
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSSetup: Codeunit "NPR POS Setup";
        POSStore: Record "NPR POS Store";
    begin
        if not POSSession.IsActiveSession(POSFrontEnd) then
            exit('');
        POSFrontEnd.GetSession(POSSession);
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSStore(POSStore);
        exit(POSStore."Location Code");
    end;
}

