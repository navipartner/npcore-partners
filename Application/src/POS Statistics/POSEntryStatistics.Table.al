table 6014620 "NPR POS Entry Statistics"
{
    DataClassification = CustomerContent;
    TableType = Temporary;
    Caption = 'POS Entry Statistics';

    fields
    {
        field(1; "Source System Id"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Source System Id';
        }
        field(2; "Source Table Id"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Source Table Id';
        }
        field(3; "Data Caption"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Data Caption';
        }
        field(20; "Payment Amount"; Decimal)
        {
            CalcFormula = Sum("NPR POS Entry Payment Line"."Amount (LCY)" WHERE("POS Store Code" = field("POS Store Filter"),
                                                                        "POS Unit No." = FIELD("POS Unit Filter"),
                                                                        "POS Payment Method Code" = field("POS Payment Method Filter"),
                                                                        "Document No." = FIELD("Document Filter"),
                                                                        "Entry Date" = FIELD("Date Filter"),
                                                                         "Shortcut Dimension 1 Code" = FIELD("Global Dimension Code 1 Filter"),
                                                                         "Shortcut Dimension 2 Code" = FIELD("Global Dimension Code 2 Filter")));
            Caption = 'Payment Amount';
            FieldClass = FlowField;
            Editable = false;
        }
        field(21; "Tax Payment Amount"; Decimal)
        {
            CalcFormula = Sum("NPR POS Entry Payment Line"."VAT Amount (LCY)" WHERE("POS Store Code" = field("POS Store Filter"),
                                                                        "POS Unit No." = FIELD("POS Unit Filter"),
                                                                        "POS Payment Method Code" = field("POS Payment Method Filter"),
                                                                        "Document No." = FIELD("Document Filter"),
                                                                        "Entry Date" = FIELD("Date Filter"),
                                                                         "Shortcut Dimension 1 Code" = FIELD("Global Dimension Code 1 Filter"),
                                                                         "Shortcut Dimension 2 Code" = FIELD("Global Dimension Code 2 Filter")));
            Caption = 'Tax Amount';
            FieldClass = FlowField;
            Editable = false;
        }
        field(22; "Tax Payment Base Amount"; Decimal)
        {
            CalcFormula = Sum("NPR POS Entry Payment Line"."VAT Base Amount (LCY)" WHERE("POS Store Code" = field("POS Store Filter"),
                                                                        "POS Unit No." = FIELD("POS Unit Filter"),
                                                                        "POS Payment Method Code" = field("POS Payment Method Filter"),
                                                                        "Document No." = FIELD("Document Filter"),
                                                                        "Entry Date" = FIELD("Date Filter"),
                                                                         "Shortcut Dimension 1 Code" = FIELD("Global Dimension Code 1 Filter"),
                                                                         "Shortcut Dimension 2 Code" = FIELD("Global Dimension Code 2 Filter")));
            Caption = 'Tax Base Amount';
            FieldClass = FlowField;
            Editable = false;
        }
        field(23; "Direct Sale Amount Excl. Tax"; Decimal)
        {
            CalcFormula = Sum("NPR POS Entry"."Amount Excl. Tax" WHERE("POS Store Code" = field("POS Store Filter"),
                                                                        "POS Unit No." = FIELD("POS Unit Filter"),
                                                                        "Entry Type" = const("Direct Sale"),
                                                                        "Document No." = FIELD("Document Filter"),
                                                                        "Entry Date" = FIELD("Date Filter"),
                                                                         "Shortcut Dimension 1 Code" = FIELD("Global Dimension Code 1 Filter"),
                                                                         "Shortcut Dimension 2 Code" = FIELD("Global Dimension Code 2 Filter")));
            Caption = 'Direct Sale Amount excl. Tax';
            FieldClass = FlowField;
            Editable = false;
        }
        field(24; "Direct Sale Amount Incl. Tax"; Decimal)
        {
            CalcFormula = Sum("NPR POS Entry"."Amount Incl. Tax" WHERE("POS Store Code" = field("POS Store Filter"),
                                                                        "POS Unit No." = FIELD("POS Unit Filter"),
                                                                        "Entry Type" = const("Direct Sale"),
                                                                        "Document No." = FIELD("Document Filter"),
                                                                        "Entry Date" = FIELD("Date Filter"),
                                                                         "Shortcut Dimension 1 Code" = FIELD("Global Dimension Code 1 Filter"),
                                                                         "Shortcut Dimension 2 Code" = FIELD("Global Dimension Code 2 Filter")));
            Caption = 'Direct Sale Amount incl. Tax';
            FieldClass = FlowField;
            Editable = false;
        }
        field(25; "Credit Sale Amount Excl. Tax"; Decimal)
        {
            CalcFormula = Sum("NPR POS Entry"."Amount Excl. Tax" WHERE("POS Store Code" = field("POS Store Filter"),
                                                                        "POS Unit No." = FIELD("POS Unit Filter"),
                                                                        "Entry Type" = const("Credit Sale"),
                                                                        "Document No." = FIELD("Document Filter"),
                                                                        "Entry Date" = FIELD("Date Filter"),
                                                                         "Shortcut Dimension 1 Code" = FIELD("Global Dimension Code 1 Filter"),
                                                                         "Shortcut Dimension 2 Code" = FIELD("Global Dimension Code 2 Filter")));
            Caption = 'Credit Sale Amount excl. Tax';
            FieldClass = FlowField;
            Editable = false;
        }
        field(26; "Credit Sale Amount Incl. Tax"; Decimal)
        {
            CalcFormula = Sum("NPR POS Entry"."Amount Incl. Tax" WHERE("POS Store Code" = field("POS Store Filter"),
                                                                        "POS Unit No." = FIELD("POS Unit Filter"),
                                                                        "Entry Type" = const("Credit Sale"),
                                                                        "Document No." = FIELD("Document Filter"),
                                                                        "Entry Date" = FIELD("Date Filter"),
                                                                         "Shortcut Dimension 1 Code" = FIELD("Global Dimension Code 1 Filter"),
                                                                         "Shortcut Dimension 2 Code" = FIELD("Global Dimension Code 2 Filter")));
            Caption = 'Credit Sale Amount incl. Tax';
            FieldClass = FlowField;
            Editable = false;
        }
        field(27; "Debit Sale Amount Excl. Tax"; Decimal)
        {
            CalcFormula = Sum("NPR POS Entry"."Amount Excl. Tax" WHERE("POS Store Code" = field("POS Store Filter"),
                                                                        "POS Unit No." = FIELD("POS Unit Filter"),
                                                                        "Entry Type" = const(Other),
                                                                        "Customer No." = field("Customer Filter"),
                                                                        "Document No." = FIELD("Document Filter"),
                                                                        "Entry Date" = FIELD("Date Filter"),
                                                                         "Shortcut Dimension 1 Code" = FIELD("Global Dimension Code 1 Filter"),
                                                                         "Shortcut Dimension 2 Code" = FIELD("Global Dimension Code 2 Filter")));
            Caption = 'Debit Sale Amount excl. Tax';
            FieldClass = FlowField;
            Editable = false;
        }
        field(28; "Debit Sale Amount Incl. Tax"; Decimal)
        {
            CalcFormula = Sum("NPR POS Entry"."Amount Incl. Tax" WHERE("POS Store Code" = field("POS Store Filter"),
                                                                        "POS Unit No." = FIELD("POS Unit Filter"),
                                                                        "Entry Type" = const(Other),
                                                                        "Customer No." = field("Customer Filter"),
                                                                        "Document No." = FIELD("Document Filter"),
                                                                        "Entry Date" = FIELD("Date Filter"),
                                                                         "Shortcut Dimension 1 Code" = FIELD("Global Dimension Code 1 Filter"),
                                                                         "Shortcut Dimension 2 Code" = FIELD("Global Dimension Code 2 Filter")));
            Caption = 'Debit Sale Amount incl. Tax';
            FieldClass = FlowField;
            Editable = false;
        }
        field(29; "Balancing Amount Excl. Tax"; Decimal)
        {
            CalcFormula = Sum("NPR POS Entry"."Amount Excl. Tax" WHERE("POS Store Code" = field("POS Store Filter"),
                                                                        "POS Unit No." = FIELD("POS Unit Filter"),
                                                                        "Entry Type" = const(Other),
                                                                        "Customer No." = field("Customer Filter"),
                                                                        "Document No." = FIELD("Document Filter"),
                                                                        "Entry Date" = FIELD("Date Filter"),
                                                                         "Shortcut Dimension 1 Code" = FIELD("Global Dimension Code 1 Filter"),
                                                                         "Shortcut Dimension 2 Code" = FIELD("Global Dimension Code 2 Filter")));
            Caption = 'Balancing Amount excl. Tax';
            FieldClass = FlowField;
            Editable = false;
        }
        field(30; "Balancing Amount Incl. Tax"; Decimal)
        {
            CalcFormula = Sum("NPR POS Entry"."Amount Incl. Tax" WHERE("POS Store Code" = field("POS Store Filter"),
                                                                        "POS Unit No." = FIELD("POS Unit Filter"),
                                                                        "Entry Type" = const(Other),
                                                                        "Customer No." = field("Customer Filter"),
                                                                        "Document No." = FIELD("Document Filter"),
                                                                        "Entry Date" = FIELD("Date Filter"),
                                                                         "Shortcut Dimension 1 Code" = FIELD("Global Dimension Code 1 Filter"),
                                                                         "Shortcut Dimension 2 Code" = FIELD("Global Dimension Code 2 Filter")));
            Caption = 'Balancing Amount incl. Tax';
            FieldClass = FlowField;
            Editable = false;
        }
        field(100; "POS Unit Filter"; Code[10])
        {
            Caption = 'POS Unit Filter';
            FieldClass = FlowFilter;
            TableRelation = "NPR POS Unit";
        }
        field(101; "Document Filter"; Code[20])
        {
            Caption = 'Document Filter';
            FieldClass = FlowFilter;
        }
        field(102; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(103; "Global Dimension Code 1 Filter"; Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension Code 1 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(104; "Global Dimension Code 2 Filter"; Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension Code 2 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(105; "POS Payment Method Filter"; Code[20])
        {
            Caption = 'POS Payment Method Filter';
            FieldClass = FlowFilter;
            TableRelation = "NPR POS Payment Method".Code;
        }
        field(106; "Salesperson Filter"; Code[20])
        {
            Caption = 'Salesperson filter';
            FieldClass = FlowFilter;
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(107; "POS Store Filter"; Code[10])
        {
            Caption = 'POS Store Filter';
            FieldClass = FlowFilter;
            TableRelation = "NPR POS Store".Code;
        }
        field(108; "Customer Filter"; Code[20])
        {
            Caption = 'Customer Filter';
            FieldClass = FlowFilter;
            TableRelation = Customer."No.";
        }
    }

    keys
    {
        key(Key1; "Source System Id")
        {
            Clustered = true;
        }
    }

    procedure Calculate(Source: Variant)
    var
        RecRef: RecordRef;
        FieldReference: FieldRef;
        DataTypeMgt: Codeunit "Data Type Management";
    begin
        InsertRecord(Source);
        if not DataTypeMgt.GetRecordRef(Source, RecRef) then
            exit;
        if DataTypeMgt.FindFieldByName(RecRef, FieldReference, 'POS Store Code') then begin
            Rec.SetFilter("POS Store Filter", FieldReference.GetFilter());
        end;
        if DataTypeMgt.FindFieldByName(RecRef, FieldReference, 'POS Unit No.') then begin
            Rec.SetFilter("POS Unit Filter", FieldReference.GetFilter());
        end;
        if DataTypeMgt.FindFieldByName(RecRef, FieldReference, 'POS Payment Method Code') then begin
            Rec.SetFilter("POS Payment Method Filter", FieldReference.GetFilter());
        end;
        if DataTypeMgt.FindFieldByName(RecRef, FieldReference, 'Document No.') then begin
            Rec.SetFilter("Document Filter", FieldReference.GetFilter());
        end;
        if DataTypeMgt.FindFieldByName(RecRef, FieldReference, 'Entry Date') then begin
            Rec.SetFilter("Date Filter", FieldReference.GetFilter());
        end;
        if DataTypeMgt.FindFieldByName(RecRef, FieldReference, 'Shortcut Dimension 1 Code') then begin
            Rec.SetFilter("Global Dimension Code 1 Filter", FieldReference.GetFilter());
        end;
        if DataTypeMgt.FindFieldByName(RecRef, FieldReference, 'Shortcut Dimension 2 Code') then begin
            Rec.SetFilter("Global Dimension Code 2 Filter", FieldReference.GetFilter());
        end;
        if DataTypeMgt.FindFieldByName(RecRef, FieldReference, 'Customer No.') then begin
            Rec.SetFilter("Customer Filter", FieldReference.GetFilter());
        end;
        OnBeforeCalcFields();
        CalcRecFields();
    end;

    procedure InsertRecord(Source: Variant)
    var
        RecRef: RecordRef;
        FieldReference: FieldRef;
        DataTypeMgt: Codeunit "Data Type Management";
    begin
        DataTypeMgt.GetRecordRef(Source, RecRef);
        DataTypeMgt.FindFieldByName(RecRef, FieldReference, '$systemId');
        Rec."Source System Id" := FieldReference.Value();
        Rec.Init();
        Rec."Source Table Id" := RecRef.Number();
        if Rec.Insert() then;
    end;

    procedure CalcRecFields()
    begin
        Rec.CalcFields("Payment Amount", "Tax Payment Amount", "Tax Payment Base Amount",
                        "Direct Sale Amount Excl. Tax", "Direct Sale Amount Incl. Tax",
                        "Credit Sale Amount Excl. Tax", "Credit Sale Amount Incl. Tax",
                        "Debit Sale Amount Excl. Tax", "Debit Sale Amount Incl. Tax",
                        "Balancing Amount Excl. Tax", "Balancing Amount Incl. Tax");
    end;

    procedure GetPageId(): Integer
    begin
        exit(Page::"NPR POS Entry Statistics");
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCalcFields()
    begin
    end;
}