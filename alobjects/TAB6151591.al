table 6151591 "NpDc Coupon"
{
    // NPR5.34/MHA /20170720  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon
    // NPR5.37/MHA /20171023  CASE 293232 Renamed field 43 "Posting No." to "Arch. No."
    // NPR5.51/MHA /20190724 CASE 343352 Added field 85 "In-use Quantity (External)" and function CalcInUseQty()

    Caption = 'Coupon';
    DataCaptionFields = "No.","Coupon Type",Description;
    DrillDownPageID = "NpDc Coupons";
    LookupPageID = "NpDc Coupons";

    fields
    {
        field(1;"No.";Code[20])
        {
            Caption = 'No.';
        }
        field(5;"Coupon Type";Code[20])
        {
            Caption = 'Coupon Type';
            TableRelation = "NpDc Coupon Type";

            trigger OnValidate()
            var
                CouponType: Record "NpDc Coupon Type";
            begin
                CouponType.Get("Coupon Type");
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
            end;
        }
        field(10;Description;Text[30])
        {
            Caption = 'Description';
        }
        field(15;"Reference No.";Text[30])
        {
            Caption = 'Reference No.';
        }
        field(17;"Discount Type";Option)
        {
            Caption = 'Discount Type';
            OptionCaption = 'Discount Amount,Discount %';
            OptionMembers = "Discount Amount","Discount %";
        }
        field(20;"Discount %";Decimal)
        {
            Caption = 'Discount %';
            DecimalPlaces = 0:5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(22;"Max. Discount Amount";Decimal)
        {
            BlankZero = true;
            Caption = 'Max. Discount Amount';
        }
        field(25;"Discount Amount";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Discount Amount';
        }
        field(30;"Starting Date";DateTime)
        {
            Caption = 'Starting Date';
        }
        field(35;"Ending Date";DateTime)
        {
            Caption = 'Ending Date';
        }
        field(40;"No. Series";Code[10])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(43;"Arch. No.";Code[20])
        {
            Caption = 'Archivation No.';
            Description = 'NPR5.37';
        }
        field(50;"Customer No.";Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(53;"Max Use per Sale";Integer)
        {
            Caption = 'Max Use per Sale';
            InitValue = 1;
            MinValue = 1;
        }
        field(65;"Print Template Code";Code[20])
        {
            Caption = 'Print Template Code';
            TableRelation = "RP Template Header" WHERE ("Table ID"=CONST(6151591));
        }
        field(70;Open;Boolean)
        {
            CalcFormula = Max("NpDc Coupon Entry".Open WHERE ("Coupon No."=FIELD("No.")));
            Caption = 'Open';
            Editable = false;
            FieldClass = FlowField;
        }
        field(75;"Remaining Quantity";Decimal)
        {
            CalcFormula = Sum("NpDc Coupon Entry"."Remaining Quantity" WHERE ("Coupon No."=FIELD("No.")));
            Caption = 'Remaining Quantity';
            DecimalPlaces = 0:5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(80;"In-use Quantity";Integer)
        {
            CalcFormula = Count("NpDc Sale Line POS Coupon" WHERE (Type=CONST(Coupon),
                                                                   "Coupon No."=FIELD("No.")));
            Caption = 'In-use Quantity';
            Editable = false;
            FieldClass = FlowField;
        }
        field(85;"In-use Quantity (External)";Integer)
        {
            CalcFormula = Count("NpDc Ext. Coupon Reservation" WHERE ("Coupon No."=FIELD("No.")));
            Caption = 'In-use Quantity (External)';
            Description = 'NPR5.51';
            Editable = false;
            FieldClass = FlowField;
        }
        field(100;"Issue Coupon Module";Code[20])
        {
            CalcFormula = Lookup("NpDc Coupon Type"."Issue Coupon Module" WHERE (Code=FIELD("Coupon Type")));
            Caption = 'Issue Coupon Module';
            Editable = false;
            FieldClass = FlowField;
        }
        field(110;"Validate Coupon Module";Code[20])
        {
            CalcFormula = Lookup("NpDc Coupon Type"."Validate Coupon Module" WHERE (Code=FIELD("Coupon Type")));
            Caption = 'Validate Coupon Module';
            Editable = false;
            FieldClass = FlowField;
        }
        field(120;"Apply Discount Module";Code[20])
        {
            CalcFormula = Lookup("NpDc Coupon Type"."Apply Discount Module" WHERE (Code=FIELD("Coupon Type")));
            Caption = 'Apply Discount Module';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
        key(Key2;"Coupon Type")
        {
        }
        key(Key3;"Reference No.")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown;"No.","Coupon Type",Description)
        {
        }
    }

    trigger OnDelete()
    var
        CouponEntry: Record "NpDc Coupon Entry";
        SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";
        NpDcExtCouponSalesLine: Record "NpDc Ext. Coupon Reservation";
    begin
        CouponEntry.SetRange("Coupon No.","No.");
        CouponEntry.DeleteAll;

        //-NPR5.51 [343352]
        SaleLinePOSCoupon.SetRange("Coupon No.","No.");
        if SaleLinePOSCoupon.FindFirst then
          SaleLinePOSCoupon.DeleteAll;

        NpDcExtCouponSalesLine.SetRange("Coupon No.","No.");
        if NpDcExtCouponSalesLine.FindFirst then
          NpDcExtCouponSalesLine.DeleteAll;
        //+NPR5.51 [343352]
    end;

    trigger OnInsert()
    var
        CouponSetup: Record "NpDc Coupon Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        TestField("Coupon Type");
        if "No." = '' then begin
          CouponSetup.Get;
          CouponSetup.TestField("Coupon No. Series");
          NoSeriesMgt.InitSeries(CouponSetup."Coupon No. Series",xRec."No. Series",0D,"No.","No. Series");
        end;
        TestReferenceNo();
    end;

    trigger OnModify()
    begin
        TestField("Coupon Type");
        TestReferenceNo();
    end;

    var
        Text000: Label 'Reference No. %1 is already used!';

    local procedure InitReferenceNo()
    var
        CouponMgt: Codeunit "NpDc Coupon Mgt.";
    begin
        "Reference No." := CouponMgt.GenerateReferenceNo(Rec);
    end;

    local procedure TestReferenceNo()
    var
        Coupon: Record "NpDc Coupon";
    begin
        if "Reference No." = '' then
          InitReferenceNo();

        TestField("Reference No.");

        Coupon.SetFilter("No.",'<>%1',"No.");
        Coupon.SetRange("Reference No.","Reference No.");
        if Coupon.FindFirst then
          Error(Text000,"Reference No.");
    end;

    procedure CalcInUseQty() InUseQty: Integer
    begin
        //-NPR5.51 [343352]
        CalcFields("In-use Quantity","In-use Quantity (External)");
        exit("In-use Quantity" + "In-use Quantity (External)");
        //+NPR5.51 [343352]
    end;
}

