table 6060083 "MCS Recommendations Log"
{
    // NPR5.30/BR  /20170220  CASE 252646 Object Created

    Caption = 'MCS Recommendations Log';
    DrillDownPageID = "MCS Recommendations Log";
    LookupPageID = "MCS Recommendations Log";

    fields
    {
        field(10;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            Editable = false;
        }
        field(20;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Business Rule,Catalog,Usage,Recommendation Request,Selected Recommendation';
            OptionMembers = BusinessRule,Catalog,Usage,RecommendationRequest,SelectRecommendation;
        }
        field(30;"Start Date Time";DateTime)
        {
            Caption = 'Start Date Time';
        }
        field(40;"End Date Time";DateTime)
        {
            Caption = 'End Date Time';
        }
        field(50;Response;Text[150])
        {
            Caption = 'Response';
        }
        field(60;Success;Boolean)
        {
            Caption = 'Success';
        }
        field(100;"Model No.";Code[10])
        {
            Caption = 'Model No.';
            TableRelation = "MCS Recommendations Model";
        }
        field(110;"Seed Item No.";Code[20])
        {
            Caption = 'Seed Item No.';
            TableRelation = Item;
        }
        field(120;"Selected Item";Code[20])
        {
            Caption = 'Selected Recommendation Item';
        }
        field(130;"Selected Rating";Decimal)
        {
            AutoFormatExpression = '<precision,0:2><Standard Format,0>%';
            AutoFormatType = 10;
            Caption = 'Rating';
        }
        field(200;"Table No.";Integer)
        {
            Caption = 'Table No.';
        }
        field(210;"Document Type";Integer)
        {
            Caption = 'Document Type';
        }
        field(220;"Document No.";Code[20])
        {
            Caption = 'Document No.';
        }
        field(230;"Document Line No.";Integer)
        {
            Caption = 'Document Line No.';
        }
        field(240;"Register No.";Code[10])
        {
            Caption = 'Register No.';
        }
        field(250;"Customer No.";Code[20])
        {
            Caption = 'Customer No.';
        }
        field(260;"Document Date";Date)
        {
            Caption = 'Document Date';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

