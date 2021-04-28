page 6014570 "NPR Retail Tools"
{
    Caption = 'Retail Tools';
    UsageCategory = Administration;
    ApplicationArea = All;
    actions
    {
        area(Processing)
        {
            action(NPRMigrateAuditRollToPOSEntry)
            {
                Caption = 'Migrate Audit Roll to POS Entry';
                Image = Process;
                ApplicationArea = All;

                trigger OnAction()
                var
                    RetailDataModelUpgrade: Report "NPR UPG RetDataMod AR Upgr.";
                begin
                    RetailDataModelUpgrade.Run();
                end;
            }
            action(NPRAction2)
            {
                Caption = 'Clean up';
                Image = Process;
                ApplicationArea = All;

                trigger OnAction()
                var
                    AuditRolltoPOSEntryLink: Record "NPR Audit Roll 2 POSEntry Link";
                    POSEntry: Record "NPR POS Entry";
                    POSSalesLine: Record "NPR POS Sales Line";
                    POSPaymentLine: Record "NPR POS Payment Line";
                    POSBalancingLine: Record "NPR POS Balancing Line";
                    POSLedgerRegister: Record "NPR POS Period Register";
                    POSEntryCommentLine: Record "NPR POS Entry Comm. Line";
                    POSTaxAmountLine: Record "NPR POS Tax Amount Line";
                begin
                    if not Confirm('Continue?', false) then exit;

                    AuditRolltoPOSEntryLink.DeleteAll(false);
                    POSEntry.DeleteAll(false);
                    POSSalesLine.DeleteAll(false);
                    POSPaymentLine.DeleteAll(false);
                    POSBalancingLine.DeleteAll(false);
                    POSLedgerRegister.DeleteAll(false);
                    POSEntryCommentLine.DeleteAll(false);
                    POSTaxAmountLine.DeleteAll(false);
                end;
            }
            action(NPRAction3)
            {
                Caption = 'Activation Validation Check';
                Image = Process;
                ApplicationArea = All;

                trigger OnAction()
                var
                    CacheRegister: Record "NPR Register";
                    POSUnit: Record "NPR POS Unit";
                begin
                    CacheRegister.SetFilter(Status, '<>%1', CacheRegister.Status::Afsluttet);
                    if (not CacheRegister.IsEmpty()) then
                        Error('Cash register must be empty/balanced.');

                    CacheRegister.Reset;
                    if (CacheRegister.FindSet()) then begin
                        repeat
                            if (not POSUnit.Get(CacheRegister."Register No.")) then
                                Error(NOT_ALL_CR_HAVE_POS_UNIT, CacheRegister.TableCaption(), POSUnit.TableCaption, CacheRegister."Register No.");
                        until (CacheRegister.Next() = 0);
                    end;
                end;

            }
        }
    }

    var
        NOT_ALL_CR_HAVE_POS_UNIT: Label 'All %1 must have a %2 when activating POS Entry posting. %1 %3 is missing its %2.';
}