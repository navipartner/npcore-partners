table 6014577 "NPR Package Shipping Agent"
{
    DataCaptionFields = "Code", Name;
    DrillDownPageID = "Shipping Agents";
    LookupPageID = "Shipping Agents";

    fields
    {
        field(1; "Code"; Code[10])
        {

            NotBlank = true;
            TableRelation = "Shipping Agent".Code;
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[50])
        {
            CalcFormula = Lookup("Shipping Agent".Name WHERE(Code = FIELD(Code)));
            FieldClass = FlowField;
        }
        field(10; "Ship to Contact Mandatory"; Boolean)
        {
            Caption = 'Ship to Contact Mandatory';
            DataClassification = CustomerContent;
        }
        field(20; "Automatic Drop Point Service"; Boolean)
        {
            Caption = 'Auto Drop Point Service';
            DataClassification = CustomerContent;
        }
        field(50; "Use own Agreement"; Boolean)
        {
            Caption = 'Use own Agreement';
            DataClassification = CustomerContent;
        }
        field(51; "Package Type Required"; Boolean)
        {
            Caption = 'Package Type Required';
            DataClassification = CustomerContent;
        }
        field(60; "Email Mandatory"; Boolean)
        {
            Caption = 'Email Mandatory';
            DataClassification = CustomerContent;

        }
        field(61; "Phone Mandatory"; Boolean)
        {
            Caption = 'Phone Mandatory';
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

    trigger OnDelete();
    var
        ShippingAgentServices: Record "Shipping Agent Services";
    begin
    end;
}

