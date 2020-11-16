report 6151050 "NPR Add Hierachy Item"
{
    // #289017/JKL /20171222  CASE 289017 Object created - Replenishment Module

    Caption = 'Add Hierachy Item';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Item Hierarchy Line"; "NPR Item Hierarchy Line")
        {
            RequestFilterFields = "Item Hierarchy Code", "Item Hierarchy Level";

            trigger OnAfterGetRecord()
            begin
                LineNo := "Item Hierarchy Line"."Item Hierarchy Line No.";
            end;
        }
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            var
                ItemHierarchyLine: Record "NPR Item Hierarchy Line";
            begin
                ItemHierarchyLine.Copy("Item Hierarchy Line");
                ItemHierarchyLine."Item Hierarchy Line No." := LineNo + 1;
                ItemHierarchyLine."Item No." := Item."No.";
                ItemHierarchyLine."Item Desc." := Item.Description;
                if not ItemHierarchyLine.Insert then
                    Error(SplitLineError);
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        LineNo: Integer;
        SplitLineError: Label 'Splitline is not possible - Line can not be inserted!';
}

