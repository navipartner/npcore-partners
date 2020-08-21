page 6184891 "Storage Setup"
{
    // NPR5.54/ALST/20200311 CASE 394895 Object created

    Caption = 'External Storage';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Storage Setup";
    UsageCategory = Documents;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Storage Type"; "Storage Type")
                {
                    ApplicationArea = All;
                }
                field("Storage ID"; "Storage ID")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action(Operations)
            {
                Caption = 'Operations';
                Image = DataEntry;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    StorageOperationType: Record "Storage Operation Type";
                    StorageOperationTypes: Page "Storage Operation Types";
                begin
                    StorageOperationType.FilterGroup(2);
                    StorageOperationType.SetRange("Storage Type", "Storage Type");
                    StorageOperationType.FilterGroup(0);

                    StorageOperationTypes.HandleStorageID("Storage ID");

                    StorageOperationTypes.SetTableView(StorageOperationType);
                    StorageOperationTypes.RunModal;
                end;
            }
        }
    }
}

