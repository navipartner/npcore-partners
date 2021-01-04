table 6151594 "NPR NpDc Coupon Module"
{
    Caption = 'Coupon Module';
    DataClassification = CustomerContent;
    DataCaptionFields = "Code", Description;
    DrillDownPageID = "NPR NpDc Coupon Modules";
    LookupPageID = "NPR NpDc Coupon Modules";

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Issue Coupon,Validate Coupon,Apply Discount';
            OptionMembers = "Issue Coupon","Validate Coupon","Apply Discount";
        }
        field(5; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(50; "Event Codeunit ID"; Integer)
        {
            Caption = 'Event Codeunit ID';
            DataClassification = CustomerContent;
        }
        field(55; "Event Codeunit Name"; Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Codeunit),
                                                             "Object ID" = FIELD("Event Codeunit ID")));
            Caption = 'Event Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; Type, "Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description)
        {
        }
    }
}

