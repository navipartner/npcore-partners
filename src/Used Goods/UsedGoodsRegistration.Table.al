table 6014500 "NPR Used Goods Registration"
{
    // NPR4.10/TSA/20150518 CASE 213150  removed Serial No.=FIELD(Serienummer))) from F41 Beholdning flowfilter
    // NPR5.26/TS/20160726 CASE 246761 Added Code to populate purchase date on Insert and field Location Code
    // NPR5.26/TS/20161130  CASE 246761 Rename Variables from danish to English and new features
    // NPR5.30/TJ  /20170223  CASE 264913 Added code that fills customer fields through Config. Template Header
    // NPR5.39/TJ  /20180212  CASE 302634 Renamed OptionString property of field 25 Identification to english
    // NPR5.39/JDH /20180220  CASE 305746 Name, Address and Address 2 Extended to 50
    // NPR5.43/RA  /20180419  CASE 311886 On field 45 added option "B+"
    // NPR5.53/BHR /20191008  CASE 369354 Removed Code For Customer Creation

    Caption = 'Used Goods Registration';
    LookupPageID = "NPR Used Goods Reg. List";

    fields
    {
        field(1; "No."; Code[10])
        {
            Caption = 'No.';

            trigger OnValidate()
            var
                NoSeriesManagement: Codeunit NoSeriesManagement;
            begin
                if "No." <> xRec."No." then begin
                    NoSeriesManagement.TestManual("No.");
                    Nummerserie := '';
                end;
            end;
        }
        field(2; "Purchase Date"; Date)
        {
            Caption = 'Purchase Date';
        }
        field(3; Subject; Text[30])
        {
            Caption = 'Subject';

            trigger OnValidate()
            begin
                //-NPR5.26
                "Search Name" := Subject;
                //-NPR5.26
            end;
        }
        field(4; Description; Text[30])
        {
            Caption = 'Subject Description';

            trigger OnValidate()
            begin
                "Search Name" := Description;
            end;
        }
        field(5; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
        }
        field(6; Paid; Option)
        {
            Caption = 'Paid';
            OptionCaption = ' ,Check,Cash,Exchange';
            OptionMembers = " ",Check,Kontant,Bytte;
        }
        field(7; "Check Number"; Code[20])
        {
            Caption = 'Check Number';
        }
        field(20; "Purchased By Customer No."; Code[20])
        {
            Caption = 'Purchase Customer No.';
            TableRelation = Customer;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                Customer: Record Customer;
                RetailSetup: Record "NPR Retail Setup";
                SalespersonPurchaser: Record "Salesperson/Purchaser";
            begin
                //-NPR5.53 [369354]
                // RetailSetup.GET();
                // IF NOT Customer.GET("Purchased By Customer No.") THEN BEGIN
                //  IF RetailSetup."Create New Customer" THEN BEGIN
                //    CASE RetailSetup."New Customer Creation" OF
                //      RetailSetup."New Customer Creation"::"2" :
                //        BEGIN
                //          Customer."No." := "Purchased By Customer No.";
                //          Customer.Type    := Customer.Type::Cash;
                //          Customer.INSERT;
                //        END;
                //      RetailSetup."New Customer Creation"::"3":
                //        BEGIN
                //          Customer."No." := "Purchased By Customer No.";
                //          Customer.Type    := Customer.Type::Customer;
                //
                //          //-NPR5.30 [264913]
                //          {
                //          Customer."Payment Terms Code" := RetailSetup."Terms of Payment";
                //          Customer.VALIDATE("Gen. Bus. Posting Group",RetailSetup."Gen. Bus. Posting Group");
                //          Customer.VALIDATE("Customer Posting Group",RetailSetup."Customer Posting Group");
                //          }
                //          ApplyCustomerConfigTemplate(RetailSetup."Customer Config. Template",Customer);
                //          //+NPR5.30 [264913]
                //
                //          Customer.INSERT;
                //        END;
                //      RetailSetup."New Customer Creation"::"1":
                //        BEGIN
                //          SalespersonPurchaser.GET("Salesperson Code");
                //          CASE SalespersonPurchaser."Customer Creation" OF
                //            SalespersonPurchaser."Customer Creation"::"0" :
                //              ERROR(Text1060003);
                //            SalespersonPurchaser."Customer Creation"::"1" :
                //              BEGIN
                //                Customer."No." := "Purchased By Customer No.";
                //                Customer.Type    := Customer.Type::Cash;
                //                Customer.INSERT;
                //              END;
                //            SalespersonPurchaser."Customer Creation"::"2" :
                //              BEGIN
                //                Customer."No." := "Purchased By Customer No.";
                //                Customer.Type := Customer.Type::Customer;
                //
                //                //-NPR5.30 [264913]
                //                {
                //                Customer."Payment Terms Code" := RetailSetup."Terms of Payment";
                //                Customer.VALIDATE("Gen. Bus. Posting Group",RetailSetup."Gen. Bus. Posting Group");
                //                Customer.VALIDATE("Customer Posting Group",RetailSetup."Customer Posting Group");
                //                }
                //                ApplyCustomerConfigTemplate(RetailSetup."Customer Config. Template",Customer);
                //                //+NPR5.30 [264913]
                //
                //                Customer.INSERT;
                //              END;
                //          END;
                //        END;
                //    END;
                //    COMMIT;
                //    //-NPR5.26
                //    //Aktion := PAGE.RUNMODAL(PAGE::"Phone No lookup",Customer);
                //    //IF (Aktion = ACTION::OK) THEN BEGIN
                //    IF PAGE.RUNMODAL(PAGE::"Customer List",Customer) = ACTION::LookupOK THEN BEGIN
                //    //+NPR5.26
                //      "Purchased By Customer No." := Customer."No.";
                //      Name := Customer.Name;
                //      Address := Customer.Address;
                //      "Address 2" := Customer."Address 2";
                //      VALIDATE("Post Code",Customer."Post Code");
                //      //-NPR5.26
                //      By := Customer.City
                //      //+NPR5.26
                //    END ELSE BEGIN
                //      "Purchased By Customer No." := '';
                //      IF Customer."No." <> '' THEN
                //        IF CONFIRM(STRSUBSTNO(Text1060004,Customer."No.",Customer.Name),TRUE) THEN
                //          Customer.DELETE;
                //    END;
                //  END ELSE
                //    ERROR(Text1060005);
                // END ELSE BEGIN
                //  Name := Customer.Name;
                //  Address := Customer.Address;
                //  "Address 2" := Customer."Address 2";
                //  VALIDATE("Post Code",Customer."Post Code");
                //  //-NPR5.26
                //  By := Customer.City
                //  //+NPR5.26
                // END;


                if Customer.Get("Purchased By Customer No.") then begin
                    Name := Customer.Name;
                    Address := Customer.Address;
                    "Address 2" := Customer."Address 2";
                    Validate("Post Code", Customer."Post Code");
                    By := Customer.City;
                end;
                //+NPR5.53 [369354]
            end;
        }
        field(21; Name; Text[50])
        {
            Caption = 'Name';
        }
        field(22; Address; Text[50])
        {
            Caption = 'Address';
        }
        field(23; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
        }
        field(24; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            TableRelation = "Post Code";

            trigger OnValidate()
            var
                PostCode: Record "Post Code";
            begin
                if PostCode.Get("Post Code") then
                    By := PostCode.City;
            end;
        }
        field(25; Identification; Option)
        {
            Caption = 'ID Card';
            OptionCaption = ' ,Driver''s Licence,Passport,Credit Card,Other';
            OptionMembers = " ","Driver's Licence",Passport,"Credit Card",Other;
        }
        field(26; "CPR No."; Code[11])
        {
            Caption = 'Social Security No.';
        }
        field(27; "Identification Number"; Code[20])
        {
            Caption = 'Legitimation No.';
        }
        field(28; "Fax til Kostercentralen"; Boolean)
        {
            Caption = 'Fax to Kostercentralen';
            Editable = false;
        }
        field(29; "Subject Sold Date"; Date)
        {
            Caption = 'Subject Sold Date';
            Editable = false;
        }
        field(30; "Sales Ticket No./Invoice No."; Code[10])
        {
            Caption = 'On Sales Ticket No./Invoice';
            Editable = false;
        }
        field(31; "Item No. Created"; Code[20])
        {
            Caption = 'Generated Item No.';
            Editable = false;
            TableRelation = Item;
        }
        field(32; "Kostercentralen Registered"; Date)
        {
            Caption = 'Kostercentralen Registered Date';
            Editable = false;
        }
        field(33; Blocked; Boolean)
        {
            Caption = 'Blocked';

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if "Item No. Created" <> '' then begin
                    Item.Get("Item No. Created");
                    Item.Validate(Blocked, Blocked);
                    Item.Modify(true);
                end;
            end;
        }
        field(34; Puljemomsordning; Boolean)
        {
            Caption = 'Pool  VAT System';
            InitValue = true;
        }
        field(35; "Relation til faktura"; Code[10])
        {
            Caption = 'Relation to Invoice';
        }
        field(36; "Salgspris inkl. Moms"; Decimal)
        {
            Caption = 'Unit Price Including VAT';
        }
        field(37; Nummerserie; Code[20])
        {
            Caption = 'No. Series';
        }
        field(38; By; Code[30])
        {
            Caption = 'City';
        }
        field(39; Serienummer; Code[50])
        {
            Caption = 'Serial No.';
        }
        field(40; "Salesperson Code"; Code[10])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(41; Beholdning; Decimal)
        {
            CalcFormula = Sum ("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("Item No. Created")));
            Caption = 'Inventory';
            Editable = false;
            FieldClass = FlowField;
        }
        field(42; Link; Code[10])
        {
            Caption = 'Link';
        }
        field(43; "Brugtvare lagermetode"; Option)
        {
            Caption = 'Used Goods Inventory Method';
            OptionCaption = 'FIFO,LIFO,Serial No.,Avarage,Standard';
            OptionMembers = FIFO,LIFO,Serienummer,Gennemsnit,Standard;
        }
        field(44; "Item Group No."; Code[10])
        {
            Caption = 'Belongs in Item Group No.';
            TableRelation = "NPR Item Group" WHERE("Used Goods Group" = CONST(true),
                                                "Main Item Group" = CONST(false));
        }
        field(45; Stand; Option)
        {
            Caption = 'Condition';
            OptionCaption = 'New,Mint,Mint boxed,A,B,C,D,E,F,B+';
            OptionMembers = New,Mint,"Mint boxed",A,B,C,D,E,F,"B+";
        }
        field(46; "Search Name"; Text[30])
        {
            Caption = 'Search Name';
        }
        field(47; "Rettet den"; Date)
        {
            Caption = 'Edited Date';
        }
        field(50; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            Description = 'NPR5.26';
            InitValue = '1';
            TableRelation = Location;
        }
        field(55; Status; Option)
        {
            Caption = 'Status';
            Description = 'NPR5.26';
            OptionCaption = 'MainPost,SinglePost,SubPost';
            OptionMembers = MainPost,SinglePost,SubPost;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            SumIndexFields = "Unit Cost";
        }
        key(Key2; "Item No. Created")
        {
        }
        key(Key3; Link)
        {
            SumIndexFields = "Unit Cost";
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        Error(Text1060001);
    end;

    trigger OnInsert()
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
        RetailSetup: Record "NPR Retail Setup";
    begin
        if "No." = '' then begin
            RetailSetup.Get;
            RetailSetup.TestField("Used Goods No. Management");
            NoSeriesManagement.InitSeries(RetailSetup."Used Goods No. Management", xRec.Nummerserie, 0D, "No.", Nummerserie);
        end;
        //-NPR5.26
        "Purchase Date" := Today;
        //+NPR5.26
        //-NPR5.26
        Link := "No.";
        //-NPR5.26
    end;

    trigger OnModify()
    begin
        /*IF "Kostercentralen Registreret d." <> 0D THEN ERROR(Text1060000);*/
        "Rettet den" := Today;

    end;

    trigger OnRename()
    begin
        Error(Text1060002);
    end;

    var
        Text1060000: Label 'Registered items cannot be changed!';
        Text1060001: Label 'Used Goods cannot be deleted because of No. Series Management!';
        Text1060002: Label 'Used Goods cannot be renamed because of No. Series Management!';
        Text1060003: Label 'You are not permitted to enter customers! Contact the system administrator.';
        Text1060004: Label 'Do you want to delete customer no. %1/name %2?';
        Text1060005: Label 'You cannot enter debtors in this window!';

    procedure Assistedit(UsedGoodsRegistration: Record "NPR Used Goods Registration"): Boolean
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
        RetailSetup: Record "NPR Retail Setup";
    begin
        with UsedGoodsRegistration do begin
            UsedGoodsRegistration := Rec;
            RetailSetup.Get;
            RetailSetup.TestField("Used Goods No. Management");
            if NoSeriesManagement.SelectSeries(RetailSetup."Used Goods No. Management", UsedGoodsRegistration.Nummerserie, Nummerserie) then begin
                RetailSetup.TestField("Used Goods No. Management");
                NoSeriesManagement.SetSeries("No.");
                Rec := UsedGoodsRegistration;
                exit(true);
            end;
        end;
    end;

    local procedure ApplyCustomerConfigTemplate(CustomerConfigTemplate: Code[10]; var Customer: Record Customer)
    var
        TempCustomer: Record Customer temporary;
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        RecRef: RecordRef;
        ConfigTemplateHeader: Record "Config. Template Header";
    begin
        if CustomerConfigTemplate = '' then
            exit;
        ConfigTemplateHeader.Get(CustomerConfigTemplate);
        TempCustomer := Customer;
        TempCustomer.Insert;
        RecRef.GetTable(TempCustomer);
        ConfigTemplateMgt.ApplyTemplateLinesWithoutValidation(ConfigTemplateHeader, RecRef);
        RecRef.SetTable(TempCustomer);
        Customer."Payment Terms Code" := TempCustomer."Payment Terms Code";
        Customer.Validate("Gen. Bus. Posting Group", TempCustomer."Gen. Bus. Posting Group");
        Customer.Validate("Customer Posting Group", TempCustomer."Customer Posting Group");
    end;
}

