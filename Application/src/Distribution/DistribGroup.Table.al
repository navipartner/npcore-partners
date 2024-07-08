table 6151055 "NPR Distrib. Group"
{
    Access = Internal;
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Group';
    DataClassification = CustomerContent;
    LookupPageID = "NPR Distrib. Group List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Group,Store';
            OptionMembers = Group,Store;
        }
        field(15; "Warehouse Location"; Code[10])
        {
            Caption = 'Warehouse Location';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(20; "Warehouse Overhead Pct."; Decimal)
        {
            Caption = 'Warehouse Overhead Pct.';
            DataClassification = CustomerContent;
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

    trigger OnDelete()
    var
        DistributionGroupMembers: Record "NPR Distrib. Group Members";
        DistributionHeaders: Record "NPR Distribution Headers";
        DistributionSetup: Record "NPR Distribution Setup";
    begin
        DistributionGroupMembers.SetRange("Distribution Group", Code);
        DistributionGroupMembers.DeleteAll(true);

        DistributionHeaders.SetRange("Distribution Group", Code);
        DistributionHeaders.DeleteAll(true);

        DistributionSetup.SetRange("Distribution Group", Code);
        DistributionSetup.DeleteAll(true);
    end;
}

