﻿table 6060106 "NPR Ean Box Event"
{
    Caption = 'Ean Box Event';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Input Box Events";
    LookupPageID = "NPR POS Input Box Events";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; "Module Name"; Text[50])
        {
            Caption = 'Module Name';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(15; "Action Code"; Code[20])
        {
            Caption = 'Action Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Action";

            trigger OnValidate()
            begin
            end;
        }
        field(20; "Action Description"; Text[250])
        {
            Caption = 'Action Description';
            Editable = false;
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Text that should follow user language can not be table data. Change to page variable populated runtime in wokflow v3.';
        }
        field(25; "POS View"; Option)
        {
            Caption = 'POS View';
            DataClassification = CustomerContent;
            OptionCaption = 'Sale,Payment';
            OptionMembers = Sale,Payment;
        }
        field(35; "Event Codeunit"; Integer)
        {
            Caption = 'Event Codeunit';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }
}

