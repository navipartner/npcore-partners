table 6150616 "NPR POS Payment Method"
{
    Caption = 'POS Payment Method';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Payment Method List";
    LookupPageID = "NPR POS Payment Method List";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Processing Type"; Enum "NPR Payment Processing Type")
        {
            Caption = 'Processing Type';
            DataClassification = CustomerContent;
        }
        field(15; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;

            trigger OnValidate()
            begin
                CheckGLSetup();
                if Rec."Currency Code" <> '' then
                    Rec."Use Stand. Exc. Rate for Bal." := ConfirmUsageOfStandardExchangeRate();
            end;
        }
        field(20; "Vouched By"; Option)
        {
            Caption = 'Vouched By';
            DataClassification = CustomerContent;
            OptionCaption = 'Internal,External';
            OptionMembers = INTERNAL,EXTERNAL;
        }
        field(25; "Is Finance Agreement"; Boolean)
        {
            Caption = 'Is Finance Agreement';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(28; "Account Type"; Enum "NPR POS Pay. Met. Acc. Type")
        {
            Caption = 'Account Type';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(29; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(30; "Include In Counting"; Option)
        {
            Caption = 'Include In Counting';
            DataClassification = CustomerContent;
            OptionCaption = 'No,Yes,Yes - Blind,Virtual';
            OptionMembers = NO,YES,BLIND,VIRTUAL;
        }
        field(31; "Fixed Rate"; Decimal)
        {
            Caption = 'Fixed Rate';
            DataClassification = CustomerContent;
        }
        field(32; "Use Stand. Exc. Rate for Bal."; Boolean)
        {
            Caption = 'Use Standard Exchange Rate from BC';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Use Stand. Exc. Rate for Bal." then
                    Rec."Use Stand. Exc. Rate for Bal." := ConfirmUsageOfStandardExchangeRate();
            end;
        }
        field(35; "Bin for Virtual-Count"; Code[10])
        {
            Caption = 'Bin for Virtual-Count';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Bin" WHERE("Bin Type" = CONST(VIRTUAL));
        }
        field(40; "Post Condensed"; Boolean)
        {
            Caption = 'Post Condensed';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
        }
        field(41; "Condensed Posting Description"; Text[50])
        {
            Caption = 'Condensed Posting Description';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
        }
        field(50; "Rounding Precision"; Decimal)
        {
            AutoFormatExpression = Code;
            AutoFormatType = 1;
            Caption = 'Rounding Precision';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            InitValue = 1;
        }
        field(51; "Rounding Type"; Option)
        {
            Caption = 'Rounding Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            OptionCaption = 'Nearest,Up,Down';
            OptionMembers = Nearest,Up,Down;
        }
        field(52; "Rounding Gains Account"; Code[20])
        {
            Caption = 'Rounding Gains Account';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            TableRelation = "G/L Account";
        }
        field(53; "Rounding Losses Account"; Code[20])
        {
            Caption = 'Rounding Losses Account';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            TableRelation = "G/L Account";
        }
        field(54; "Maximum Amount"; Decimal)
        {
            Caption = 'Max Amount';
            DataClassification = CustomerContent;
        }
        field(55; "Minimum Amount"; Decimal)
        {
            Caption = 'Min Amount';
            DataClassification = CustomerContent;
        }
        field(60; "Return Payment Method Code"; Code[10])
        {
            Caption = 'Return Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method".Code;
        }
        field(68; "Forced Amount"; Boolean)
        {
            Caption = 'Forced Amount';
            DataClassification = CustomerContent;
        }
        field(75; "Match Sales Amount"; Boolean)
        {
            Caption = 'Match Sales Amount';
            DataClassification = CustomerContent;
        }
        field(100; "Reverse Unrealized VAT"; Boolean)
        {
            Caption = 'Reverse Unrealized VAT';
            DataClassification = CustomerContent;
        }
        field(110; "Open Drawer"; Boolean)
        {
            Caption = 'Open Drawer';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
        }
        field(120; "Allow Refund"; Boolean)
        {
            Caption = 'Allow Refund';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(130; "Zero as Default on Popup"; Boolean)
        {
            Caption = 'Zero as Default on Popup';
            DataClassification = CustomerContent;
        }
        field(140; "No Min Amount on Web Orders"; Boolean)
        {
            Caption = 'No Min Amount on Web Orders';
            DataClassification = CustomerContent;
        }
        field(318; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Only used by Global Dimension 1';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(319; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Only used by Global Dimension 2';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(320; "Auto End Sale"; Boolean)
        {
            Caption = 'Auto End Sale';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(321; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(520; "EFT Surcharge Service Item No."; Code[20])
        {
            Caption = 'Surcharge Service Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item WHERE(Type = CONST(Service));
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaced by G/L account setup field which is enforced when creating new EFT Setup records';
        }
        field(521; "EFT Surcharge Account No."; Code[20])
        {
            Caption = 'EFT Surcharge Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" WHERE("Account Type" = CONST(Posting),
                                                 "Direct Posting" = CONST(true));
        }
        field(530; "EFT Tip Service Item No."; Code[20])
        {
            Caption = 'Tip Service Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item WHERE(Type = CONST(Service));
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaced by G/L account setup field which is enforced when creating new EFT Setup records';
        }
        field(531; "EFT Tip Account No."; Code[20])
        {
            Caption = 'EFT Tip Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" WHERE("Account Type" = CONST(Posting),
                                                 "Direct Posting" = CONST(true));
        }
        field(540; "Block POS Payment"; Boolean)
        {
            Caption = 'Block POS Payment';
            DataClassification = CustomerContent;
        }
        field(600; "Created by Version"; Text[100])
        {
            Caption = 'Created by Version';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(700; "NPR Warning pop-up on Return"; Boolean)
        {
            Caption = 'Warning pop-up on Return';
            DataClassification = CustomerContent;
        }

        field(710; "Ask for Check No."; Boolean)
        {
            Caption = 'Ask for Check No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Code, "Processing Type") { }
        fieldgroup(Brick; Code, "Processing Type") { }
    }

    var
        GLSetup: Record "General Ledger Setup";
        HasGotGLSetup: Boolean;

    trigger OnInsert()
    begin
        CheckReturnProcessingType();
    end;

    trigger OnModify()
    var
        MinGreaterThanMax: Label 'The minimum amount has to be less than the maximum amount';
    begin
        if Rec."Minimum Amount" > Rec."Maximum Amount" then
            Error(MinGreaterThanMax);
        CheckReturnProcessingType();
    end;

    trigger OnDelete()
    var
        POSPostingSetup: Record "NPR POS Posting Setup";
    begin
        POSPostingSetup.SetRange("POS Payment Method Code", Rec.Code);
        POSPostingSetup.DeleteAll(true);
    end;


    internal procedure GetRoundingType(): Text[1]
    begin
        case Rec."Rounding Type" of
            Rec."Rounding Type"::Down:
                exit('<');
            Rec."Rounding Type"::Up:
                exit('>');
            Rec."Rounding Type"::Nearest:
                exit('=');
        end;
    end;

    local procedure CheckReturnProcessingType()
    var
        ReturnPOSPaymentMethod: Record "NPR POS Payment Method";
        ReturnedPOSPaymentMethod: Record "NPR POS Payment Method";
    begin
        if ReturnPOSPaymentMethod.Get(Rec."Return Payment Method Code") then
            if ReturnPOSPaymentMethod."Processing Type" = ReturnPOSPaymentMethod."Processing Type"::EFT then
                ReturnPOSPaymentMethod.FieldError("Processing Type");
        if Rec."Processing Type" = Rec."Processing Type"::EFT then begin
            ReturnedPOSPaymentMethod.SetRange("Return Payment Method Code", Rec.Code);
            if not ReturnedPOSPaymentMethod.IsEmpty() then
                Rec.FieldError("Processing Type");
            if Rec.Code = Rec."Return Payment Method Code" then
                Rec.FieldError("Processing Type");
        end;
    end;

    local procedure ConfirmUsageOfStandardExchangeRate(): Boolean
    var
        CurrExchRate: Record "Currency Exchange Rate";
        Currency: Record Currency;
        EnableStandardExchRateQst: Label 'Standard Exchange Rates will apply for %1 in balancing. With current exchange rate setup 1 %1 is equivalent to %2 %3.\Do you want to proceed?', Comment = '%1=Rec.FieldCaption("Currency Code");%2=Exchange Rate;%3=GLSetup."LCY Code"';
    begin
        if not GuiAllowed() then
            exit;

        GetGLSetup();
        Currency.Get(Rec."Currency Code");
        exit(Confirm(EnableStandardExchRateQst,
                        false,
                        Rec."Currency Code",
                        Round(1 / CurrExchRate.ExchangeRate(Today(), Rec."Currency Code"), Currency."Amount Rounding Precision", Currency.InvoiceRoundingDirection()),
                        GLSetup."LCY Code"));
    end;

    local procedure CheckGLSetup()
    var
        CurrencyCodeMsgLbl: Label 'You have selected the local currency.';
    begin
        if not GuiAllowed then
            exit;

        GetGLSetup();
        if GLSetup."LCY Code" = Rec."Currency Code" then
            Message(CurrencyCodeMsgLbl);
    end;

    local procedure GetGLSetup()
    begin
        if not HasGotGLSetup then
            GLSetup.Get();

        HasGotGLSetup := true;
    end;
}

