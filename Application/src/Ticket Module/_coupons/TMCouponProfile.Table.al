table 6150842 "NPR TM CouponProfile"
{
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; ProfileCode; Code[20])
        {
            Caption = 'Profile Code';
            DataClassification = CustomerContent;
        }
        field(2; AliasCode; Code[20])
        {
            Caption = 'Coupon Alias';
            DataClassification = CustomerContent;
        }

        field(10; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(15; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
        field(21; Default; Boolean)
        {
            Caption = 'Default';
            DataClassification = CustomerContent;
        }
        field(25; CouponType; Code[20])
        {
            Caption = 'Coupon Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpDc Coupon Type";
        }
        field(30; ValidFromDate; Option)
        {
            Caption = 'Valid From Date';
            DataClassification = CustomerContent;
            OptionCaption = ',Purchase,First Admission,Selected Admission';
            OptionMembers = NA,PURCHASE,FIRST_ADMISSION,SELECTED_ADMISSION;
        }
        field(31; ValidForDateFormula; DateFormula)
        {
            Caption = 'Valid For Date Formula';
            DataClassification = CustomerContent;
        }
        field(35; RequiredAdmissionCode; Code[20])
        {
            Caption = 'Required Admission Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Admission";
        }
        field(40; AdmissionIsRequired; Boolean)
        {
            Caption = 'Admission Is Required';
            DataClassification = CustomerContent;
        }

        field(50; ForceTicketAmount; Boolean)
        {
            Caption = 'Force Ticket Amount';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2025-04-16';
            ObsoleteReason = 'Moved to enum "ForceAmount" to allow more options.';
        }
        field(51; ForceAmount; Enum "NPR TM CouponForceAmount")
        {
            Caption = 'Force Amount';
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(Key1; ProfileCode, AliasCode)
        {
            Clustered = true;
        }
    }
}