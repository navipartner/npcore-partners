table 6014654 "NPR Tax Free GB I2 Param."
{
    Access = Internal;

    Caption = 'Tax Free GB I2 Parameter';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Tax Free Unit"; Code[10])
        {
            Caption = 'Tax Free Unit';
            TableRelation = "NPR Tax Free POS Unit"."POS Unit No.";
            DataClassification = CustomerContent;
        }
        field(2; "Shop ID"; Text[30])
        {
            Caption = 'Shop ID';
            DataClassification = CustomerContent;
        }
        field(3; "Desk ID"; Text[30])
        {
            Caption = 'Desk ID';
            DataClassification = CustomerContent;
        }
        field(4; Username; Text[30])
        {
            Caption = 'Username';
            DataClassification = CustomerContent;
        }
        field(5; Password; Text[30])
        {
            Caption = 'Password';
            DataClassification = CustomerContent;
        }
        field(6; "Consolidation Allowed"; Boolean)
        {
            Caption = 'Consolidation Allowed';
            DataClassification = CustomerContent;
        }
        field(7; "Consolidation Separate Limits"; Boolean)
        {
            Caption = 'Consolidation Separate Limits';
            DataClassification = CustomerContent;
        }
        field(8; "Voucher Issue Date Limit"; DateFormula)
        {
            Caption = 'Voucher Issue Date Limit';
            DataClassification = CustomerContent;
        }
        field(9; "Shop Country Code"; Integer)
        {
            BlankZero = true;
            Caption = 'Shop Country Code';
            DataClassification = CustomerContent;
        }
        field(10; "Date Last Auto Configured"; Date)
        {
            Caption = 'Date Last Auto Configured';
            DataClassification = CustomerContent;
        }
        field(11; "Services Eligible"; Boolean)
        {
            Caption = 'Services Eligible';
            DataClassification = CustomerContent;
        }
        field(12; "Count Zero VAT Goods For Limit"; Boolean)
        {
            Caption = 'Count Zero VAT Goods For Limit';
            DataClassification = CustomerContent;
        }
        field(30; "(Dialog) Passport Number"; Option)
        {
            Caption = 'Passport Number';
            OptionCaption = 'Hide,Optional,Required';
            OptionMembers = Hide,Optional,Required;
            DataClassification = CustomerContent;
        }
        field(31; "(Dialog) First Name"; Option)
        {
            Caption = 'First Name';
            OptionCaption = 'Hide,Optional,Required';
            OptionMembers = Hide,Optional,Required;
            DataClassification = CustomerContent;
        }
        field(32; "(Dialog) Last Name"; Option)
        {
            Caption = 'Last Name';
            OptionCaption = 'Hide,Optional,Required';
            OptionMembers = Hide,Optional,Required;
            DataClassification = CustomerContent;
        }
        field(33; "(Dialog) Street"; Option)
        {
            Caption = 'Street';
            OptionCaption = 'Hide,Optional,Required';
            OptionMembers = Hide,Optional,Required;
            DataClassification = CustomerContent;
        }
        field(34; "(Dialog) Postal Code"; Option)
        {
            Caption = 'Postal Code';
            OptionCaption = 'Hide,Optional,Required';
            OptionMembers = Hide,Optional,Required;
            DataClassification = CustomerContent;
        }
        field(35; "(Dialog) Town"; Option)
        {
            Caption = 'Town';
            OptionCaption = 'Hide,Optional,Required';
            OptionMembers = Hide,Optional,Required;
            DataClassification = CustomerContent;
        }
        field(36; "(Dialog) Country Code"; Option)
        {
            Caption = 'Country Code';
            OptionCaption = 'Hide,Optional,Required';
            OptionMembers = Hide,Optional,Required;
            DataClassification = CustomerContent;
        }
        field(37; "(Dialog) Email"; Option)
        {
            Caption = 'Email';
            OptionCaption = 'Hide,Optional,Required';
            OptionMembers = Hide,Optional,Required;
            DataClassification = CustomerContent;
        }
        field(38; "(Dialog) Mobile No."; Option)
        {
            Caption = 'Mobile No.';
            OptionCaption = 'Hide,Optional,Required';
            OptionMembers = Hide,Optional,Required;
            DataClassification = CustomerContent;
        }
        field(39; "(Dialog) Passport Country Code"; Option)
        {
            Caption = 'Passport Country Code';
            OptionCaption = 'Hide,Optional,Required';
            OptionMembers = Hide,Optional,Required;
            DataClassification = CustomerContent;
        }
        field(40; "(Dialog) Date Of Birth"; Option)
        {
            Caption = 'Date Of Birth';
            OptionCaption = 'Hide,Optional,Required';
            OptionMembers = Hide,Optional,Required;
            DataClassification = CustomerContent;
        }
        field(41; "(Dialog) Departure Date"; Option)
        {
            Caption = 'Departure Date';
            OptionCaption = 'Hide,Optional,Required';
            OptionMembers = Hide,Optional,Required;
            DataClassification = CustomerContent;
        }
        field(42; "(Dialog) Arrival Date"; Option)
        {
            Caption = 'Arrival Date';
            OptionCaption = 'Hide,Optional,Required';
            OptionMembers = Hide,Optional,Required;
            DataClassification = CustomerContent;
        }
        field(43; "(Dialog) Dest. Country Code"; Option)
        {
            Caption = 'Dest. Country Code';
            OptionCaption = 'Hide,Optional,Required';
            OptionMembers = Hide,Optional,Required;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Tax Free Unit")
        {
        }
    }
}

