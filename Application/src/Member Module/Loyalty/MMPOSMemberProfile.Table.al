table 6150851 "NPR MM POS Member Profile"
{
    Access = Internal;
    Caption = 'POS Member Profile';
    DataClassification = CustomerContent;
    LookupPageId = "NPR MM POS Member Profiles";
    DrillDownPageId = "NPR MM POS Member Profiles";
    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(4; "Print Membership On Sale"; Boolean)
        {
            Caption = 'Print Membership On Sale';
            DataClassification = CustomerContent;
        }
        field(5; "Send Notification On Sale"; Boolean)
        {
            Caption = 'Send Notification On Sale';
            DataClassification = CustomerContent;
        }
        field(6; "Alteration Group"; Code[10])
        {
            Caption = 'Alteration Group';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Members. Alter. Group";
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }
}