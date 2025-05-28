table 6151591 "NPR NpDc Coupon"
{
    Caption = 'Coupon';
    DataClassification = CustomerContent;
    DataCaptionFields = "No.", "Coupon Type", Description;
    DrillDownPageID = "NPR NpDc Coupons";
    LookupPageID = "NPR NpDc Coupons";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(5; "Coupon Type"; Code[20])
        {
            Caption = 'Coupon Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpDc Coupon Type";

            trigger OnValidate()
            begin
                CopyFromCouponType();
            end;
        }
        field(10; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(15; "Reference No."; Text[50])
        {
            Caption = 'Reference No.';
            DataClassification = CustomerContent;
        }
        field(17; "Discount Type"; Option)
        {
            Caption = 'Discount Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Discount Amount,Discount %';
            OptionMembers = "Discount Amount","Discount %";
        }
        field(20; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(22; "Max. Discount Amount"; Decimal)
        {
            BlankZero = true;
            Caption = 'Max. Discount Amount';
            DataClassification = CustomerContent;
        }
        field(25; "Discount Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Discount Amount';
            DataClassification = CustomerContent;
        }
        field(30; "Starting Date"; DateTime)
        {
            Caption = 'Starting Date';
            DataClassification = CustomerContent;
        }
        field(35; "Ending Date"; DateTime)
        {
            Caption = 'Ending Date';
            DataClassification = CustomerContent;
        }
        field(40; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(43; "Arch. No."; Code[20])
        {
            Caption = 'Archivation No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.37';
        }
        field(50; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(53; "Max Use per Sale"; Integer)
        {
            Caption = 'Max Use per Sale';
            DataClassification = CustomerContent;
            InitValue = 1;
            MinValue = 1;
        }
        field(65; "Print Template Code"; Code[20])
        {
            Caption = 'Print Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR RP Template Header" WHERE("Table ID" = CONST(6151591));
        }
        field(70; Open; Boolean)
        {
            CalcFormula = Max("NPR NpDc Coupon Entry".Open WHERE("Coupon No." = FIELD("No.")));
            Caption = 'Open';
            Editable = false;
            FieldClass = FlowField;
        }
        field(75; "Remaining Quantity"; Decimal)
        {
            CalcFormula = Sum("NPR NpDc Coupon Entry"."Remaining Quantity" WHERE("Coupon No." = FIELD("No.")));
            Caption = 'Remaining Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(80; "In-use Quantity"; Integer)
        {
            CalcFormula = Count("NPR NpDc SaleLinePOS Coupon" WHERE(Type = CONST(Coupon),
                                                                   "Coupon No." = FIELD("No.")));
            Caption = 'In-use Quantity';
            Editable = false;
            FieldClass = FlowField;
        }
        field(85; "In-use Quantity (External)"; Integer)
        {
            CalcFormula = Count("NPR NpDc Ext. Coupon Reserv." WHERE("Coupon No." = FIELD("No.")));
            Caption = 'In-use Quantity (External)';
            Description = 'NPR5.51';
            Editable = false;
            FieldClass = FlowField;
        }
        field(100; "Issue Coupon Module"; Code[20])
        {
            CalcFormula = Lookup("NPR NpDc Coupon Type"."Issue Coupon Module" WHERE(Code = FIELD("Coupon Type")));
            Caption = 'Issue Coupon Module';
            Editable = false;
            FieldClass = FlowField;
        }
        field(110; "Validate Coupon Module"; Code[20])
        {
            CalcFormula = Lookup("NPR NpDc Coupon Type"."Validate Coupon Module" WHERE(Code = FIELD("Coupon Type")));
            Caption = 'Validate Coupon Module';
            Editable = false;
            FieldClass = FlowField;
        }
        field(120; "Apply Discount Module"; Code[20])
        {
            CalcFormula = Lookup("NPR NpDc Coupon Type"."Apply Discount Module" WHERE(Code = FIELD("Coupon Type")));
            Caption = 'Apply Discount Module';
            Editable = false;
            FieldClass = FlowField;
        }
        field(150; "POS Store Group"; Code[20])
        {
            Caption = 'POS Store Group';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Store Group";
        }
        field(160; "Coupon Issued"; Boolean)
        {
            CalcFormula = Exist("NPR NpDc Coupon Entry" WHERE("Coupon No." = FIELD("No."),
                                                              "Entry Type" = const("Issue Coupon")));
            Caption = 'Coupon Issued';
            Editable = false;
            FieldClass = FlowField;
        }
        field(161; "Issue Date"; Date)
        {
            CalcFormula = min("NPR NpDc Coupon Entry"."Posting Date" where("Coupon No." = field("No."),
                                                              "Entry Type" = const("Issue Coupon")));
            Caption = 'Issue Date';
            Editable = false;
            FieldClass = FlowField;
        }
        field(162; "Print Object Type"; Enum "NPR Print Object Type")
        {
            Caption = 'Print Object Type';
            DataClassification = CustomerContent;
            InitValue = Template;
        }
        field(163; "Print Object ID"; Integer)
        {
            Caption = 'Print Object ID';
            DataClassification = CustomerContent;
            TableRelation = IF ("Print Object Type" = CONST(Codeunit)) AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Codeunit)) ELSE
            IF ("Print Object Type" = CONST(Report)) AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Report));
            BlankZero = true;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "Coupon Type")
        {
        }
        key(Key3; "Reference No.")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", "Coupon Type", Description)
        {
        }
    }

    trigger OnDelete()
    var
        CouponEntry: Record "NPR NpDc Coupon Entry";
        SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcExtCouponSalesLine: Record "NPR NpDc Ext. Coupon Reserv.";
    begin
        CouponEntry.SetRange("Coupon No.", "No.");
        if not CouponEntry.IsEmpty() then
            CouponEntry.DeleteAll();

        SaleLinePOSCoupon.SetRange("Coupon No.", "No.");
        if not SaleLinePOSCoupon.IsEmpty() then
            SaleLinePOSCoupon.DeleteAll();

        NpDcExtCouponSalesLine.SetRange("Coupon No.", "No.");
        if not NpDcExtCouponSalesLine.IsEmpty() then
            NpDcExtCouponSalesLine.DeleteAll();
    end;

    trigger OnInsert()
    var
        CouponSetup: Record "NPR NpDc Coupon Setup";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesMgt: Codeunit "No. Series";
#ELSE
        NoSeriesMgt: Codeunit NoSeriesManagement;
#ENDIF
    begin
        TestField("Coupon Type");
        if "No." = '' then begin
            CouponSetup.Get();
            CouponSetup.TestField("Coupon No. Series");
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            "No. Series" := CouponSetup."Coupon No. Series";
            if NoSeriesMgt.AreRelated(CouponSetup."Coupon No. Series", xRec."No. Series") then
                "No. Series" := xRec."No. Series";
            "No." := NoSeriesMgt.GetNextNo("No. Series");
#ELSE
            NoSeriesMgt.InitSeries(CouponSetup."Coupon No. Series", xRec."No. Series", 0D, "No.", "No. Series");
#ENDIF
        end;
        TestReferenceNo();
    end;

    trigger OnModify()
    begin
        TestField("Coupon Type");
        TestReferenceNo();
    end;

    var
        ReferenceNoUsedErr: Label 'Reference No. %1 is already used!', Comment = '%1 = Reference no.';

    local procedure InitReferenceNo()
    var
        CouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
    begin
        "Reference No." := CopyStr(CouponMgt.GenerateReferenceNo(Rec), 1, MaxStrLen("Reference No."));
    end;

    local procedure TestReferenceNo()
    var
        Coupon: Record "NPR NpDc Coupon";
    begin
        if "Reference No." = '' then
            InitReferenceNo();

        TestField("Reference No.");

        Coupon.SetFilter("No.", '<>%1', "No.");
        Coupon.SetRange("Reference No.", "Reference No.");
        if not Coupon.IsEmpty() then
            Error(ReferenceNoUsedErr, "Reference No.");
    end;

    local procedure CopyFromCouponType()
    var
        CouponType: Record "NPR NpDc Coupon Type";
    begin
        if not CouponType.Get("Coupon Type") then
            exit;

        Description := CouponType.Description;
        "Starting Date" := CouponType."Starting Date";
        "Ending Date" := CouponType."Ending Date";
        "Customer No." := CouponType."Customer No.";
        "Discount Type" := CouponType."Discount Type";
        "Discount %" := CouponType."Discount %";
        "Max. Discount Amount" := CouponType."Max. Discount Amount";
        "Discount Amount" := CouponType."Discount Amount";
        "Max Use per Sale" := CouponType."Max Use per Sale";
        "Print Template Code" := CouponType."Print Template Code";
        "Print Object ID" := CouponType."Print Object ID";
        "Print Object Type" := CouponType."Print Object Type";
        "POS Store Group" := CouponType."POS Store Group";

        if ((Rec."Starting Date" = CreateDateTime(0D, 0T)) and (Format(CouponType."Starting Date DateFormula") <> '')) then
            Rec."Starting Date" := CreateDateTime(CalcDate(CouponType."Starting Date DateFormula"), 0T);
        if ((Rec."Ending Date" = CreateDateTime(0D, 0T)) and (Format(CouponType."Ending Date DateFormula") <> '')) then
            Rec."Ending Date" := CreateDateTime(CalcDate(CouponType."Ending Date DateFormula"), 235959T);
    end;

    internal procedure CalcInUseQty() InUseQty: Integer
    begin
        CalcFields("In-use Quantity", "In-use Quantity (External)");
        exit("In-use Quantity" + "In-use Quantity (External)");
    end;
}

