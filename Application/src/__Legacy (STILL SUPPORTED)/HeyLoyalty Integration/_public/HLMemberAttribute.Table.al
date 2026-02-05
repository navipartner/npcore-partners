table 6059802 "NPR HL Member Attribute"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Public;
    Caption = 'HeyLoyalty Member Attribute';
    DrillDownPageID = "NPR HL Member Attributes";
    LookupPageID = "NPR HL Member Attributes";

    fields
    {
        field(1; "HeyLoyalty Member Entry No."; BigInteger)
        {
            Caption = 'HeyLoyalty Member Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR HL HeyLoyalty Member"."Entry No.";
        }
        field(2; "Attribute Code"; Code[20])
        {
            Caption = 'Attribute Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Attribute".Code;

            trigger OnValidate()
            begin
                if "Attribute Code" <> xRec."Attribute Code" then
                    Validate("Attribute Value Code", '');
            end;
        }
        field(3; "Attribute Value Code"; Code[20])
        {
            Caption = 'Attribute Value Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Attribute Lookup Value"."Attribute Value Code" where("Attribute Code" = field("Attribute Code"));

            trigger OnValidate()
            var
                NPRAttributeValue: Record "NPR Attribute Lookup Value";
                HLMappedValueMgt: Codeunit "NPR HL Mapped Value Mgt.";
            begin
                if NPRAttributeValue.Get("Attribute Code", "Attribute Value Code") then
                    "HeyLoyalty Attribute Value" := HLMappedValueMgt.GetMappedValue(NPRAttributeValue.RecordId, NPRAttributeValue.FieldNo("Attribute Value Name"), false)
                else
                    "HeyLoyalty Attribute Value" := '';
            end;
        }
        field(10; "Attribute Name"; Text[80])
        {
            Caption = 'Attribute Name';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Lookup("NPR Attribute".Description WHERE(Code = FIELD("Attribute Code")));
        }
        field(11; "Attribute Value Name"; Text[100])
        {
            Caption = 'Attribute Value Name';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Lookup("NPR Attribute Lookup Value"."Attribute Value Name" WHERE("Attribute Code" = FIELD("Attribute Code"), "Attribute Value Code" = FIELD("Attribute Value Code")));
        }
        field(20; "HeyLoyalty Attribute Value"; Text[100])
        {
            Caption = 'HeyLoyalty Attribute Value';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "HeyLoyalty Member Entry No.", "Attribute Code")
        {
            Clustered = true;
        }
    }
}