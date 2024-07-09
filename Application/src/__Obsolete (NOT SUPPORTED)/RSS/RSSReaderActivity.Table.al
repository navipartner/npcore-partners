﻿table 6059995 "NPR RSS Reader Activity"
{
    Access = Internal;
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'We dont use RSS Feed any more.';
    Caption = 'RSS Reader Activity';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Link; Text[250])
        {
            Caption = 'Link';
            DataClassification = CustomerContent;
        }
        field(10; Title; Text[250])
        {
            Caption = 'Title';
            DataClassification = CustomerContent;
        }
        field(20; "Published At"; DateTime)
        {
            Caption = 'Published At';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code", Link)
        {
        }
        key(Key2; "Published At")
        {
        }
    }
}

