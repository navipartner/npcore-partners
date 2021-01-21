page 6184891 "NPR Storage Setup"
{
    Caption = 'External Storage';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR Storage Setup";
    UsageCategory = Documents;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Storage Type"; "Storage Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Storage Type field';
                }
                field("Storage ID"; "Storage ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Storage ID field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
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
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Operations action';

                trigger OnAction()
                var
                    StorageOperationType: Record "NPR Storage Operation Type";
                    StorageOperationTypes: Page "NPR Storage Operation Types";
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

