table 6059892 "Npm Page View"
{
    // NPR5.33/MHA /20170126  CASE 264348 Object created - Module: Np Page Manager

    Caption = 'Npm View Condition';

    fields
    {
        field(1;"Page ID";Integer)
        {
            Caption = 'Page ID';
            MinValue = 1;
            TableRelation = "Npm Page";
        }
        field(5;"View Code";Code[20])
        {
            Caption = 'View Code';
            NotBlank = true;

            trigger OnLookup()
            var
                NpmPage: Record "Npm Page";
                NpmView: Record "Npm View";
            begin
                NpmPage.Get("Page ID");
                NpmView.SetRange("Table No.",NpmPage."Source Table No.");
                if PAGE.RunModal(0,NpmView) <> ACTION::LookupOK then
                  exit;

                Validate("View Code",NpmView.Code);
            end;

            trigger OnValidate()
            var
                NpmPage: Record "Npm Page";
                NpmView: Record "Npm View";
            begin
                NpmPage.Get("Page ID");
                NpmView.Get(NpmPage."Source Table No.","View Code");
            end;
        }
        field(10;"Source Table No.";Integer)
        {
            CalcFormula = Lookup("Npm Page"."Source Table No." WHERE ("Page ID"=FIELD("Page ID")));
            Caption = 'Source Table No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(100;"Show Mandatory Fields";Boolean)
        {
            Caption = 'Show Mandatory Fields';
        }
        field(105;"Show Field Captions";Boolean)
        {
            Caption = 'Show Field Captions';
        }
    }

    keys
    {
        key(Key1;"Page ID","View Code")
        {
        }
    }

    fieldgroups
    {
    }
}

