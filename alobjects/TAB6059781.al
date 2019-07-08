table 6059781 "Sales Price Maintenance Setup"
{
    // NPR5.25/CLVA/20160628 CASE 244461 : Sales Price Maintenance
    // NPR5.29/TS  /20170116 CASE 257404 : Change DrillDown Page
    // NPR5.33/CLVA/20170607 CASE 272906 : Added fields "Exclude Item Groups" and "Exclude All Item Groups"

    Caption = 'Sales Price Maintenance Setup';
    DrillDownPageID = "Sales Price Maintenance Setup";
    LookupPageID = "Sales Price Maintenance Setup";

    fields
    {
        field(1;Id;Integer)
        {
            Caption = 'Id';
        }
        field(10;"Sales Code";Code[20])
        {
            Caption = 'Sales Code';
            TableRelation = IF ("Sales Type"=CONST("Customer Price Group")) "Customer Price Group"
                            ELSE IF ("Sales Type"=CONST(Customer)) Customer
                            ELSE IF ("Sales Type"=CONST(Campaign)) Campaign;
            ValidateTableRelation = false;
        }
        field(11;"Sales Type";Option)
        {
            Caption = 'Sales Type';
            OptionCaption = 'Customer,Customer Price Group,All Customers,Campaign';
            OptionMembers = Customer,"Customer Price Group","All Customers",Campaign;

            trigger OnValidate()
            begin
                if "Sales Type" = "Sales Type"::Campaign then
                  Error(Txt003);
            end;
        }
        field(12;"Currency Code";Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(13;"Prices Including VAT";Boolean)
        {
            Caption = 'Prices Including VAT';
        }
        field(14;"Allow Invoice Disc.";Boolean)
        {
            Caption = 'Allow Invoice Disc.';
        }
        field(15;"Allow Line Disc.";Boolean)
        {
            Caption = 'Allow Line Disc.';
        }
        field(16;"Internal Unit Price";Option)
        {
            Caption = 'Internal Unit Price';
            OptionCaption = 'Unit Price,Unit Cost,Standard Cost,Last Direct Cost';
            OptionMembers = "Unit Price","Unit Cost","Standard Cost","Last Direct Cost";
        }
        field(17;Factor;Decimal)
        {
            Caption = 'Factor';
        }
        field(18;"VAT Bus. Posting Gr. (Price)";Code[10])
        {
            Caption = 'VAT Bus. Posting Gr. (Price)';
            TableRelation = "VAT Business Posting Group";

            trigger OnValidate()
            begin
                if "Sales Type" = "Sales Type"::"All Customers" then begin
                  "Sales Code" := '';
                  if not "Prices Including VAT" then begin
                    "VAT Bus. Posting Gr. (Price)" := '';
                    Message(Txt001);
                  end;
                end else begin
                  "VAT Bus. Posting Gr. (Price)" := '';
                  Message(Txt002);
                end;
            end;
        }
        field(19;"Exclude Item Groups";Integer)
        {
            CalcFormula = Count("Sales Price Maintenance Groups" WHERE (Id=FIELD(Id)));
            Caption = 'Exclude Item Groups';
            FieldClass = FlowField;
        }
        field(20;"Exclude All Item Groups";Boolean)
        {
            Caption = 'Exclude All Item Groups';
        }
    }

    keys
    {
        key(Key1;Id)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if "Sales Type" = "Sales Type"::"All Customers" then begin
          "Sales Code" := '';
          if "Prices Including VAT" then
            TestField("VAT Bus. Posting Gr. (Price)");
        end else
          TestField("Sales Code");

        if "Sales Type" = "Sales Type"::Campaign then
          Error(Txt003);
    end;

    var
        Txt001: Label 'When using "VAT Bus. Posting Gr. (Price)" "Price Includes VAT" must be set to True';
        Txt002: Label '"Sales Type" must be set to "All Customers" when using "VAT Bus. Posting Gr. (Price)"';
        Txt003: Label '"Sales Type" Campaign is not in use';
}

