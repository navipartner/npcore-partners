table 6059970 "NPR Variety Setup"
{
    Caption = 'Variety Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(9; "Variety Enabled"; Boolean)
        {
            Caption = 'Variety Enabled';
            DataClassification = CustomerContent;
        }
        field(10; "Item Journal Blocking"; Option)
        {
            Caption = 'Item Journal Blocking';
            DataClassification = CustomerContent;
            OptionCaption = 'Total Block Item If Variants,Sale Block Item If Variants,Allow Non Variants';
            OptionMembers = TotalBlockItemIfVariants,SaleBlockItemIfVariants,AllowNonVariants;
        }
        field(20; "Barcode Type (Alt. No.)"; Option)
        {
            Caption = 'Barcode Type (Alt. No.)';
            DataClassification = CustomerContent;
            OptionCaption = ' ,EAN8,EAN13';
            OptionMembers = " ",EAN8,EAN13;
            ObsoleteState = Removed;
        }
        field(21; "Alt. No. No. Series (I)"; Code[10])
        {
            Caption = 'Alt. No. No. Series (Item)';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
        }
        field(22; "Create Alt. No. automatic"; Boolean)
        {
            Caption = 'Create Alt. No. automatic';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
        }
        field(23; "Alt. No. No. Series (V)"; Code[20])
        {
            Caption = 'Alt. No. No. Series (Variant)';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ObsoleteState = Removed;
        }
        field(30; "Barcode Type (Item Cross Ref.)"; Option)
        {
            Caption = 'Barcode Type (Item Cross Ref.)';
            DataClassification = CustomerContent;
            OptionCaption = ' ,EAN8,EAN13';
            OptionMembers = " ",EAN8,EAN13;
        }
        field(31; "Item Cross Ref. No. Series (I)"; Code[20])
        {
            Caption = 'Item Reference No. Series (Item)';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(32; "Create Item Cross Ref. auto."; Boolean)
        {
            Caption = 'Create Item Reference Automatically';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(33; "Item Cross Ref. No. Series (V)"; Code[20])
        {
            Caption = 'Item Reference No. Series (Variant)';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(34; "Item Cross Ref. Description(I)"; Option)
        {
            Caption = 'Item Reference Description (Item)';
            DataClassification = CustomerContent;
            OptionCaption = 'Item Description 1,Item Description 2';
            OptionMembers = ItemDescription1,ItemDescription2;
        }
        field(35; "Item Cross Ref. Description(V)"; Option)
        {
            Caption = 'Item Reference Description (Variant)';
            DataClassification = CustomerContent;
            OptionCaption = 'Item Description 1,Item Description 2,Variant Description 1,Variant Description 2';
            OptionMembers = ItemDescription1,ItemDescription2,VariantDescription1,VariantDescription2;
        }
        field(40; "Hide Inactive Values"; Boolean)
        {
            Caption = 'Hide Inactive Values';
            DataClassification = CustomerContent;
            Description = 'VRT1.11';
        }
        field(53; "Internal EAN No. Series"; Code[20])
        {
            Caption = 'Internal EAN No. Series';
            DataClassification = CustomerContent;
            Description = 'Nummerserie til EAN numre';
            TableRelation = "No. Series";

            trigger OnValidate()
            begin
                if xRec."Internal EAN No. Series" <> '' then
                    Error(NoSeriesChangeErr);
            end;
        }
        field(54; "EAN-Internal"; Integer)
        {
            Caption = 'EAN-Internal';
            DataClassification = CustomerContent;
            Description = 'Intern ean nummer start';
            MaxValue = 29;
            MinValue = 27;
        }
        field(56; "External EAN No. Series"; Code[20])
        {
            Caption = 'External EAN-No. Series';
            DataClassification = CustomerContent;
            Description = 'Nummerserie til eksterne EAN numre';
            TableRelation = "No. Series";

            trigger OnValidate()
            begin
                if xRec."Internal EAN No. Series" <> '' then
                    Error(NoSeriesChangeErr);
            end;
        }
        field(57; "EAN-External"; Integer)
        {
            Caption = 'EAN-External';
            DataClassification = CustomerContent;
            Description = 'ekstern eannummer';
        }
        field(60; "Variant Description"; Option)
        {
            Caption = 'Variant Description';
            DataClassification = CustomerContent;
            Description = 'VRT1.11';
            OptionCaption = 'Variety Table Setup First 50,Variety Table Setup Next 50,Item Description 1,Item Description 2';
            OptionMembers = VarietyTableSetupFirst50,VarietyTableSetupNext50,ItemDescription1,ItemDescription2;
        }
        field(61; "Variant Description 2"; Option)
        {
            Caption = 'Variant Description 2';
            DataClassification = CustomerContent;
            Description = 'VRT1.11';
            InitValue = VarietyTableSetupNext50;
            OptionCaption = 'Variety Table Setup First 50,Variety Table Setup Next 50,Item Description 1,Item Description 2';
            OptionMembers = VarietyTableSetupFirst50,VarietyTableSetupNext50,ItemDescription1,ItemDescription2;
        }
        field(70; "Create Variant Code From"; Text[60])
        {
            Caption = 'Create Variant Code From';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //-NPR5.43 [317108]
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR Variety Clone Data");
                EventSubscription.SetRange("Published Function", 'GetNewVariantCode');
                if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
                    exit;

                Validate("Create Variant Code From", EventSubscription."Subscriber Function");
                //+NPR5.43 [317108]
            end;
        }
        field(750; "Variant No. Series"; Code[20])
        {
            Caption = 'Variant Std. No. Serie';
            DataClassification = CustomerContent;
            Description = 'Nummerserie til 10-code variantkode (ikke EAN)';
            TableRelation = "No. Series";
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

    var
        NoSeriesChangeErr: Label 'No. Series cannot be changed!';
}

