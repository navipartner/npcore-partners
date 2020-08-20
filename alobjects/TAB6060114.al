table 6060114 "TM Ticket Access Fact"
{
    // NPR4.14/TSA/20150803/CASE214262 - Initial Version
    // TM1.00/TSA/20151217  CASE 228982 NaviPartner Ticket Management
    // TM1.07/TSA/20160125  CASE 232495 Added Admission Code as a fact
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.17/TSA /20161025  CASE 256152 Conform to OMA Guidelines
    // TM1.36/TSA /20180727 CASE 323024 Adding Variant as Dimension

    Caption = 'Ticket Access Fact';
    DataClassification = CustomerContent;
    DrillDownPageID = "TM Ticket Access Facts";
    LookupPageID = "TM Ticket Access Facts";

    fields
    {
        field(1; "Fact Name"; Option)
        {
            Caption = 'Fact Name';
            DataClassification = CustomerContent;
            OptionCaption = 'Item,Ticket Type,Admission Date,Admission Hour,Admission Code,Variant Code';
            OptionMembers = ITEM,TICKET_TYPE,ADMISSION_DATE,ADMISSION_HOUR,ADMISSION_CODE,VARIANT_CODE;
        }
        field(2; "Fact Code"; Code[20])
        {
            Caption = 'Fact Code';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(11; Block; Boolean)
        {
            Caption = 'Block';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Fact Name", "Fact Code")
        {
        }
    }

    fieldgroups
    {
    }
}

