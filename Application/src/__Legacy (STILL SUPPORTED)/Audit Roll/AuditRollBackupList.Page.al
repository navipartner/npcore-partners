page 6014495 "NPR Audit Roll Backup List"
{
    Caption = 'Audit Roll Backup List';
    Editable = false;
    PageType = List;
    Permissions = TableData "NPR Audit Roll" = rimd;
    SourceTable = "NPR Audit Roll Backup";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Register No. field';
                }
                field("Sale Type"; "Sale Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sale Type field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Sale Date"; "Sale Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sale Date field';
                }
                field("Starting Time"; "Starting Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Time field';
                }
                field("Closing Time"; "Closing Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Closing Time field';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field(Posted; Posted)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posted field';
                }
                field("Item Entry Posted"; "Item Entry Posted")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Entry Posted field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Including VAT field';
                }
                field("Line Discount %"; "Line Discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Discount % field';
                }
                field("Line Discount Amount"; "Line Discount Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Discount Amount field';
                }
                field("VAT %"; "VAT %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT % field';
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field(Offline; Offline)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Offline field';
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Move to Audit Roll")
            {
                Caption = 'Move to Audit Roll';
                Image = MoveUp;
                ApplicationArea = All;
                ToolTip = 'Executes the Move to Audit Roll action';

                trigger OnAction()
                var
                    AuditRollBackup: Record "NPR Audit Roll Backup";
                    AuditRoll: Record "NPR Audit Roll";
                begin
                    AuditRollBackup.Copy(Rec);
                    CurrPage.SetSelectionFilter(AuditRollBackup);
                    if AuditRollBackup.FindSet then
                        repeat
                            if not AuditRoll.Get(AuditRollBackup."Register No.", AuditRollBackup."Sales Ticket No.", AuditRollBackup."Sale Type", AuditRollBackup."Line No.",
                             AuditRollBackup."No.", AuditRollBackup."Sale Date") then begin
                                AuditRoll.TransferFields(AuditRollBackup);
                                AuditRoll.Insert;
                            end;
                        until AuditRollBackup.Next = 0;
                end;
            }
        }
    }
}

