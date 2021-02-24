table 6014423 "NPR Period"
{
    Caption = 'Period';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Integer)
        {
            Caption = 'No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            Editable = false;
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(3; Status; Option)
        {
            Caption = 'Status';
            Editable = false;
            OptionCaption = 'Passive,Ongoing,Balanced,Saved';
            OptionMembers = Passiv,Ongoing,Balanced,Saved;
            DataClassification = CustomerContent;
        }
        field(4; "Balancing Time"; Time)
        {
            Caption = 'Balancing Time';
            Editable = false;
            InitValue = 000000T;
            NotBlank = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Period.Get("No." - 1) then
                    if "Balancing Time" < Period."Balancing Time" then
                        Error(Text1060000, "No.", Period."Balancing Time");
            end;
        }
        field(5; "Last Date Active"; Date)
        {
            Caption = 'Last Date Active';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(6; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(7; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(8; Register; Integer)
        {
            Caption = 'Cash Register';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(9; "Date Opened"; Date)
        {
            Caption = 'Date Opened';
            Description = 'overf¢r fra kasse';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(10; "Date Closed"; Date)
        {
            Caption = 'Date Closed';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11; "Date Saved"; Date)
        {
            Caption = 'Date Saved';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(12; "Opening Time"; Time)
        {
            Caption = 'Opening Time';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(13; "Closing Time"; Time)
        {
            Caption = 'Closing Time';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14; "Saving  Time"; Time)
        {
            Caption = 'Saving Time';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(15; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            Editable = false;
            TableRelation = "NPR Audit Roll"."Sales Ticket No." WHERE(Type = CONST("Open/Close"));
            DataClassification = CustomerContent;
        }
        field(16; "Opening Sales Ticket No."; Code[10])
        {
            Caption = 'Opening Sales Ticket No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(17; Comment; Text[250])
        {
            Caption = 'Comment';
            DataClassification = CustomerContent;
        }
        field(20; "Opening Cash"; Decimal)
        {
            Caption = 'Opening Cash';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(21; "Net. Cash Change"; Decimal)
        {
            Caption = 'Net. Cash Change';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(22; "Net. Credit Voucher Change"; Decimal)
        {
            Caption = 'Net. Credit Voucher Change';
            Editable = false;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Credit voucher table won''t be used anymore.';
            ObsoleteTag = 'NPR Credit Voucher';
        }
        field(23; "Net. Gift Voucher Change"; Decimal)
        {
            Caption = 'Net. Gift Voucher Change';
            Editable = false;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Gift voucher table won''t be used anymore.';
            ObsoleteTag = 'NPR Gift Voucher';
        }
        field(24; "Net. Terminal Change"; Decimal)
        {
            Caption = 'Net. Terminal Change';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(25; "Net. Dankort Change"; Decimal)
        {
            Caption = 'Dankort';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(26; "Net. VisaCard Change"; Decimal)
        {
            Caption = 'Net. VisaCard Change';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(27; "Net. Change Other Cedit Cards"; Decimal)
        {
            Caption = 'Net. Change Other Cedit Cards';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(28; "Gift Voucher Sales"; Decimal)
        {
            Caption = 'Gift Voucher Sales';
            Editable = false;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Gift voucher table won''t be used anymore.';
            ObsoleteTag = 'NPR Gift Voucher';
        }
        field(29; "Credit Voucher issuing"; Decimal)
        {
            Caption = 'Credit Voucher issuing';
            Editable = false;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Credit voucher table won''t be used anymore.';
            ObsoleteTag = 'NPR Credit Voucher';
        }
        field(30; "Cash Received"; Decimal)
        {
            Caption = 'Cash Received';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(31; "Pay Out"; Decimal)
        {
            Caption = 'Pay Out';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(32; "Debit Sale"; Decimal)
        {
            Caption = 'Debit Sale';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(33; "Negative Sales Count"; Integer)
        {
            Caption = 'NegSalesQty';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(34; "Negative Sales Amount"; Decimal)
        {
            Caption = 'NegSalesAmt';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(35; Cheque; Decimal)
        {
            Caption = 'Cheque';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(36; "Balanced Cash Amount"; Decimal)
        {
            Caption = 'Balanced Cash Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(37; "Closing Cash"; Decimal)
        {
            Caption = 'Closing Cash';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(38; Difference; Decimal)
        {
            Caption = 'Difference';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(39; "Deposit in Bank"; Decimal)
        {
            Caption = 'Deposit in Bank';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(40; "Balance Per Denomination"; Text[250])
        {
            Caption = 'Balance Per Denomination';
            Description = 'm¢nt optalt streng separeret af '';''';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(41; "Balanced Sec. Currency"; Text[250])
        {
            Caption = 'Balanced Sec. Currency';
            DataClassification = CustomerContent;
        }
        field(42; "Balanced Euro"; Text[250])
        {
            Caption = 'Balanced Euro';
            DataClassification = CustomerContent;
        }
        field(43; "Change Register"; Decimal)
        {
            Caption = 'Change Cash Register';
            DataClassification = CustomerContent;
        }
        field(50; "Gift Voucher Debit"; Decimal)
        {
            Caption = 'Gift Voucher Debit';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Gift voucher table won''t be used anymore.';
            ObsoleteTag = 'NPR Gift Voucher';
        }
        field(51; "Euro Difference"; Decimal)
        {
            Caption = 'Euro Difference';
            DataClassification = CustomerContent;
        }
        field(100; "LCY Count"; Text[250])
        {
            Caption = 'LCY Count';
            DataClassification = CustomerContent;
        }
        field(101; "Euro Count"; Text[250])
        {
            Caption = 'Euro Count';
            DataClassification = CustomerContent;
        }
        field(102; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                LookUpShortcutDimCode(1, "Shortcut Dimension 1 Code");
                Validate("Shortcut Dimension 1 Code", "Shortcut Dimension 1 Code");
            end;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
                Modify;
            end;
        }
        field(103; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                LookUpShortcutDimCode(2, "Shortcut Dimension 2 Code");
                Validate("Shortcut Dimension 2 Code", "Shortcut Dimension 2 Code");
            end;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
                Modify;
            end;
        }
        field(104; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location.Code;
            DataClassification = CustomerContent;
        }
        field(105; "Money bag no."; Code[20])
        {
            Caption = 'Money bag no.';
            DataClassification = CustomerContent;
        }
        field(106; "Alternative Register No."; Code[20])
        {
            Caption = 'Alternative Cash Register No.';
            DataClassification = CustomerContent;
        }
        field(107; "Sales (Qty)"; Integer)
        {
            Caption = 'No. of sales';
            DataClassification = CustomerContent;
        }
        field(108; "Sales (LCY)"; Decimal)
        {
            Caption = 'Total sales amount';
            DataClassification = CustomerContent;
        }
        field(109; "Cancelled Sales"; Integer)
        {
            Caption = 'Cancelled sales';
            DataClassification = CustomerContent;
        }
        field(110; "Campaign Discount (LCY)"; Decimal)
        {
            Caption = 'Campaign Discount';
            DataClassification = CustomerContent;
        }
        field(111; "Mix Discount (LCY)"; Decimal)
        {
            Caption = 'Mix Discount';
            DataClassification = CustomerContent;
        }
        field(112; "Quantity Discount (LCY)"; Decimal)
        {
            Caption = 'Quantity Discount';
            DataClassification = CustomerContent;
        }
        field(113; "Line Discount (LCY)"; Decimal)
        {
            Caption = 'Line Discount';
            DataClassification = CustomerContent;
        }
        field(114; "Custom Discount (LCY)"; Decimal)
        {
            Caption = 'Custom Discount';
            DataClassification = CustomerContent;
        }
        field(115; "Total Discount (LCY)"; Decimal)
        {
            Caption = 'Total Discount';
            DataClassification = CustomerContent;
        }
        field(116; "Net Turnover (LCY)"; Decimal)
        {
            Caption = 'Net Turnover';
            DataClassification = CustomerContent;
        }
        field(117; "Net Cost (LCY)"; Decimal)
        {
            Caption = 'Net Cost';
            DataClassification = CustomerContent;
        }
        field(118; "Currencies Amount (LCY)"; Decimal)
        {
            Caption = 'Currencies Amount';
            DataClassification = CustomerContent;
        }
        field(119; "Profit Amount (LCY)"; Decimal)
        {
            Caption = 'Profit Amount';
            DataClassification = CustomerContent;
        }
        field(120; "Profit %"; Decimal)
        {
            Caption = 'Profit %';
            DataClassification = CustomerContent;
        }
        field(121; "Turnover Including VAT"; Decimal)
        {
            Caption = 'Turnover Including VAT';
            DataClassification = CustomerContent;
        }
        field(125; "Debit Sales (Qty)"; Integer)
        {
            Caption = 'Debit Sales (Qty)';
            DataClassification = CustomerContent;
        }
        field(130; "Item Return Amount (LCY)"; Decimal)
        {
            Caption = 'Item Return Amount (LCY)';
            DataClassification = CustomerContent;
        }
        field(131; "Item Return Quantity"; Decimal)
        {
            Caption = 'Item Return Quantity';
            DataClassification = CustomerContent;
        }
        field(150; "No. Of Goods Sold"; Decimal)
        {
            Caption = 'No. Of Goods Sold';
            Description = 'Statistics made for swedish black box';
            DataClassification = CustomerContent;
        }
        field(151; "No. Of Cash Receipts"; Decimal)
        {
            Caption = 'No. Of Cash Receipts';
            Description = 'Statistics made for swedish black box';
            DataClassification = CustomerContent;
        }
        field(152; "No. Of Cash Box Openings"; Decimal)
        {
            Caption = 'No. Of Cash Box Openings';
            Description = 'Statistics made for swedish black box';
            DataClassification = CustomerContent;
        }
        field(153; "No. Of Receipt Copies"; Decimal)
        {
            Caption = 'No. Of Receipt Copies';
            Description = 'Statistics made for swedish black box';
            DataClassification = CustomerContent;
        }
        field(160; "VAT Info String"; Text[100])
        {
            Caption = 'VAT Info String';
            Description = 'Statistics made for swedish black box';
            DataClassification = CustomerContent;
        }
        field(165; "Order Amount"; Decimal)
        {
            Caption = 'Order Amount';
            DataClassification = CustomerContent;
        }
        field(166; "Invoice Amount"; Decimal)
        {
            Caption = 'Invoice Amount';
            DataClassification = CustomerContent;
        }
        field(167; "Return Amount"; Decimal)
        {
            Caption = 'Return Amount';
            DataClassification = CustomerContent;
        }
        field(168; "Credit Memo Amount"; Decimal)
        {
            Caption = 'Credit Memo Amount';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Register No.", "Sales Ticket No.", "No.")
        {
        }
        key(Key2; Status)
        {
        }
        key(Key3; "Register No.", Register, "Sales Ticket No.")
        {
        }
        key(Key4; "Register No.", Status, "No.")
        {
        }
        key(Key5; "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Location Code")
        {
        }
        key(Key6; "Sales Ticket No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if Period.Find('+') then
            "No." := Period."No." + 1
        else
            "No." := 1;
    end;

    var
        Text1060000: Label 'Ending time for period %1 must be after %2 o''clock';
        Period: Record "NPR Period";
        NPRDimMgt: Codeunit "NPR Dimension Mgt.";

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        NPRDimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        NPRDimMgt.SaveDefaultDim(DATABASE::"NPR POS Unit", "Register No.", FieldNumber, ShortcutDimCode);
        Modify;
    end;

    procedure LookUpShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        NPRDimMgt.LookupDimValueCode(FieldNumber, ShortcutDimCode);
    end;
}

