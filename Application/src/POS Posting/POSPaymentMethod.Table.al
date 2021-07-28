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
        field(10; "Processing Type"; Option)
        {
            Caption = 'Processing Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Cash,Voucher,Check,EFT,CUSTOMER,PayOut,Foreign Voucher';
            OptionMembers = CASH,VOUCHER,CHECK,EFT,CUSTOMER,PAYOUT,"FOREIGN VOUCHER";
        }
        field(15; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
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
            ObsoleteReason = 'Not used';
        }
        field(28; "Account Type"; Enum "NPR POS Payment Method Account Type")
        {
            Caption = 'Account Type';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(29; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" where("Direct Posting" = const(true), "Account Type" = const(Posting), Blocked = const(false));
            ObsoleteState = Removed;
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
        field(76; "Normal Sale in POS"; Decimal)
        {
            CalcFormula = Sum("NPR POS Entry Sales Line"."Amount Incl. VAT" WHERE("POS Unit No." = FIELD("POS Unit Filter"),
                                                                        "Document No." = FIELD("Document Filter"),
                                                                        "Entry Date" = FIELD("Date Filter"),
                                                                         Type = CONST(Item),
                                                                         "Salesperson Code" = FIELD("Salesperson Filter"),
                                                                         "Shortcut Dimension 1 Code" = FIELD("Global Dimension Code 1 Filter"),
                                                                         "Shortcut Dimension 2 Code" = FIELD("Global Dimension Code 2 Filter")));
            Caption = 'Normal Sale in POS';
            FieldClass = FlowField;
        }
        field(77; "Debit Sale in POS"; Decimal)
        {
            CalcFormula = Sum("NPR POS Entry Sales Line"."Amount Incl. VAT" WHERE("POS Unit No." = FIELD("POS Unit Filter"),
                                                                         "Document No." = FIELD("Document Filter"),
                                                                         "Entry Date" = FIELD("Date Filter"),
                                                                         Type = CONST(Item),
                                                                         "Salesperson Code" = FIELD("Salesperson Filter"),
                                                                         "Shortcut Dimension 1 Code" = FIELD("Global Dimension Code 1 Filter"),
                                                                         "Shortcut Dimension 2 Code" = FIELD("Global Dimension Code 2 Filter")));
            Caption = 'Debit Sale in POS';
            FieldClass = FlowField;
        }
        field(78; "No. of Sales in POS"; Integer)
        {
            CalcFormula = Count("NPR POS Entry Sales Line" WHERE("POS Unit No." = FIELD("POS Unit Filter"),
                                                    "Document No." = FIELD("Document Filter"),
                                                    Type = CONST(Item),
                                                    "Line No." = CONST(10000),
                                                    "Entry Date" = FIELD("Date Filter"),
                                                    "Salesperson Code" = FIELD("Salesperson Filter"),
                                                    "Shortcut Dimension 1 Code" = FIELD("Global Dimension Code 1 Filter"),
                                                    "Shortcut Dimension 2 Code" = FIELD("Global Dimension Code 2 Filter")));
            Caption = 'No. Sales in POS';
            FieldClass = FlowField;
        }
        field(79; "Cost Amount in POS"; Decimal)
        {
            CalcFormula = Sum("NPR POS Entry Sales Line"."Unit Cost" WHERE("POS Unit No." = FIELD("POS Unit Filter"),
                                                       "Document No." = FIELD("Document Filter"),
                                                       "Entry Date" = FIELD("Date Filter"),
                                                       Type = CONST(Item),
                                                       "Salesperson Code" = FIELD("Salesperson Filter"),
                                                       "Shortcut Dimension 1 Code" = FIELD("Global Dimension Code 1 Filter"),
                                                       "Shortcut Dimension 2 Code" = FIELD("Global Dimension Code 2 Filter")));
            Caption = 'Cost Amount in POS';
            FieldClass = FlowField;
        }
        field(80; "Amount in POS Payment Line"; Decimal)
        {
            CalcFormula = Sum("NPR POS Entry Payment Line"."Amount" WHERE("POS Unit No." = FIELD("POS Unit Filter"),
                                                                         "Document No." = FIELD("Document Filter"),
                                                                         "Entry Date" = FIELD("Date Filter"),
                                                                         "Shortcut Dimension 1 Code" = FIELD("Global Dimension Code 1 Filter"),
                                                                         "Shortcut Dimension 2 Code" = FIELD("Global Dimension Code 2 Filter"),
                                                                         "POS Payment Method Code" = FIELD(Code)));
            Caption = 'Amount in POS Payment Line';
            FieldClass = FlowField;
        }
        field(81; "No. of Items in POS"; Decimal)
        {
            CalcFormula = Sum("NPR POS Entry Sales Line".Quantity WHERE("POS Unit No." = FIELD("POS Unit Filter"),
                                                           "Document No." = FIELD("Document Filter"),
                                                           "Entry Date" = FIELD("Date Filter"),
                                                           Type = CONST(Item),
                                                           "Salesperson Code" = FIELD("Salesperson Filter"),
                                                           "Shortcut Dimension 1 Code" = FIELD("Global Dimension Code 1 Filter"),
                                                           "Shortcut Dimension 2 Code" = FIELD("Global Dimension Code 2 Filter")));
            Caption = 'No. of Items in POS';
            FieldClass = FlowField;
        }
        field(82; "No. of Sale Lines in POS"; Integer)
        {
            CalcFormula = Count("NPR POS Entry Sales Line" WHERE("POS Unit No." = FIELD("POS Unit Filter"),
                                                    "Document No." = FIELD("Document Filter"),
                                                    "Entry Date" = FIELD("Date Filter"),
                                                    "Salesperson Code" = FIELD("Salesperson Filter"),
                                                    "Shortcut Dimension 1 Code" = FIELD("Global Dimension Code 1 Filter"),
                                                    "Shortcut Dimension 2 Code" = FIELD("Global Dimension Code 2 Filter")));
            Caption = 'No. of Sale Lines in POS';
            FieldClass = FlowField;
        }
        field(83; "No. of Item Lines in POS"; Integer)
        {
            CalcFormula = Count("NPR POS Entry Sales Line" WHERE("POS Unit No." = FIELD("POS Unit Filter"),
                                                    "Document No." = FIELD("Document Filter"),
                                                    "No." = FILTER(<> ''),
                                                    "Entry Date" = FIELD("Date Filter"),
                                                    "Salesperson Code" = FIELD("Salesperson Filter"),
                                                    "Shortcut Dimension 1 Code" = FIELD("Global Dimension Code 1 Filter"),
                                                    "Shortcut Dimension 2 Code" = FIELD("Global Dimension Code 2 Filter"),
                                                    "Type" = Filter(Item)));
            Caption = 'No. of Item Lines in POS';
            FieldClass = FlowField;
        }
        field(84; "No. of Deb. Sales in POS"; Integer)
        {
            CalcFormula = Count("NPR POS Entry" WHERE("POS Unit No." = FIELD("POS Unit Filter"),
                                                    "Document No." = FIELD("Document Filter"),
                                                    "Entry Type" = CONST("Direct Sale"),
                                                    "Entry Date" = FIELD("Date Filter"),
                                                    "Salesperson Code" = FIELD("Salesperson Filter"),
                                                    "Shortcut Dimension 1 Code" = FIELD("Global Dimension Code 1 Filter"),
                                                    "Shortcut Dimension 2 Code" = FIELD("Global Dimension Code 2 Filter")));
            Caption = 'No. of Deb. Sales in POS';
            FieldClass = FlowField;
        }
        field(85; "Norm. Sales in POS Excl. VAT"; Decimal)
        {
            CalcFormula = Sum("NPR POS Entry"."Amount Excl. Tax" WHERE("Entry Date" = FIELD("Date Filter"),
                                                         "POS Unit No." = FIELD("POS Unit Filter"),
                                                         "Entry Type" = CONST(Other),
                                                         "Salesperson Code" = FIELD("Salesperson Filter"),
                                                         "Shortcut Dimension 1 Code" = FIELD("Global Dimension Code 1 Filter"),
                                                         "Shortcut Dimension 2 Code" = FIELD("Global Dimension Code 2 Filter")));
            Caption = 'Norm. Sales in POS Excl. VAT';
            FieldClass = FlowField;
        }
        field(86; "Debit Sales in POS Excl. VAT"; Decimal)
        {
            CalcFormula = Sum("NPR POS Entry"."Amount Excl. Tax" WHERE("Entry Date" = FIELD("Date Filter"),
                                                         "POS Unit No." = FIELD("POS Unit Filter"),
                                                         "Entry Type" = CONST("Credit Sale"),
                                                         "Salesperson Code" = FIELD("Salesperson Filter"),
                                                         "Shortcut Dimension 1 Code" = FIELD("Global Dimension Code 1 Filter"),
                                                         "Shortcut Dimension 2 Code" = FIELD("Global Dimension Code 2 Filter"),
                                                         "Document No." = FIELD("Document Filter")));
            Caption = 'Debit Sales in POS Excl. VAT';
            FieldClass = FlowField;
        }
        field(87; "Unit Cost in POS Sale"; Decimal)
        {
            CalcFormula = Sum("NPR POS Entry Sales Line"."Unit Cost" WHERE("Entry Date" = FIELD("Date Filter"),
                                                       "Document No." = FIELD("Document Filter"),
                                                       Type = CONST(Item),
                                                       "Salesperson Code" = FIELD("Salesperson Filter"),
                                                       "Shortcut Dimension 1 Code" = FIELD("Global Dimension Code 1 Filter"),
                                                       "Shortcut Dimension 2 Code" = FIELD("Global Dimension Code 2 Filter"),
                                                       "Document No." = FIELD("Document Filter")));
            Caption = 'Unit Cost in POS Sale';
            FieldClass = FlowField;
        }
        field(88; "Amount in POS"; Decimal)
        {
            CalcFormula = Sum("NPR POS Entry Sales Line"."Amount Incl. VAT" WHERE("POS Unit No." = FIELD("POS Unit Filter"),
                                                                         "Document No." = FIELD("Document Filter"),
                                                                         "Entry Date" = FIELD("Date Filter"),
                                                                         "Salesperson Code" = FIELD("Salesperson Filter"),
                                                                         "Shortcut Dimension 1 Code" = FIELD("Global Dimension Code 1 Filter"),
                                                                         "Shortcut Dimension 2 Code" = FIELD("Global Dimension Code 2 Filter")));
            Caption = 'Amount in POS';
            FieldClass = FlowField;
        }
        field(89; "POS Unit Filter"; Code[10])
        {
            Caption = 'POS Unit Filter';
            FieldClass = FlowFilter;
        }
        field(90; "Document Filter"; Code[20])
        {
            Caption = 'Document Filter';
            FieldClass = FlowFilter;
        }
        field(91; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(92; "Global Dimension Code 1 Filter"; Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension Code 1 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(93; "Global Dimension Code 2 Filter"; Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension Code 2 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(94; "Salesperson Filter"; Code[20])
        {
            Caption = 'Salesperson filter';
            FieldClass = FlowFilter;
            TableRelation = "Salesperson/Purchaser".Code;
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
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(319; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Only used by Global Dimension 2';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            ObsoleteState = Removed;
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
            TableRelation = "Payment Method";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(520; "EFT Surcharge Service Item No."; Code[20])
        {
            Caption = 'Surcharge Service Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item WHERE(Type = CONST(Service));
        }
        field(530; "EFT Tip Service Item No."; Code[20])
        {
            Caption = 'Tip Service Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item WHERE(Type = CONST(Service));
        }
        field(540; "Block POS Payment"; Boolean)
        {
            Caption = 'Block POS Payment';
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
    }

    trigger OnModify()
    var
        MinGreaterThanMax: Label 'The minimum amount has to be less than the maximum amount';
    begin
        if rec."Minimum Amount" > rec."Maximum Amount" then
            error(MinGreaterThanMax);
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

}

