table 6151401 "Magento Setup"
{
    // MAG1.17/MHA /20150611  CASE 216142 Object Created - Magento specific fields from NaviConnect Setup
    // MAG1.17/BHR /20150611  CASE 216108 Added field 430 "Exchange Web Code Pattern"
    // MAG1.20/TR  /20150810  CASE 218819 Field "Gift Voucher Activation" added.
    // MAG1.21/MHA /20151104  CASE 223835 Added field 35 "Variant Picture Dimension" and 37 "Picture Miniature"
    // MAG1.21/MHA /20151120  CASE 227734 WebVariant (OptionString 4) Deleted from Field 30 "Variant System"
    // MAG1.21/MHA /20151123  CASE 227354 Added Field 140 "Multistore Enabled"
    // MAG1.22/TS  /20150120  CASE 231762 Added Field Tickets Enabled
    // MAG1.22/TR  /20160414  CASE 238563 Added Field Custom Options Nos.
    // MAG1.22/MHA /20160418  CASE 230240 Added field 38 "Max. Picture Size"
    // MAG1.22/MHA /20160421  CASE 236917 Added inventory fields 50 "Inventory Location Filter" and 55 "Intercompany Inventory Enabled"
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.02/MHA /20170221  CASE 266871 Added field 517 "Customer Config. Template Code"
    // MAG2.03/MHA /20170316  CASE 267449 Added fields for replicating Special Price to Sales Price: 600 "Replicate to Sales Prices",605 "Replicate to Sales Type",610 "Replicate to Sales Code"
    // MAG2.03/MHA /20170425  CASE 267094 Added field 615 "Auto Seo Link Disabled"
    // MAG2.05/MHA /20170714  CASE 283777 Added field 77 "Api Authorization"
    // MAG2.08/MHA /20171011  CASE 292314 UpdateApi() is only invoked during "Magento Url".OnValidate()
    // MAG2.09/MHA /20171211  CASE 292576 Added fields 345 "Voucher Number Format" and 350 "Voucher Date Format"
    // MAG2.19/MHA /20190306  CASE 347974 Added field 535 "Release Order on Import"
    // MAG2.20/MHA /20190426  CASE 320423 Added field 15 "Magento Version"
    // MAG2.21/MHA /20190522  CASE 355271 Reworked OptionString for field 500 "Customer Mapping"
    // MAG2.22/MHA /20190611  CASE 357662 Added field 490 "Customer Update Mode"
    // MAG2.22/MHA /20190621  CASE 359146 Added field 540 "Use Blank Code for LCY"
    // MAG2.22/MHA /20190625  CASE 359285 Added field 34 "Picture Variety Type"
    // MAG2.22/MHA /20190625  CASE 359754 Added OptionValue "Customer No." to field 500 "Customer Mapping"
    // MAG2.22/MHA /20190708  CASE 352201 Added field 220 "Collect in Store Enabled"
    // MAG14.00.2.22/MHA/20190717  CASE 362262 Removed DotNet Print fields 340 "Gift Voucher Bitmap", 345 "Voucher Number Format", 350 "Voucher Date Format", 425 "Credit Voucher Bitmap"
    // MAG2.23/MHA /20190826  CASE 363864 Added fields 700 "Post Retail Voucher on Import", 710 "E-mail Retail Vouchers to"
    // MAG2.23/MHA /20190930  CASE 370831 B2B modules should be disabled for Magento 2 as Pull has been implemented via NAV Web Services
    // MAG2.23/MHA /20191011  CASE 371791 Added fields 720 "Post Tickets on Import", 730 "Post Memberships on Import"
    // MAG2.24/MHA /20191024  CASE 371807 Added Option "Phone No. to Customer No." to field 500 "Customer Mapping"
    // MAG2.25/MHA /20200204  CASE 387936 Added fields 750 "Send Order Confirmation", 760 "Order Conf. E-mail Template"
    // MAG2.26/MHA /20200428  CASE 402247 Added Option "Fixed" to field 490 "Customer Update Mode"
    // MAG2.26/MHA /20200430  CASE 402486 Added field 800 "Stock Calculation Method"
    // MAG2.26/MHA /20200505  CASE 402488 Added field 810 "Stock NpXml Template", 820 "Stock Codeunit Id", 830 "Stock Codeunit Name", 840 "Stock Function Name"
    // MAG2.26/MHA /20200526  CASE 406591 Added fields 850 "NpCs Workflow Code", 860 "NpCs From Store Code"

    Caption = 'Magento Setup';

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(10;"Magento Enabled";Boolean)
        {
            Caption = 'Magento Enabled';
        }
        field(15;"Magento Version";Option)
        {
            Caption = 'Magento Version';
            Description = 'MAG2.20';
            InitValue = "2";
            OptionCaption = '1,,,,,,,,,,2';
            OptionMembers = "1",,,,,,,,,,"2";

            trigger OnValidate()
            begin
                //-MAG2.20 [320423]
                if xRec."Magento Version" <> "Magento Version" then begin
                  "Api Url" := '';
                  UpdateApi();
                end;
                //+MAG2.20 [320423]
                //-MAG2.23 [370831]
                case "Magento Version" of
                  "Magento Version"::"2":
                    begin
                      "Customers Enabled" := false;
                      "Sales Prices Enabled" := false;
                      "Sales Line Discounts Enabled" := false;
                      "Item Disc. Group Enabled" := false;
                    end;
                end;
                //+MAG2.23 [370831]
            end;
        }
        field(20;"Magento Url";Text[250])
        {
            Caption = 'Magento Url';
            ExtendedDatatype = URL;

            trigger OnValidate()
            begin
                //-MAG1.21
                //IF ("Magento Url" <> '') AND ("Magento Url"[STRLEN("Magento Url")] <> '/') THEN
                //  "Magento Url" += '/';
                if "Magento Url" = '' then
                  exit;
                if "Magento Url"[StrLen("Magento Url")] = '/' then
                  exit;

                "Magento Url" += '/';
                //+MAG1.21
                //-MAG2.08 [292314]
                UpdateApi();
                //+MAG2.08 [292314]
            end;
        }
        field(30;"Variant System";Option)
        {
            Caption = 'Variant System';
            Description = 'MAG1.21,MAG2.00';
            OptionCaption = 'None,,Variety';
            OptionMembers = "None",,Variety;
        }
        field(34;"Picture Variety Type";Option)
        {
            Caption = 'Picture Variety Type';
            Description = 'MAG2.22';
            OptionCaption = 'Fixed,Select on Item,Variety 1,Variety 2,Variety 3,Variety 4';
            OptionMembers = "Fixed","Select on Item","Variety 1","Variety 2","Variety 3","Variety 4";
        }
        field(35;"Variant Picture Dimension";Code[10])
        {
            Caption = 'Variant Picture Dimension';
            Description = 'MAG1.21,MAG2.22';
            TableRelation = Variety;
        }
        field(37;"Miniature Picture";Option)
        {
            Caption = 'Miniature Picture';
            Description = 'MAG1.21';
            OptionCaption = 'None,Single Picture,Line Picture,Single Picture + Line Picture';
            OptionMembers = "None",SinglePicutre,LinePicture,"SinglePicture+LinePicture";
        }
        field(38;"Max. Picture Size";Integer)
        {
            Caption = 'Max. Picture Size (kb)';
            Description = 'MAG1.22';
            InitValue = 512;
        }
        field(40;"Generic Setup";BLOB)
        {
            Caption = 'Generic Setup';
        }
        field(50;"Inventory Location Filter";Text[100])
        {
            Caption = 'Inventory Location Filter';
            Description = 'MAG1.22';
            TableRelation = Location;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                //-MAG1.22
                "Inventory Location Filter" := UpperCase("Inventory Location Filter");
                //+MAG1.22
            end;
        }
        field(55;"Intercompany Inventory Enabled";Boolean)
        {
            Caption = 'Intercompany Inventory Enabled';
            Description = 'MAG1.22';

            trigger OnValidate()
            var
                MagentoInventoryCompany: Record "Magento Inventory Company";
            begin
                //-MAG1.22
                if "Intercompany Inventory Enabled" and not MagentoInventoryCompany.Get(CompanyName) then begin
                  MagentoInventoryCompany.Init;
                  MagentoInventoryCompany."Company Name" := CompanyName;
                  MagentoInventoryCompany."Location Filter" := "Inventory Location Filter";
                  MagentoInventoryCompany.Insert(true);
                end;
                //+MAG1.22
            end;
        }
        field(60;"Api Url";Text[250])
        {
            Caption = 'Api Url';
            Description = 'MAG2.00';
        }
        field(65;"Api Username Type";Option)
        {
            Caption = 'Api Username Type';
            Description = 'MAG2.00';
            OptionCaption = 'Automatic,Custom';
            OptionMembers = Automatic,Custom;
        }
        field(70;"Api Username";Text[250])
        {
            Caption = 'Api Username';
            Description = 'MAG2.00';
        }
        field(75;"Api Password";Text[250])
        {
            Caption = 'Api Password';
            Description = 'MAG2.00';
        }
        field(77;"Api Authorization";Text[100])
        {
            Caption = 'Api Authorization';
            Description = 'MAG2.05';
        }
        field(80;"Managed Nav Modules Enabled";Boolean)
        {
            Caption = 'Managed Nav Modules Enabled';
            Description = 'MAG2.00';
        }
        field(85;"Managed Nav Api Url";Text[250])
        {
            Caption = 'Managed Nav Api Url';
            Description = 'MAG2.00';
        }
        field(90;"Managed Nav Api Username";Text[100])
        {
            Caption = 'Managed Nav api brugernavn';
            Description = 'MAG2.00';
        }
        field(95;"Managed Nav Api Password";Text[100])
        {
            Caption = 'Managed Nav Api Password';
            Description = 'MAG2.00';
            ExtendedDatatype = Masked;
        }
        field(98;"Version No.";Text[50])
        {
            Caption = 'Version No.';
            Description = 'MAG2.00';
            Editable = false;
        }
        field(99;"Version Coverage";Text[50])
        {
            Caption = 'Version Coverage';
            Description = 'MAG2.00';
            Editable = false;
        }
        field(100;"Brands Enabled";Boolean)
        {
            Caption = 'Brands Enabled';
        }
        field(105;"Attributes Enabled";Boolean)
        {
            Caption = 'Attributes Enabled';
        }
        field(110;"Product Relations Enabled";Boolean)
        {
            Caption = 'Product Relations Enabled';
        }
        field(115;"Special Prices Enabled";Boolean)
        {
            Caption = 'Special Prices Enabled';
        }
        field(120;"Tier Prices Enabled";Boolean)
        {
            Caption = 'Tier Prices Enabled';
        }
        field(125;"Customer Group Prices Enabled";Boolean)
        {
            Caption = 'Customer Group Prices Enabled';
        }
        field(130;"Custom Options Enabled";Boolean)
        {
            Caption = 'Custom Options Enabled';
        }
        field(131;"Custom Options No. Series";Code[10])
        {
            Caption = 'Custom Options Nos.';
            Description = 'MAG1.22';
            TableRelation = "No. Series";
        }
        field(135;"Bundled Products Enabled";Boolean)
        {
            Caption = 'Bundled Products Enabled';
        }
        field(140;"Multistore Enabled";Boolean)
        {
            Caption = 'Multistore Enabled';
            Description = 'MAG1.21';
        }
        field(145;"Tickets Enabled";Boolean)
        {
            Caption = 'Tickets Enabled';
            Description = 'MAG1.22';
        }
        field(200;"Customers Enabled";Boolean)
        {
            Caption = 'Customers Enabled';
        }
        field(205;"Sales Prices Enabled";Boolean)
        {
            Caption = 'Sales Prices Enabled';
        }
        field(210;"Sales Line Discounts Enabled";Boolean)
        {
            Caption = 'Sales Line Discounts Enabled';
        }
        field(215;"Item Disc. Group Enabled";Boolean)
        {
            Caption = 'Item Disc. Group Enabled';
        }
        field(220;"Collect in Store Enabled";Boolean)
        {
            Caption = 'Collect in Store Enabled';
            Description = 'MAG2.22';
        }
        field(300;"Gift Voucher Enabled";Boolean)
        {
            Caption = 'Gift Voucher Enabled';
        }
        field(305;"Gift Voucher Item No.";Code[20])
        {
            Caption = 'Gift Voucher Item No.';
            TableRelation = Item;
        }
        field(310;"Gift Voucher Account No.";Code[20])
        {
            Caption = 'Gift Voucher Account No.';
            TableRelation = "G/L Account";
        }
        field(315;"Gift Voucher Report";Integer)
        {
            Caption = 'Gift Voucher Report';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Report));
        }
        field(320;"Gift Voucher Code Pattern";Code[20])
        {
            Caption = 'Gift Voucher Code Pattern';
        }
        field(330;"Gift Voucher Language Code";Code[20])
        {
            Caption = 'Gift Voucher Language Code';
            TableRelation = Language;
        }
        field(335;"Gift Voucher Valid Period";DateFormula)
        {
            Caption = 'Gift Voucher Validity';
        }
        field(400;"Credit Voucher Language Code";Code[10])
        {
            Caption = 'Credit Voucher Language Code';
        }
        field(405;"Credit Voucher Report";Integer)
        {
            Caption = 'Credit Voucher Report';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Report));
        }
        field(410;"Credit Voucher Valid Period";DateFormula)
        {
            Caption = 'Credit Voucher Valid Period';
        }
        field(415;"Credit Voucher Account No.";Code[20])
        {
            Caption = 'Credit Voucher Account No.';
            TableRelation = "G/L Account";
        }
        field(420;"Credit Voucher Code Pattern";Code[20])
        {
            Caption = 'Credit Voucher Code Pattern';
        }
        field(430;"Exchange Web Code Pattern";Code[20])
        {
            Caption = 'Exchange Web Code Pattern';
        }
        field(435;"Gift Voucher Activation";Option)
        {
            Caption = 'Activate Gift Voucher';
            Description = 'MAG1.20';
            OptionCaption = 'On Posting,On Insert';
            OptionMembers = OnPosting,OnInsert;
        }
        field(480;"Fixed Customer No.";Code[20])
        {
            Caption = 'Fixed Customer No.';
            Description = 'MAG2.26';
            TableRelation = Customer;
        }
        field(490;"Customer Update Mode";Option)
        {
            Caption = 'Customer Update Mode';
            Description = 'MAG2.22,MAG2.26';
            OptionCaption = 'Create and Update,Create,Update,None,Fixed';
            OptionMembers = "Create and Update",Create,Update,"None","Fixed";
        }
        field(500;"Customer Mapping";Option)
        {
            Caption = 'Customer Mapping';
            Description = 'MAG2.00,MAG2.21,MAG2.22,MAG2.24';
            OptionCaption = 'E-mail,Phone No.,E-mail AND Phone No.,E-mail OR Phone No.,Customer No.,Phone No. to Customer No.';
            OptionMembers = "E-mail","Phone No.","E-mail AND Phone No.","E-mail OR Phone No.","Customer No.","Phone No. to Customer No.";
        }
        field(505;"Customer Posting Group";Code[10])
        {
            Caption = 'Customer Posting Group';
            Description = 'MAG2.00';
            TableRelation = "Customer Posting Group";
        }
        field(515;"Customer Template Code";Code[10])
        {
            Caption = 'Customer Template Code';
            Description = 'MAG2.00';
            TableRelation = "Customer Template";
        }
        field(517;"Customer Config. Template Code";Code[10])
        {
            Caption = 'Customer Config. Template Code';
            Description = 'MAG2.02';
            TableRelation = "Config. Template Header".Code WHERE ("Table ID"=CONST(18));
        }
        field(520;"Payment Terms Code";Code[10])
        {
            Caption = 'Payment Terms Code';
            Description = 'MAG2.00';
            TableRelation = "Payment Terms";
        }
        field(525;"Payment Fee Account No.";Code[20])
        {
            Caption = 'Payment Fee Account No.';
            Description = 'MAG2.00';
            TableRelation = "G/L Account";
        }
        field(530;"Salesperson Code";Code[10])
        {
            Caption = 'Salesperson Code';
            Description = 'MAG2.00';
            TableRelation = "Salesperson/Purchaser";
        }
        field(535;"Release Order on Import";Boolean)
        {
            Caption = 'Release Order on Import';
            Description = 'MAG2.19';
        }
        field(540;"Use Blank Code for LCY";Boolean)
        {
            Caption = 'Use Blank Code for LCY';
            Description = 'MAG2.22';
        }
        field(600;"Replicate to Sales Prices";Boolean)
        {
            Caption = 'Replicate to Sales Prices';
            Description = 'MAG2.03';
        }
        field(605;"Replicate to Sales Type";Option)
        {
            Caption = 'Replicate to Sales Type';
            Description = 'MAG2.03';
            OptionCaption = 'Customer,Customer Price Group,All Customers,Campaign';
            OptionMembers = Customer,"Customer Price Group","All Customers",Campaign;

            trigger OnValidate()
            begin
                "Replicate to Sales Code" := '';
            end;
        }
        field(610;"Replicate to Sales Code";Code[20])
        {
            Caption = 'Replicate to Sales Code';
            Description = 'MAG2.03';
            TableRelation = IF ("Replicate to Sales Type"=CONST("Customer Price Group")) "Customer Price Group"
                            ELSE IF ("Replicate to Sales Type"=CONST(Customer)) Customer
                            ELSE IF ("Replicate to Sales Type"=CONST(Campaign)) Campaign;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                Campaign: Record Campaign;
                Cust: Record Customer;
                CustPriceGr: Record "Customer Price Group";
            begin
                if "Replicate to Sales Code" <> '' then
                  case "Replicate to Sales Type" of
                    "Replicate to Sales Type"::"Customer Price Group":
                      begin
                        CustPriceGr.Get("Replicate to Sales Code");
                      end;
                    "Replicate to Sales Type"::Customer:
                      begin
                        Cust.Get("Replicate to Sales Code");
                      end;
                    "Replicate to Sales Type"::Campaign:
                      begin
                        Campaign.Get("Replicate to Sales Code");
                      end;
                  end;
            end;
        }
        field(615;"Auto Seo Link Disabled";Boolean)
        {
            Caption = 'Auto Seo Link Disabled';
            Description = 'MAG2.03';
        }
        field(700;"Post Retail Vouchers on Import";Boolean)
        {
            Caption = 'Post Retail Vouchers on Import';
            Description = 'MAG2.23';
        }
        field(710;"E-mail Retail Vouchers to";Option)
        {
            Caption = 'E-mail Retail Vouchers to';
            Description = 'MAG2.23';
            OptionCaption = ' ,Bill-to Customer';
            OptionMembers = " ","Bill-to Customer";
        }
        field(720;"Post Tickets on Import";Boolean)
        {
            Caption = 'Post Tickets on Import';
            Description = 'MAG2.23';
        }
        field(730;"Post Memberships on Import";Boolean)
        {
            Caption = 'Post Memberships on Import';
            Description = 'MAG2.23';
        }
        field(750;"Send Order Confirmation";Boolean)
        {
            Caption = 'Send Order Confirmation';
            Description = 'MAG2.25';

            trigger OnValidate()
            begin
                //-MAG2.25 [387936]
                "Release Order on Import" := true;
                //+MAG2.25 [387936]
            end;
        }
        field(760;"E-mail Template (Order Conf.)";Code[20])
        {
            Caption = 'E-mail Template (Order Confirmation)';
            Description = 'MAG2.25';
            TableRelation = "E-mail Template Header" WHERE ("Table No."=CONST(36));
        }
        field(800;"Stock Calculation Method";Option)
        {
            Caption = 'Stock Calculation Method';
            Description = 'MAG2.26';
            OptionCaption = 'Standard,Function';
            OptionMembers = Standard,"Function";
        }
        field(810;"Stock NpXml Template";Code[20])
        {
            Caption = 'Stock NpXml Template';
            Description = 'MAG2.26';
            TableRelation = "NpXml Template" WHERE ("Table No."=CONST(27),
                                                    "Xml Root Name"=CONST('stock_updates'));
        }
        field(820;"Stock Codeunit Id";Integer)
        {
            BlankZero = true;
            Caption = 'Stock Codeunit Id';
            Description = 'MAG2.26';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Codeunit));
        }
        field(830;"Stock Codeunit Name";Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE ("Object Type"=CONST(Codeunit),
                                                             "Object ID"=FIELD("Stock Codeunit Id")));
            Caption = 'Stock Codeunit Name';
            Description = 'MAG2.26';
            Editable = false;
            FieldClass = FlowField;
        }
        field(840;"Stock Function Name";Text[250])
        {
            Caption = 'Stock Function Name';
            Description = 'MAG2.26';

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //-MAG2.26 [402488]
                EventSubscription.SetRange("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID",GetStockPublisherCodeunitId());
                EventSubscription.SetRange("Published Function",GetStockPublisherFunctionName());
                if PAGE.RunModal(PAGE::"Event Subscriptions",EventSubscription) <> ACTION::LookupOK then
                  exit;

                "Stock Codeunit Id" := EventSubscription."Subscriber Codeunit ID";
                "Stock Function Name" := EventSubscription."Subscriber Function";
                //+MAG2.26 [402488]
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //-MAG2.26 [402488]
                if "Stock Function Name" = '' then begin
                  "Stock Codeunit Id" := 0;
                  exit;
                end;

                EventSubscription.SetRange("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID",GetStockPublisherCodeunitId());
                EventSubscription.SetRange("Published Function",GetStockPublisherFunctionName());
                if "Stock Codeunit Id" > 0 then
                  EventSubscription.SetRange("Subscriber Codeunit ID","Stock Codeunit Id");
                if "Stock Function Name" <> '' then
                  EventSubscription.SetFilter("Subscriber Function",'@*' + "Stock Function Name" + '*');
                EventSubscription.FindFirst;

                "Stock Codeunit Id" := EventSubscription."Subscriber Codeunit ID";
                "Stock Function Name" := EventSubscription."Subscriber Function";
                //+MAG2.26 [402488]
            end;
        }
        field(850;"NpCs Workflow Code";Code[20])
        {
            Caption = 'Collect in Store Workflow Code';
            Description = 'MAG2.26';
            TableRelation = "NpCs Workflow";
        }
        field(860;"NpCs From Store Code";Code[20])
        {
            Caption = 'From Collect Store Code';
            Description = 'MAG2.26';
            TableRelation = "NpCs Store" WHERE ("Local Store"=CONST(true));

            trigger OnLookup()
            var
                NpCsStore: Record "NpCs Store";
            begin
                //-MAG2.26 [406591]
                NpCsStore.SetRange("Local Store",true);
                NpCsStore.SetFilter("Location Code","Inventory Location Filter");
                if PAGE.RunModal(0,NpCsStore) = ACTION::LookupOK then
                  Validate("NpCs From Store Code",NpCsStore.Code);
                //+MAG2.26 [406591]
            end;

            trigger OnValidate()
            var
                NpCsStoreWorkflowRelation: Record "NpCs Store Workflow Relation";
            begin
                //-MAG2.26 [406591]
                if "NpCs From Store Code" = '' then
                  exit;

                NpCsStoreWorkflowRelation.SetRange("Store Code");
                if NpCsStoreWorkflowRelation.FindFirst then
                  Validate("NpCs Workflow Code",NpCsStoreWorkflowRelation."Workflow Code");
                //+MAG2.26 [406591]
            end;
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
        //-MAG2.08 [292314]
        //UpdateApi();
        //+MAG2.08 [292314]
    end;

    trigger OnModify()
    begin
        //-MAG2.08 [292314]
        //UpdateApi();
        //+MAG2.08 [292314]
    end;

    procedure GetApiUsername(): Text[250]
    var
        NpXmlMgt: Codeunit "NpXml Mgt.";
    begin
        //-MAG2.00
        case "Api Username Type" of
          "Api Username Type"::Automatic:
            begin
              exit(NpXmlMgt.GetAutomaticUsername());
            end;
          else
            exit("Api Username");
        end;
        //+MAG2.00
    end;

    local procedure UpdateApi()
    var
        FormsAuthentication: DotNet npNetFormsAuthentication;
    begin
        //-MAG2.20 [320423]
        case "Magento Version" of
          "Magento Version"::"2":
            begin
              "Api Url" := "Magento Url" + 'rest/all/V1/naviconnect/';
              exit;
            end;
        end;
        //+MAG2.20 [320423]
        //-MAG2.00
        "Api Url" := "Magento Url" + 'api/rest/naviconnect/';
        if "Api Password" = '' then
          "Api Password" := FormsAuthentication.HashPasswordForStoringInConfigFile(Format(CurrentDateTime,0,9),'MD5');
        //+MAG2.00
    end;

    procedure GetBasicAuthInfo(): Text
    var
        Convert: DotNet npNetConvert;
        Encoding: DotNet npNetEncoding;
    begin
        //-MAG2.00
        exit(Convert.ToBase64String(Encoding.UTF8.GetBytes(GetApiUsername() + ':' + "Api Password")));
        //+MAG2.00
    end;

    procedure GetCredentialsHash(): Text
    var
        FormsAuthentication: DotNet npNetFormsAuthentication;
    begin
        //-MAG2.00
        exit(LowerCase(FormsAuthentication.HashPasswordForStoringInConfigFile(GetApiUsername() + "Api Password" + 'D3W7k5pd7Pn64ctn25ng91ZkSvyDnjo2','MD5')));
        //+MAG2.00
    end;

    local procedure GetStockPublisherCodeunitId(): Integer
    begin
        //-MAG2.26 [402488]
        exit(CODEUNIT::"Magento Item Mgt.");
        //+MAG2.26 [402488]
    end;

    local procedure GetStockPublisherFunctionName(): Text
    begin
        //-MAG2.26 [402488]
        exit('OnCalcStockQty');
        //+MAG2.26 [402488]
    end;
}

