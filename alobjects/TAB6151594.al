table 6151594 "NpDc Coupon Module"
{
    // NPR5.34/MHA /20170720  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon

    Caption = 'Coupon Module';
    DataCaptionFields = "Code",Description;
    DrillDownPageID = "NpDc Coupon Modules";
    LookupPageID = "NpDc Coupon Modules";

    fields
    {
        field(1;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Issue Coupon,Validate Coupon,Apply Discount';
            OptionMembers = "Issue Coupon","Validate Coupon","Apply Discount";
        }
        field(5;"Code";Code[20])
        {
            Caption = 'Code';
        }
        field(10;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(50;"Event Codeunit ID";Integer)
        {
            Caption = 'Event Codeunit ID';
        }
        field(55;"Event Codeunit Name";Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE ("Object Type"=CONST(Codeunit),
                                                             "Object ID"=FIELD("Event Codeunit ID")));
            Caption = 'Event Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;Type,"Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown;"Code",Description)
        {
        }
    }
}

