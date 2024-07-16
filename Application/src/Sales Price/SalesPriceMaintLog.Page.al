page 6150833 "NPR Sales Price Maint. Log"
{
    ApplicationArea = NPRRetail;
    Caption = 'Sales Price Maintenance Log';
    Extensible = False;
    PageType = List;
    SourceTable = "NPR Sales Price Maint. Log";
    UsageCategory = Administration;
    SourceTableView = sorting("Entry No.") order(descending);

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Entry No. field.', Comment = '%';
                    Editable = false;
                    Enabled = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Item No. field.', Comment = '%';
                    Editable = false;
                    Enabled = false;
                }
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Processed field.', Comment = '%';
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the SystemModifiedAt field.', Comment = '%';
                    Editable = false;
                    Enabled = false;
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the SystemModifiedBy field.', Comment = '%';
                    Editable = false;
                    Enabled = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ProcessManually)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Process Manually';
                Image = Process;
                ToolTip = 'Process the log entry';
                trigger OnAction()
                var
                    Item: Record Item;
                    SalesPriceMaintenance: Codeunit "NPR Sales Price Maint. Event";
                    SalesPriceMaintSetup: Record "NPR Sales Price Maint. Setup";
                begin
                    Item.Get(Rec."Item No.");
                    SalesPriceMaintenance.UpdateSalesPricesForStaff(Item, SalesPriceMaintSetup, true);
                    Rec.Processed := true;
                    Rec.Modify();
                end;
            }
        }
    }
}
