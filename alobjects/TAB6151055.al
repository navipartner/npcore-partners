table 6151055 "Distribution Group"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Group';
    LookupPageID = "Distribution Group List";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(5;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(10;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Group,Store';
            OptionMembers = Group,Store;
        }
        field(15;"Warehouse Location";Code[10])
        {
            Caption = 'Warehouse Location';
            TableRelation = Location;
        }
        field(20;"Warehouse Overhead Pct.";Decimal)
        {
            Caption = 'Warehouse Overhead Pct.';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        DistributionGroupMembers: Record "Distribution Group Members";
        DistributionHeaders: Record "Distribution Headers";
        DistributionSetup: Record "Distribution Setup";
    begin
        DistributionGroupMembers.SetRange("Distribution Group",Code);
        DistributionGroupMembers.DeleteAll(true);

        DistributionHeaders.SetRange("Distribution Group",Code);
        DistributionHeaders.DeleteAll(true);

        DistributionSetup.SetRange("Distribution Group",Code);
        DistributionSetup.DeleteAll(true);
    end;
}

