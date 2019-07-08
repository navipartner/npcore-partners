table 6151050 "Item Hierarchy"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Item Hierarchy';

    fields
    {
        field(1;"Hierarchy Code";Code[20])
        {
            Caption = 'Hierarchy Code';
            NotBlank = true;
        }
        field(5;Description;Text[30])
        {
            Caption = 'Description';
        }
        field(10;"No. Of Levels";Integer)
        {
            Caption = 'No. Of Levels';
        }
        field(20;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,Sales,Purchase';
            OptionMembers = " ",Sales,Purchase;
        }
        field(30;"Sales History";Boolean)
        {
            Caption = 'Sales History';
            Enabled = false;
        }
        field(31;"Show Expanded";Boolean)
        {
            Caption = 'Show Expanded';
            Enabled = false;
        }
    }

    keys
    {
        key(Key1;"Hierarchy Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ItemHierarchyLevel: Record "Item Hierarchy Level";
        ItemHierarchyLine: Record "Item Hierarchy Line";
        RetaiReplDemandLine: Record "Retai Repl. Demand Line";
        DistributionSetup: Record "Distribution Setup";
    begin

        ItemHierarchyLevel.SetRange("Hierarchy Code","Hierarchy Code");
        ItemHierarchyLevel.DeleteAll(true);

        ItemHierarchyLine.SetRange("Item Hierarchy Code","Hierarchy Code");
        ItemHierarchyLine.DeleteAll(true);

        DistributionSetup.SetRange("Item Hiearachy","Hierarchy Code");
        DistributionSetup.DeleteAll(true);

        RetaiReplDemandLine.SetRange("Item Hierachy","Hierarchy Code");
        RetaiReplDemandLine.DeleteAll(true);
    end;
}

