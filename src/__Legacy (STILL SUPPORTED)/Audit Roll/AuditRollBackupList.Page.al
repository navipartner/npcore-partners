page 6014495 "NPR Audit Roll Backup List"
{
    // NPR5.27/LS  /20160922 CASE 252997 Created Page for Audit Roll Backup
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

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
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("Sale Type"; "Sale Type")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Sale Date"; "Sale Date")
                {
                    ApplicationArea = All;
                }
                field("Starting Time"; "Starting Time")
                {
                    ApplicationArea = All;
                }
                field("Closing Time"; "Closing Time")
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                }
                field(Posted; Posted)
                {
                    ApplicationArea = All;
                }
                field("Item Entry Posted"; "Item Entry Posted")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ApplicationArea = All;
                }
                field("Line Discount %"; "Line Discount %")
                {
                    ApplicationArea = All;
                }
                field("Line Discount Amount"; "Line Discount Amount")
                {
                    ApplicationArea = All;
                }
                field("VAT %"; "VAT %")
                {
                    ApplicationArea = All;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field(Offline; Offline)
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
            action("Move to Audit Roll")
            {
                Caption = 'Move to Audit Roll';
                Image = MoveUp;
                ApplicationArea=All;

                trigger OnAction()
                var
                    AuditRollBackup: Record "NPR Audit Roll Backup";
                    AuditRoll: Record "NPR Audit Roll";
                begin
                    //-NPR5.27  [252997]
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
                    //+NPR5.27  [252997]
                end;
            }
        }
    }
}

