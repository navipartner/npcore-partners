table 6014667 "NPR TM Price Rule Buffer"
{
    TableType = Temporary;
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; ExtAdmissionScheduleEntryNo; Integer)
        {
            Caption = 'External Admission Schedule Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; AdmissionCode; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
        }
        field(12; AdmissionInclusion; Option)
        {
            Caption = 'Admission Inclusion';
            DataClassification = CustomerContent;
            OptionCaption = 'Required,Optional and Selected,Optional and not Selected';
            OptionMembers = REQUIRED,SELECTED,NOT_SELECTED;
        }
        field(15; AdmissionScheduleEntryNo; Integer)
        {
            Caption = 'Admission Schedule Entry No.';
            DataClassification = CustomerContent;
        }
        field(20; ProfileCode; Code[10])
        {
            Caption = 'Profile Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Dynamic Price Profile".ProfileCode;
        }
        field(21; LineNo; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }

        field(30; BasePrice; Decimal)
        {
            Caption = 'Base Price';
            DataClassification = CustomerContent;
        }
        field(31; AddonPrice; Decimal)
        {
            Caption = 'Addon Price';
            DataClassification = CustomerContent;
        }
        field(80; PricingOption; Option)
        {
            Caption = 'Pricing Option';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Fixed Amount,Relative Amount,Percentage';
            OptionMembers = NA,"FIXED",RELATIVE,PERCENT;
        }
        field(82; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(83; Percentage; Decimal)
        {
            Caption = 'Percentage';
            DataClassification = CustomerContent;
            MinValue = -100;
        }
        field(85; AmountIncludesVAT; Boolean)
        {
            Caption = 'Amount Includes VAT';
            DataClassification = CustomerContent;
        }
        field(86; VatPercentage; Decimal)
        {
            Caption = 'VAT Percentage';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 100;
        }
    }

    keys
    {
        key(PrimaryKey; ExtAdmissionScheduleEntryNo)
        {
            Clustered = true;
        }
        key(Key2; AdmissionCode)
        {
            Unique = false;
        }
    }
}