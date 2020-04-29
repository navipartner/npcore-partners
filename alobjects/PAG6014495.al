page 6014495 "Audit Roll Backup List"
{
    // NPR5.27/LS  /20160922 CASE 252997 Created Page for Audit Roll Backup
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Audit Roll Backup List';
    Editable = false;
    PageType = List;
    Permissions = TableData "Audit Roll"=rimd;
    SourceTable = "Audit Roll Backup";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Sales Ticket No.";"Sales Ticket No.")
                {
                }
                field("Register No.";"Register No.")
                {
                }
                field("Sale Type";"Sale Type")
                {
                }
                field(Type;Type)
                {
                }
                field("Sale Date";"Sale Date")
                {
                }
                field("Starting Time";"Starting Time")
                {
                }
                field("Closing Time";"Closing Time")
                {
                }
                field("No.";"No.")
                {
                }
                field(Amount;Amount)
                {
                }
                field(Description;Description)
                {
                }
                field("Customer No.";"Customer No.")
                {
                }
                field(Posted;Posted)
                {
                }
                field("Item Entry Posted";"Item Entry Posted")
                {
                }
                field(Quantity;Quantity)
                {
                }
                field("Amount Including VAT";"Amount Including VAT")
                {
                }
                field("Line Discount %";"Line Discount %")
                {
                }
                field("Line Discount Amount";"Line Discount Amount")
                {
                }
                field("VAT %";"VAT %")
                {
                }
                field("Salesperson Code";"Salesperson Code")
                {
                }
                field(Offline;Offline)
                {
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

                trigger OnAction()
                var
                    AuditRollBackup: Record "Audit Roll Backup";
                    AuditRoll: Record "Audit Roll";
                begin
                    //-NPR5.27  [252997]
                    AuditRollBackup.Copy(Rec);
                    CurrPage.SetSelectionFilter(AuditRollBackup);
                    if AuditRollBackup.FindSet then repeat
                      if not AuditRoll.Get(AuditRollBackup."Register No.",AuditRollBackup."Sales Ticket No.",AuditRollBackup."Sale Type",AuditRollBackup."Line No.",
                       AuditRollBackup."No.",AuditRollBackup."Sale Date") then begin
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

