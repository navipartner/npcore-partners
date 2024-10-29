table 6150946 "NPR TM DynamicPriceItemList"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Dynamic Price Item List';

    fields
    {
        field(1; ItemNo; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(2; VariantCode; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(3; AdmissionCode; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Admission";
        }
        field(4; ScheduleCode; Code[20])
        {
            Caption = 'Schedule Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Admis. Schedule";
        }

        field(10; ItemPriceCode; Code[10])
        {
            Caption = 'Item Price Profile Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Dynamic Price Profile".ProfileCode;
        }
        field(100; AdmissionSchedulePriceCode; Code[10])
        {
            Caption = 'Admission Schedule Price Profile Code';
            FieldClass = FlowField;
            CalcFormula = LOOKUP("NPR TM Admis. Schedule Lines"."Dynamic Price Profile Code" WHERE("Admission Code" = FIELD(AdmissionCode), "Schedule Code" = FIELD(ScheduleCode)));
            Editable = false;
        }
    }

    keys
    {
        key(Key1; ItemNo, VariantCode, AdmissionCode, ScheduleCode)
        {
            Clustered = true;
        }
        key(Key2; AdmissionCode, ScheduleCode, ItemNo, VariantCode)
        {
            Clustered = false;
        }
    }

}