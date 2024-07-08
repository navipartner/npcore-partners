page 6060084 "NPR APIV1 PBIItem Budget Ent."
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'itemBudgetEntry';
    EntitySetName = 'itemBudgetEntries';
    Caption = 'PowerBI Item Budget Entry';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "Item Budget Entry";
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.', Locked = true;
                }
                field(analysisArea; Rec."Analysis Area")
                {
                    Caption = 'Analysis Area', Locked = true;
                }
                field(budgetName; Rec."Budget Name")
                {
                    Caption = 'Budget Name', Locked = true;
                }
                field("date"; Rec."date")
                {
                    Caption = 'Date', Locked = true;
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item No.', Locked = true;
                }
                field(sourceType; Rec."Source Type")
                {
                    Caption = 'Source Type', Locked = true;
                }
                field(sourceNo; Rec."Source No.")
                {
                    Caption = 'Source No.', Locked = true;
                }
                field(description; Rec."Description")
                {
                    Caption = 'Description', Locked = true;
                }
                field(quantity; Rec."Quantity")
                {
                    Caption = 'Quantity', Locked = true;
                }
                field(costAmount; Rec."Cost Amount")
                {
                    Caption = 'Cost Amount', Locked = true;
                }
                field(salesAmount; Rec."Sales Amount")
                {
                    Caption = 'Sales Amount', Locked = true;
                }
                field("userId"; Rec."User Id")
                {
                    Caption = 'User Id', Locked = true;
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location Code', Locked = true;
                }
                field(globalDimension1Code; Rec."Global Dimension 1 Code")
                {
                    Caption = 'Global Dimension 1 Code', Locked = true;
                }
                field(globalDimension2Code; Rec."Global Dimension 2 Code")
                {
                    Caption = 'Global Dimension 2 Code', Locked = true;
                }
                field(budgetDimension1Code; Rec."Budget Dimension 1 Code")
                {
                    Caption = 'Budget Dimension 1 Code', Locked = true;
                }
                field(budgetDimension2Code; Rec."Budget Dimension 2 Code")
                {
                    Caption = 'Budget Dimension 2 Code', Locked = true;
                }
                field(budgetDimension3Code; Rec."Budget Dimension 3 Code")
                {
                    Caption = 'Budget Dimension 3 Code', Locked = true;
                }
                field(dimensionSetId; Rec."Dimension Set Id")
                {
                    Caption = 'Dimension Set Id', Locked = true;
                }
            }
        }
    }
}