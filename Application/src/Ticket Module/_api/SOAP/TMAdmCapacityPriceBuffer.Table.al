table 6060016 "NPR TM AdmCapacityPriceBuffer"
{
    DataClassification = CustomerContent;
    TableType = Temporary;
    Caption = 'Admission Capacity Price Buffer';
    Access = Internal;

    fields
    {
        field(1; EntryNo; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; AdmissionCode; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(10; RequestId; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(100; DefaultAdmissionCode; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(115; ItemReference; Code[50])
        {
            DataClassification = CustomerContent;
        }
        field(116; ItemNumber; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(117; VariantCode; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(120; CustomerNo; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(130; ReferenceDate; Date)
        {
            DataClassification = CustomerContent;
        }
        field(135; Quantity; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(200; UnitPrice; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(205; UnitPriceIncludesVat; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(206; UnitPriceVatPercentage; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(210; DiscountPct; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(220; TotalDiscountAmount; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(230; DefaultAdmission; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(231; AdmissionInclusion; Option)
        {
            DataClassification = CustomerContent;
            OptionCaption = 'Required,Optional and Selected,Optional and not Selected';
            OptionMembers = REQUIRED,SELECTED,NOT_SELECTED;
        }
    }

    keys
    {
        key(Key1; EntryNo, AdmissionCode)
        {
            Clustered = true;
        }
    }

}