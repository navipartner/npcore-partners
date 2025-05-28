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
#IF NOT (BC17 or BC18 or BC19 or BC20)            
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Use "Variant Mandatory if Exist" from Inventory Setup and Item';
#ENDIF            
        }
        field(20; "Barcode Type (Alt. No.)"; Option)
        {
            Caption = 'Barcode Type (Alt. No.)';
            DataClassification = CustomerContent;
            OptionCaption = ' ,EAN8,EAN13';
            OptionMembers = " ",EAN8,EAN13;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
        }
        field(21; "Alt. No. No. Series (I)"; Code[10])
        {
            Caption = 'Alt. No. No. Series (Item)';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
        }
        field(22; "Create Alt. No. automatic"; Boolean)
        {
            Caption = 'Create Alt. No. automatic';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
        }
        field(23; "Alt. No. No. Series (V)"; Code[20])
        {
            Caption = 'Alt. No. No. Series (Variant)';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
        }
        field(30; "Barcode Type (Item Cross Ref.)"; Option)
        {
            Caption = 'Barcode Type (Item Cross Ref.)';
            DataClassification = CustomerContent;
            OptionCaption = ' ,EAN8,EAN13';
            OptionMembers = " ",EAN8,EAN13;
            trigger OnValidate()
            begin
                TestNoSeries(Rec."Item Cross Ref. No. Series (I)");
                if Rec."Item Cross Ref. No. Series (V)" <> Rec."Item Cross Ref. No. Series (I)" then
                    TestNoSeries(Rec."Item Cross Ref. No. Series (V)");
            end;
        }
        field(31; "Item Cross Ref. No. Series (I)"; Code[20])
        {
            Caption = 'Item Reference No. Series (Item)';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            trigger OnValidate()
            begin
                TestNoSeries(Rec."Item Cross Ref. No. Series (I)");
            end;
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
            trigger OnValidate()
            begin
                TestNoSeries(Rec."Item Cross Ref. No. Series (V)");
            end;
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
        field(36; "Item Ref. Description 2 (I)"; Option)
        {
            Caption = 'Item Ref. Description 2 (Item)';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Item Description 1,Item Description 2';
            OptionMembers = " ",ItemDescription1,ItemDescription2;
        }
        field(37; "Item Ref. Description 2 (V)"; Option)
        {
            Caption = 'Item Ref. Description 2 (Variant)';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Item Description 1,Item Description 2,Variant Description 1,Variant Description 2';
            OptionMembers = " ",ItemDescription1,ItemDescription2,VariantDescription1,VariantDescription2;
        }
        field(40; "Hide Inactive Values"; Boolean)
        {
            Caption = 'Hide Inactive Values';
            DataClassification = CustomerContent;
            Description = 'VRT1.11';
        }
        field(45; "Show Column Names"; Boolean)
        {
            Caption = 'Show Column Names';
            DataClassification = CustomerContent;
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
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", Codeunit::"NPR Variety Clone Data");
                EventSubscription.SetRange("Published Function", 'GetNewVariantCode');
                if Page.RunModal(Page::"Event Subscriptions", EventSubscription) <> Action::LookupOK then
                    exit;

                Validate("Create Variant Code From", EventSubscription."Subscriber Function");
            end;
        }
        field(80; "Custom Descriptions"; Boolean)
        {
            Caption = 'Custom Descriptions';
            DataClassification = CustomerContent;
        }
        field(90; "Pop up Variety Matrix"; Boolean)
        {
            Caption = 'Pop up Variety Matrix';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                SetPopupVarietyMatrixOnDocuments(Rec."Pop up Variety Matrix");
            end;
        }
        field(91; "Pop up on Sales Order"; Boolean)
        {
            Caption = 'Pop up on Sales Order';
            DataClassification = CustomerContent;
        }
        field(92; "Pop up on Purchase Order"; Boolean)
        {
            Caption = 'Pop up on Purchase Order';
            DataClassification = CustomerContent;
        }
        field(93; "Pop up on Transfer Order"; Boolean)
        {
            Caption = 'Pop up on Transfer Order';
            DataClassification = CustomerContent;
        }
        field(94; "Pop up on Sales Return Order"; Boolean)
        {
            Caption = 'Pop up on Sales Return Order';
            DataClassification = CustomerContent;
        }
        field(95; "Pop up on Purch. Return Order"; Boolean)
        {
            Caption = 'Pop up on Purch. Return Order';
            DataClassification = CustomerContent;
        }
        field(100; "Activate Inventory"; Boolean)
        {
            Caption = 'Activate Inventory in Variety Lookup on POS';
            DataClassification = CustomerContent;
        }

        field(105; "Allow Clear Matrix"; Boolean)
        {
            Caption = 'Allow Clear Matrix';
            DataClassification = CustomerContent;
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

    procedure SetPopupVarietyMatrixOnDocuments(Enable: Boolean)
    begin
        Rec."Pop up on Sales Order" := Enable;
        Rec."Pop up on Sales Return Order" := Enable;
        Rec."Pop up on Purchase Order" := Enable;
        Rec."Pop up on Purch. Return Order" := Enable;
        Rec."Pop up on Transfer Order" := Enable;
    end;

    local procedure TestNoSeries(NoSeriesCode: Code[20])
    var
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesManagement: Codeunit "No. Series";
#ELSE
        NoSeriesManagement: Codeunit NoSeriesManagement;
#ENDIF
        NextNo: Code[20];
        RequiredLength: Integer;
        InvalidNoSerieErr: Label 'Number Series %1 generates a value (%2) which does not have the required length (%3) for Barcodetype %4';
        NonNumericErr: Label 'Number Series %1 generates a value (%2) which is not numerical. This value can''t be used to generate a %3 barcode';
    begin
        if NoSeriesCode = '' then
            exit;
        if not Rec."Create Item Cross Ref. auto." then
            exit;
        if Rec."Barcode Type (Item Cross Ref.)" = Rec."Barcode Type (Item Cross Ref.)"::" " then
            exit;
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NextNo := NoSeriesManagement.PeekNextNo(NoSeriesCode, Today);
#ELSE
        NextNo := NoSeriesManagement.TryGetNextNo(NoSeriesCode, Today);
#ENDIF
        case Rec."Barcode Type (Item Cross Ref.)" of
            Rec."Barcode Type (Item Cross Ref.)"::EAN13:
                RequiredLength := 12;
            Rec."Barcode Type (Item Cross Ref.)"::EAN8:
                RequiredLength := 7;
            else
                exit;
        end;
        if StrLen(DelChr(NextNo, '=', '1234567890')) > 0 then
            Message(NonNumericErr, NoSeriesCode, NextNo, Rec."Barcode Type (Item Cross Ref.)")
        else
            if StrLen(NextNo) <> RequiredLength then
                Message(InvalidNoSerieErr, NoSeriesCode, NextNo, RequiredLength, Rec."Barcode Type (Item Cross Ref.)");
    end;

    var
        NoSeriesChangeErr: Label 'No. Series cannot be changed!';
}

