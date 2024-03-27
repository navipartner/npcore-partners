#if not BC17
table 6150810 "NPR Spfy Store"
{
    Access = Internal;
    Caption = 'Shopify Store';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR Spfy Stores";
    LookupPageId = "NPR Spfy Stores";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
        field(20; "Shopify Url"; Text[250])
        {
            Caption = 'Shopify Url';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
        }
        field(21; "Shopify Access Token"; Text[100])
        {
            Caption = 'Shopify Access Token';
            DataClassification = CustomerContent;
        }
        field(30; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(40; "Get Orders Starting From"; DateTime)
        {
            Caption = 'Get Orders Starting From';
            DataClassification = CustomerContent;
        }
        field(50; "Last Orders Imported At"; DateTime)
        {
            Caption = 'Last Orders Imported At';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    trigger OnRename()
    var
        RecordCannotBeRenamedErr: Label '%1 record cannot be renamed.';
    begin
        Error(RecordCannotBeRenamedErr, Rec.TableCaption);
    end;
}
#endif