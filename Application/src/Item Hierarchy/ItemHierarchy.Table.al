table 6151050 "NPR Item Hierarchy"
{
    Access = Internal;
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Item Hierarchy';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Hierarchy Code"; Code[20])
        {
            Caption = 'Hierarchy Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "No. Of Levels"; Integer)
        {
            Caption = 'No. Of Levels';
            DataClassification = CustomerContent;
        }
        field(20; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Sales,Purchase';
            OptionMembers = " ",Sales,Purchase;
        }
        field(30; "Sales History"; Boolean)
        {
            Caption = 'Sales History';
            DataClassification = CustomerContent;
            Enabled = false;
        }
        field(31; "Show Expanded"; Boolean)
        {
            Caption = 'Show Expanded';
            DataClassification = CustomerContent;
            Enabled = false;
        }
    }

    keys
    {
        key(Key1; "Hierarchy Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ItemHierarchyLevel: Record "NPR Item Hierarchy Level";
        ItemHierarchyLine: Record "NPR Item Hierarchy Line";
        RetaiReplDemandLine: Record "NPR Retail Repl. Demand Line";
        DistributionSetup: Record "NPR Distribution Setup";
    begin

        ItemHierarchyLevel.SetRange("Hierarchy Code", "Hierarchy Code");
        ItemHierarchyLevel.DeleteAll(true);

        ItemHierarchyLine.SetRange("Item Hierarchy Code", "Hierarchy Code");
        ItemHierarchyLine.DeleteAll(true);

        DistributionSetup.SetRange("Item Hiearachy", "Hierarchy Code");
        DistributionSetup.DeleteAll(true);

        RetaiReplDemandLine.SetRange("Item Hierachy", "Hierarchy Code");
        RetaiReplDemandLine.DeleteAll(true);
    end;
}

