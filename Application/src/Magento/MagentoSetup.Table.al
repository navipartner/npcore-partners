table 6151401 "NPR Magento Setup"
{
    Caption = 'Magento Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Magento Enabled"; Boolean)
        {
            Caption = 'Magento Enabled';
            DataClassification = CustomerContent;
        }
        field(15; "Magento Version"; Enum "NPR Magento Version")
        {
            Caption = 'Magento Version';
            DataClassification = CustomerContent;
            InitValue = "2";

            trigger OnValidate()
            begin
                if xRec."Magento Version" <> "Magento Version" then begin
                    "Api Url" := '';
                    UpdateApi();
                end;
                case "Magento Version" of
                    "Magento Version"::"2":
                        begin
                            "Customers Enabled" := false;
                            "Sales Prices Enabled" := false;
                            "Sales Line Discounts Enabled" := false;
                            "Item Disc. Group Enabled" := false;
                        end;
                end;
            end;
        }
        field(20; "Magento Url"; Text[250])
        {
            Caption = 'Magento Url';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;

            trigger OnValidate()
            begin
                if "Magento Url" = '' then
                    exit;
                if "Magento Url"[StrLen("Magento Url")] = '/' then
                    exit;

                "Magento Url" += '/';
                UpdateApi();
            end;
        }
        field(30; "Variant System"; Enum "NPR Magento Variant System")
        {
            Caption = 'Variant System';
            DataClassification = CustomerContent;
        }
        field(34; "Picture Variety Type"; Enum "NPR Magento Pic. Variety Type")
        {
            Caption = 'Picture Variety Type';
            DataClassification = CustomerContent;
        }
        field(35; "Variant Picture Dimension"; Code[10])
        {
            Caption = 'Variant Picture Dimension';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety";
        }
        field(37; "Miniature Picture"; Enum "NPR Magento Miniature Picture")
        {
            Caption = 'Miniature Picture';
            DataClassification = CustomerContent;
        }
        field(38; "Max. Picture Size"; Integer)
        {
            Caption = 'Max. Picture Size (kb)';
            DataClassification = CustomerContent;
            InitValue = 512;
        }
        field(40; "Generic Setup"; BLOB)
        {
            Caption = 'Generic Setup';
            DataClassification = CustomerContent;
        }
        field(50; "Inventory Location Filter"; Text[100])
        {
            Caption = 'Inventory Location Filter';
            DataClassification = CustomerContent;
            TableRelation = Location;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                "Inventory Location Filter" := UpperCase("Inventory Location Filter");
            end;
        }
        field(55; "Intercompany Inventory Enabled"; Boolean)
        {
            Caption = 'Intercompany Inventory Enabled';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                MagentoInventoryCompany: Record "NPR Magento Inv. Company";
            begin
                if "Intercompany Inventory Enabled" and not MagentoInventoryCompany.Get(CompanyName) then begin
                    MagentoInventoryCompany.Init;
                    MagentoInventoryCompany."Company Name" := CompanyName;
                    MagentoInventoryCompany."Location Filter" := "Inventory Location Filter";
                    MagentoInventoryCompany.Insert(true);
                end;
            end;
        }
        field(60; "Api Url"; Text[250])
        {
            Caption = 'Api Url';
            DataClassification = CustomerContent;
        }
        field(65; "Api Username Type"; Enum "NPR Magento Api Username Type")
        {
            Caption = 'Api Username Type';
            DataClassification = CustomerContent;
        }
        field(70; "Api Username"; Text[250])
        {
            Caption = 'Api Username';
            DataClassification = CustomerContent;
        }
        field(75; "Api Password"; Text[250])
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'IsolatedStorage is in use.';
            Caption = 'Api Password';
            DataClassification = CustomerContent;
        }
        field(76; "Api Password Key"; Guid)
        {
            Caption = 'Api Password Key';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(77; "Api Authorization"; Text[100])
        {
            Caption = 'Api Authorization';
            DataClassification = CustomerContent;
        }
        field(80; "Managed Nav Modules Enabled"; Boolean)
        {
            Caption = 'Managed Nav Modules Enabled';
            DataClassification = CustomerContent;
        }
        field(85; "Managed Nav Api Url"; Text[250])
        {
            Caption = 'Managed Nav Api Url';
            DataClassification = CustomerContent;
        }
        field(90; "Managed Nav Api Username"; Text[100])
        {
            Caption = 'Managed Nav api brugernavn';
            DataClassification = CustomerContent;
        }
        field(95; "Managed Nav Api Password"; Text[100])
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'IsolatedStorage is in use.';
            Caption = 'Managed Nav Api Password';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(96; "Managed Nav Api Password Key"; Guid)
        {
            Caption = 'Managed Nav Api Password Key';
            DataClassification = CustomerContent;
        }
        field(98; "Version No."; Text[50])
        {
            Caption = 'Version No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(99; "Version Coverage"; Text[50])
        {
            Caption = 'Version Coverage';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(100; "Brands Enabled"; Boolean)
        {
            Caption = 'Brands Enabled';
            DataClassification = CustomerContent;
        }
        field(105; "Attributes Enabled"; Boolean)
        {
            Caption = 'Attributes Enabled';
            DataClassification = CustomerContent;
        }
        field(110; "Product Relations Enabled"; Boolean)
        {
            Caption = 'Product Relations Enabled';
            DataClassification = CustomerContent;
        }
        field(115; "Special Prices Enabled"; Boolean)
        {
            Caption = 'Special Prices Enabled';
            DataClassification = CustomerContent;
        }
        field(120; "Tier Prices Enabled"; Boolean)
        {
            Caption = 'Tier Prices Enabled';
            DataClassification = CustomerContent;
        }
        field(125; "Customer Group Prices Enabled"; Boolean)
        {
            Caption = 'Customer Group Prices Enabled';
            DataClassification = CustomerContent;
        }
        field(130; "Custom Options Enabled"; Boolean)
        {
            Caption = 'Custom Options Enabled';
            DataClassification = CustomerContent;
        }
        field(131; "Custom Options No. Series"; Code[20])
        {
            Caption = 'Custom Options Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(135; "Bundled Products Enabled"; Boolean)
        {
            Caption = 'Bundled Products Enabled';
            DataClassification = CustomerContent;
        }
        field(140; "Multistore Enabled"; Boolean)
        {
            Caption = 'Multistore Enabled';
            DataClassification = CustomerContent;
        }
        field(145; "Tickets Enabled"; Boolean)
        {
            Caption = 'Tickets Enabled';
            DataClassification = CustomerContent;
        }
        field(200; "Customers Enabled"; Boolean)
        {
            Caption = 'Customers Enabled';
            DataClassification = CustomerContent;
        }
        field(205; "Sales Prices Enabled"; Boolean)
        {
            Caption = 'Sales Prices Enabled';
            DataClassification = CustomerContent;
        }
        field(210; "Sales Line Discounts Enabled"; Boolean)
        {
            Caption = 'Sales Line Discounts Enabled';
            DataClassification = CustomerContent;
        }
        field(215; "Item Disc. Group Enabled"; Boolean)
        {
            Caption = 'Item Disc. Group Enabled';
            DataClassification = CustomerContent;
        }
        field(220; "Collect in Store Enabled"; Boolean)
        {
            Caption = 'Collect in Store Enabled';
            DataClassification = CustomerContent;
        }
        field(300; "Gift Voucher Enabled"; Boolean)
        {
            Caption = 'Gift Voucher Enabled';
            DataClassification = CustomerContent;
        }
        field(305; "Gift Voucher Item No."; Code[20])
        {
            Caption = 'Gift Voucher Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(310; "Gift Voucher Account No."; Code[20])
        {
            Caption = 'Gift Voucher Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(315; "Gift Voucher Report"; Integer)
        {
            Caption = 'Gift Voucher Report';
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(320; "Gift Voucher Code Pattern"; Code[20])
        {
            Caption = 'Gift Voucher Code Pattern';
            DataClassification = CustomerContent;
        }
        field(330; "Gift Voucher Language Code"; Code[20])
        {
            Caption = 'Gift Voucher Language Code';
            DataClassification = CustomerContent;
            TableRelation = Language;
        }
        field(335; "Gift Voucher Valid Period"; DateFormula)
        {
            Caption = 'Gift Voucher Validity';
            DataClassification = CustomerContent;
        }
        field(400; "Credit Voucher Language Code"; Code[10])
        {
            Caption = 'Credit Voucher Language Code';
            DataClassification = CustomerContent;
        }
        field(405; "Credit Voucher Report"; Integer)
        {
            Caption = 'Credit Voucher Report';
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(410; "Credit Voucher Valid Period"; DateFormula)
        {
            Caption = 'Credit Voucher Valid Period';
            DataClassification = CustomerContent;
        }
        field(415; "Credit Voucher Account No."; Code[20])
        {
            Caption = 'Credit Voucher Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(420; "Credit Voucher Code Pattern"; Code[20])
        {
            Caption = 'Credit Voucher Code Pattern';
            DataClassification = CustomerContent;
        }
        field(430; "Exchange Web Code Pattern"; Code[20])
        {
            Caption = 'Exchange Web Code Pattern';
            DataClassification = CustomerContent;
        }
        field(435; "Gift Voucher Activation"; Enum "NPR Mag. Gift Voucher Activ.")
        {
            Caption = 'Activate Gift Voucher';
            DataClassification = CustomerContent;
        }
        field(480; "Fixed Customer No."; Code[20])
        {
            Caption = 'Fixed Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(490; "Customer Update Mode"; Enum "NPR Magento Cust. Update Mode")
        {
            Caption = 'Customer Update Mode';
            DataClassification = CustomerContent;
        }
        field(500; "Customer Mapping"; Enum "NPR Magento Customer Mapping")
        {
            Caption = 'Customer Mapping';
            DataClassification = CustomerContent;
        }
        field(505; "Customer Posting Group"; Code[10])
        {
            Caption = 'Customer Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Customer Posting Group";
        }
        field(515; "Customer Template Code"; Code[10])
        {
            Caption = 'Customer Template Code';
            DataClassification = CustomerContent;
            TableRelation = "Customer Template";
        }
        field(517; "Customer Config. Template Code"; Code[10])
        {
            Caption = 'Customer Config. Template Code';
            DataClassification = CustomerContent;
            TableRelation = "Config. Template Header".Code WHERE("Table ID" = CONST(18));
        }
        field(520; "Payment Terms Code"; Code[10])
        {
            Caption = 'Payment Terms Code';
            DataClassification = CustomerContent;
            TableRelation = "Payment Terms";
        }
        field(525; "Payment Fee Account No."; Code[20])
        {
            Caption = 'Payment Fee Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(530; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser";
        }
        field(535; "Release Order on Import"; Boolean)
        {
            Caption = 'Release Order on Import';
            DataClassification = CustomerContent;
        }
        field(540; "Use Blank Code for LCY"; Boolean)
        {
            Caption = 'Use Blank Code for LCY';
            DataClassification = CustomerContent;
        }
        field(600; "Replicate to Sales Prices"; Boolean)
        {
            Caption = 'Replicate to Sales Prices';
            DataClassification = CustomerContent;
        }
        field(605; "Replicate to Sales Type"; Enum "Sales Price Type")
        {
            Caption = 'Replicate to Sales Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Replicate to Sales Code" := '';
            end;
        }
        field(610; "Replicate to Sales Code"; Code[20])
        {
            Caption = 'Replicate to Sales Code';
            DataClassification = CustomerContent;
            TableRelation = IF ("Replicate to Sales Type" = CONST("Customer Price Group")) "Customer Price Group"
            ELSE
            IF ("Replicate to Sales Type" = CONST(Customer)) Customer
            ELSE
            IF ("Replicate to Sales Type" = CONST(Campaign)) Campaign;
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
        field(615; "Auto Seo Link Disabled"; Boolean)
        {
            Caption = 'Auto Seo Link Disabled';
            DataClassification = CustomerContent;
        }
        field(700; "Post Retail Vouchers on Import"; Boolean)
        {
            Caption = 'Post Retail Vouchers on Import';
            DataClassification = CustomerContent;
        }
        field(710; "E-mail Retail Vouchers to"; Enum "NPR E-mail Retail Vouchers to")
        {
            Caption = 'E-mail Retail Vouchers to';
            DataClassification = CustomerContent;
        }
        field(720; "Post Tickets on Import"; Boolean)
        {
            Caption = 'Post Tickets on Import';
            DataClassification = CustomerContent;
        }
        field(730; "Post Memberships on Import"; Boolean)
        {
            Caption = 'Post Memberships on Import';
            DataClassification = CustomerContent;
        }
        field(750; "Send Order Confirmation"; Boolean)
        {
            Caption = 'Send Order Confirmation';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Release Order on Import" := true;
            end;
        }
        field(760; "E-mail Template (Order Conf.)"; Code[20])
        {
            Caption = 'E-mail Template (Order Confirmation)';
            DataClassification = CustomerContent;
            TableRelation = "NPR E-mail Template Header" WHERE("Table No." = CONST(36));
        }
        field(800; "Stock Calculation Method"; Enum "NPR Stock Calculation Method")
        {
            Caption = 'Stock Calculation Method';
            DataClassification = CustomerContent;
        }
        field(810; "Stock NpXml Template"; Code[20])
        {
            Caption = 'Stock NpXml Template';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpXml Template" WHERE("Table No." = CONST(27),
                                                    "Xml Root Name" = CONST('stock_updates'));
        }
        field(820; "Stock Codeunit Id"; Integer)
        {
            BlankZero = true;
            Caption = 'Stock Codeunit Id';
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit));
        }
        field(830; "Stock Codeunit Name"; Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Codeunit),
                                                             "Object ID" = FIELD("Stock Codeunit Id")));
            Caption = 'Stock Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(840; "Stock Function Name"; Text[250])
        {
            Caption = 'Stock Function Name';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", GetStockPublisherCodeunitId());
                EventSubscription.SetRange("Published Function", GetStockPublisherFunctionName());
                if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
                    exit;

                "Stock Codeunit Id" := EventSubscription."Subscriber Codeunit ID";
                "Stock Function Name" := EventSubscription."Subscriber Function";
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                if "Stock Function Name" = '' then begin
                    "Stock Codeunit Id" := 0;
                    exit;
                end;

                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", GetStockPublisherCodeunitId());
                EventSubscription.SetRange("Published Function", GetStockPublisherFunctionName());
                if "Stock Codeunit Id" > 0 then
                    EventSubscription.SetRange("Subscriber Codeunit ID", "Stock Codeunit Id");
                if "Stock Function Name" <> '' then
                    EventSubscription.SetFilter("Subscriber Function", '@*' + "Stock Function Name" + '*');
                EventSubscription.FindFirst;

                "Stock Codeunit Id" := EventSubscription."Subscriber Codeunit ID";
                "Stock Function Name" := EventSubscription."Subscriber Function";
            end;
        }
        field(850; "NpCs Workflow Code"; Code[20])
        {
            Caption = 'Collect in Store Workflow Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpCs Workflow";
        }
        field(860; "NpCs From Store Code"; Code[20])
        {
            Caption = 'From Collect Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpCs Store" WHERE("Local Store" = CONST(true));

            trigger OnLookup()
            var
                NpCsStore: Record "NPR NpCs Store";
            begin
                NpCsStore.SetRange("Local Store", true);
                NpCsStore.SetFilter("Location Code", "Inventory Location Filter");
                if PAGE.RunModal(0, NpCsStore) = ACTION::LookupOK then
                    Validate("NpCs From Store Code", NpCsStore.Code);
            end;

            trigger OnValidate()
            var
                NpCsStoreWorkflowRelation: Record "NPR NpCs Store Workflow Rel.";
            begin
                if "NpCs From Store Code" = '' then
                    exit;

                NpCsStoreWorkflowRelation.SetRange("Store Code");
                if NpCsStoreWorkflowRelation.FindFirst then
                    Validate("NpCs Workflow Code", NpCsStoreWorkflowRelation."Workflow Code");
            end;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    [NonDebuggable]
    procedure SetApiPassword(NewPassword: Text)
    begin
        if IsNullGuid("Api Password Key") then
            "Api Password Key" := CreateGuid();
        IsolatedStorage.Set("Api Password Key", NewPassword, DataScope::Company);
    end;

    [NonDebuggable]
    procedure GetApiPassword() PasswordValue: Text
    begin
        IsolatedStorage.Get("Api Password Key", DataScope::Company, PasswordValue);
    end;

    [NonDebuggable]
    procedure HasApiPassword(): Boolean
    begin
        exit(GetApiPassword() <> '');
    end;

    procedure RemoveApiPassword()
    begin
        IsolatedStorage.Delete("Api Password Key", DataScope::Company);
        Clear("Api Password Key");
    end;

    [NonDebuggable]
    procedure SetNavApiPassword(NewPassword: Text)
    begin
        if IsNullGuid("Managed Nav Api Password Key") then
            "Managed Nav Api Password Key" := CreateGuid();
        IsolatedStorage.Set("Managed Nav Api Password Key", NewPassword, DataScope::Company);
    end;

    [NonDebuggable]
    procedure GetNavApiPassword() PasswordValue: Text
    begin
        IsolatedStorage.Get("Managed Nav Api Password Key", DataScope::Company, PasswordValue);
    end;

    [NonDebuggable]
    procedure HasNavApiPassword(): Boolean
    begin
        exit(GetNavApiPassword() <> '');
    end;

    procedure RemoveNavApiPassword()
    begin
        IsolatedStorage.Delete("Managed Nav Api Password Key", DataScope::Company);
        Clear("Managed Nav Api Password Key");
    end;

    procedure GetApiUsername(): Text[250]
    var
        NpXmlMgt: Codeunit "NPR NpXml Mgt.";
    begin
        case "Api Username Type" of
            "Api Username Type"::Automatic:
                begin
                    exit(NpXmlMgt.GetAutomaticUsername());
                end;
            else
                exit("Api Username");
        end;
    end;

    local procedure UpdateApi()
    var
        CryptographyManagement: Codeunit "Cryptography Management";
    begin
        case "Magento Version" of
            "Magento Version"::"2":
                begin
                    "Api Url" := "Magento Url" + 'rest/all/V1/naviconnect/';
                    exit;
                end;
        end;
        "Api Url" := "Magento Url" + 'api/rest/naviconnect/';
        if not HasApiPassword() then
            SetApiPassword(CryptographyManagement.GenerateHash(Format(CurrentDateTime, 0, 9), 0));
    end;

    procedure GetBasicAuthInfo(): Text
    var
        Base64: Codeunit "Base64 Convert";
    begin
        exit(Base64.ToBase64(GetApiUsername() + ':' + GetApiPassword(), TextEncoding::UTF8));
    end;

    procedure GetCredentialsHash(): Text
    var
        CryptographyManagement: Codeunit "Cryptography Management";
    begin
        exit(LowerCase(CryptographyManagement.GenerateHash(GetApiUsername() + GetApiPassword() + 'D3W7k5pd7Pn64ctn25ng91ZkSvyDnjo2', 0)));
    end;

    local procedure GetStockPublisherCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Magento Item Mgt.");
    end;

    local procedure GetStockPublisherFunctionName(): Text
    begin
        exit('OnCalcStockQty');
    end;
}